# RocksDB write stall / slowdown 补证

生成时间：2026-07-11 17:30:04 CST

## Source Inventory

| 来源 URL / 本地路径 | 来源类型 | 证据等级 | 已抓取正文 |
| --- | --- | --- | --- |
| `https://raw.githubusercontent.com/facebook/rocksdb/d52b520d5168de6be5f1494b2035b61ff0958c11/docs/components/write_flow/07_flow_control.md` | 官方文档，write-flow / flow-control | A | 是 |
| `https://raw.githubusercontent.com/facebook/rocksdb/d52b520d5168de6be5f1494b2035b61ff0958c11/docs/components/write_flow/10_performance.md` | 官方文档，write-flow / tuning | A | 是 |
| `https://raw.githubusercontent.com/facebook/rocksdb/d52b520d5168de6be5f1494b2035b61ff0958c11/db/column_family.cc` | 官方源码，stall 条件判定与 token 选择 | A | 是 |
| `https://raw.githubusercontent.com/facebook/rocksdb/d52b520d5168de6be5f1494b2035b61ff0958c11/db/write_controller.cc` | 官方源码，delay token 与 credit-based rate limit | A | 是 |
| `https://raw.githubusercontent.com/facebook/rocksdb/d52b520d5168de6be5f1494b2035b61ff0958c11/db/db_impl/db_impl_write.cc` | 官方源码，DelayWrite / no_slowdown / bg_cv_ | A | 是 |
| `https://raw.githubusercontent.com/facebook/rocksdb/d52b520d5168de6be5f1494b2035b61ff0958c11/db/write_controller.h` | 官方源码，默认 delayed_write_rate 与上限 | A | 是 |
| `https://raw.githubusercontent.com/facebook/rocksdb/d52b520d5168de6be5f1494b2035b61ff0958c11/db/write_stall_stats.cc` | 官方源码，stall 统计与 cause/condition 映射 | A | 是 |
| `../checklist-topic-evidence/03-io-queues.md` | 本地既有证据卡，前轮 RocksDB compaction pressure / gap | B | 是 |
| `../checklist-topic-evidence/05-background-recovery.md` | 本地既有证据卡，后台压实与恢复语义 | B | 是 |
| `../../domain-map.md` | 本地 checklist 输入，source-document 待补证项与 gate 映射 | B | 是 |

## Version Note

- 这轮证据以 `facebook/rocksdb` 当前 `main` 分支为准，抓取时间为 2026-07-11。
- RocksDB 官方写流文档是滚动维护文档，不是固定 release 手册；因此这里把 commit SHA 一并固定为 `d52b520d5168de6be5f1494b2035b61ff0958c11`。
- 需要特别注意：不同 RocksDB 版本、不同 compaction style、以及 `disable_auto_compactions` / `allow_stall` 等配置，会改变 stall 语义或直接绕过部分条件。

## Mechanism Notes

### 1) 先分清三条通路：stop、delay、compaction pressure

RocksDB 的写流控制不是单一开关，而是三类 token 协同：

- `StopWriteToken`：完全阻塞写入。
- `DelayWriteToken`：按 `delayed_write_rate` 限速。
- `CompactionPressureToken`：不直接 stall 写入，但提高压实并行度。

官方写流文档明确把写流控制拆成 `WriteController` 和可选的 `WriteBufferManager` 两个子系统。前者主要针对单 DB 的 compaction lag，后者针对跨 DB 共享的 memtable 内存预算。

### 2) Stop 条件优先于 delay 条件

`ColumnFamilyData::GetWriteStallConditionAndCause()` 先判断 stop，再判断 delay。

Stop 条件有三类，都是“达到阈值就停写”：

- 未 flush 的 immutable memtable 数量 `num_unflushed_memtables >= max_write_buffer_number`
- L0 文件数 `num_l0_files >= level0_stop_writes_trigger`
- pending compaction bytes `num_compaction_needed_bytes >= hard_pending_compaction_bytes_limit`

Delay 条件也有三类，但只会降速，不会完全停写：

- memtable 接近上限：`max_write_buffer_number > 3` 且接近最后一个 buffer
- L0 文件数达到 slowdown trigger
- pending compaction bytes 达到 soft limit

这里有两个关键约束：

- `stop >= slowdown >= compaction_trigger` 不是用户随便填的关系，`SanitizeOptions()` 会检查并在必要时收紧数值。
- 如果 `disable_auto_compactions` 打开，L0 / pending-compaction 的 stall 逻辑会被明显削弱或跳过，不能把它当成默认路径。

### 3) `delayed_write_rate` 不是静态常量，而是会被动态调节

`SetupDelay()` 会根据 compaction debt 的变化动态调整 `delayed_write_rate`：

- debt 没有下降时，继续降速。
- debt 下降时，逐步恢复。
- 接近 stop 边界时，降速更激进。

源码里能确认的约束有：

- 最小写速率下限是 `16 KB/s`
- `WriteController` 构造函数默认 `max_delayed_write_rate = 32 MB/s`
- `GetDelay()` 使用 credit-based 方案，并按约 1ms 颗粒 refill

因此，`delayed_write_rate` 应该被理解为“写入被 stall 后的即时放行速率”，不是一个永远不变的配置常量。

### 4) `no_slowdown` 语义是直接返回错误，而不是等待

`DBImpl::DelayWrite()` 里，若当前写入需要 delay/stop 且 `WriteOptions.no_slowdown` 为真，RocksDB 会直接返回 `Status::Incomplete("Write stall")`。

否则：

- 对 delay 路径，leader 会调用 `BeginWriteStall()`，释放 mutex，然后以 1ms 粒度睡眠并轮询是否仍需 stall。
- 对 stop 路径，leader 会在 `bg_cv_` 上等待，直到 `total_stopped_` 归零。

这意味着写 stall 对上层应用的表现分成两种：

- 阻塞等待
- 立即失败（`no_slowdown`）

这两个分支都要在 checklist 里显式列出，不能只写“变慢了”。

### 5) `WriteBufferManager` 是另一条全局 backpressure 路径

`WriteBufferManager::ShouldStall()` 关注的是总 memtable 内存，而不是某个 CF 的 L0 或 pending bytes。

条件很简单：

- 构造时允许 `allow_stall`
- `memory_usage() >= buffer_size_`

一旦触发，`DBImpl::WriteBufferManagerStallWrites()` 会先让 write thread 进入 stall，再由 `WriteBufferManager` 的唤醒机制恢复。

所以如果系统启用了共享 `WriteBufferManager`，write stall 不能只看 RocksDB 单 CF 的 L0 / compaction debt，还要把跨 DB 的内存上限算进去。

### 6) 监控与归因是有明确 cause/condition 枚举的

`db/write_stall_stats.cc` 把 stall 原因和状态拆成可观测枚举：

- `memtable-limit`
- `l0-file-count-limit`
- `pending-compaction-bytes`
- `write-buffer-manager-limit`

状态又分成：

- `delays`
- `stops`

这说明 write stall 不是只能靠日志猜，RocksDB 已经把它做成统计项，checklist 应该要求这些指标进入观测面。

## Checklist Impact

### Gate 4. Read/Write Path And Queue Budget

应补强为“写路径 + stall 路径”而不只是普通 write path。

建议修改点：

- 在 `write-path-sequence.md` 里显式增加 `PreprocessWrite -> DelayWrite -> BeginWriteStall/EndWriteStall -> bg_cv_ wait` 的分支图。
- 把 `no_slowdown` 写成独立语义：不是所有 stall 都等待，有些会返回 `Incomplete("Write stall")`。
- 在 queue budget 里把三类 stall 因素分开列：`max_write_buffer_number`、`L0`、`pending compaction bytes`，不要合并成一个“后台压力”泛称。
- 如果系统启用 `WriteBufferManager`，把它标成独立的全局内存 backpressure 入口。

### Gate 6. Durability, Recovery, And Background Work

应把 RocksDB 的后台压实当成“会反向影响前台写”的资源治理对象。

建议修改点：

- 在后台任务清单里增加 `write stall / slowdown` 作为 compaction debt 的外显症状，而不是只写 compaction 本身。
- 对 `soft_pending_compaction_bytes_limit` / `hard_pending_compaction_bytes_limit` 增加“版本与配置敏感”注记，避免把一个版本的默认值写死成通用事实。
- 若使用 FIFO compaction style 或禁用自动压实，应在 gate 里单独标出“stall 语义被钝化/绕过”的例外。

### Gate 7. Observability, Benchmark, And Artifact

应把 write stall 作为必须可观测、可复现的 artifact。

建议修改点：

- 要求 benchmark artifact 同时记录：RocksDB commit SHA、column family options、compaction style、`no_slowdown`、`enable_pipelined_write`、`disable_auto_compactions`。
- 指标至少包含：`STALL_MICROS`、`WRITE_STALL`、`L0_FILE_COUNT_LIMIT_DELAYS/STOPS`、`MEMTABLE_LIMIT_DELAYS/STOPS`、`PENDING_COMPACTION_BYTES_LIMIT_DELAYS/STOPS`、`WRITE_BUFFER_MANAGER_LIMIT_STOPS`。
- 需要把“stall onset”与 workload trace 对齐，不然只能知道慢，不能知道为什么慢。

## Open Gaps

- 还缺“当前项目实际使用的 RocksDB 版本”与对应 release note 的版本化核验，不能直接把 `main` 分支行为当作项目生产版本行为。
- 还缺 `level0_*`、`soft/hard_pending_compaction_bytes_limit`、`delayed_write_rate` 在目标版本上的默认值核验，以及默认值是否被上层封装改写。
- 还缺针对目标 workload 的实验：L0 增长、memtable 堆积、pending compaction bytes 增长分别在什么负载下触发 delay / stop。
- 还缺对 `WriteBufferManager` 是否启用的项目级确认；若没启用，这条全局 stall 路径可降权。
- 还缺 FIFO compaction / disable_auto_compactions / `no_slowdown` 的组合测试，确认 checklist 是否要把这些当成例外分支。

## Evidence Table

| check_item | source | local_ref | evidence_type | evidence_note | design_pressure | confidence | gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| RocksDB write stall / slowdown 总览 | RocksDB 官方写流文档 | `facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:docs/components/write_flow/07_flow_control.md:L1-L18` | mechanism | 官方文档把 flow control 拆成 `WriteController` 和 `WriteBufferManager`，前者针对 compaction lag，后者针对共享 memtable 内存。 | checklist 不能把写 stall 只写成“后台压实慢”，必须区分单 DB 与共享内存两条路径。 | A | 需要项目版本与配置核验，确认是否启用 `WriteBufferManager`。 |
| L0 file slowdown | RocksDB 官方写流文档 + 源码 | `facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:docs/components/write_flow/07_flow_control.md:L24-L31; facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:db/column_family.cc:L1033-L1037; facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:db/column_family.cc:L1114-L1124` | mechanism | `num_l0_files >= level0_slowdown_writes_trigger` 触发 delay；`SetupDelay()` 再根据 compaction debt 调整 `delayed_write_rate`。 | checklist 要把 L0 slowdown 作为独立门槛，而不是和 pending bytes 混写。 | A | 具体阈值是 option 级别，且 FIFO/禁用自动压实会改变适用性。 |
| L0 stop writes | RocksDB 官方写流文档 + 源码 | `facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:docs/components/write_flow/07_flow_control.md:L16-L23; facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:db/column_family.cc:L1016-L1020` | mechanism | `num_l0_files >= level0_stop_writes_trigger` 会直接进入 stop，写线程停止前进，等待 compaction 追上。 | gate 4 和 gate 6 都要把“完全停写”与“仅降速”分开描述。 | A | 还要结合当前版本确认默认 trigger 与 compaction style 的联动。 |
| Pending compaction bytes slowdown | RocksDB 官方写流文档 + 源码 | `facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:docs/components/write_flow/07_flow_control.md:L24-L31; facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:db/column_family.cc:L1038-L1043; facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:db/column_family.cc:L1136-L1159` | mechanism | `compaction_needed_bytes >= soft_pending_compaction_bytes_limit` 触发 delay；`SetupDelay()` 会在 debt 不下降时继续降速，并在接近 stop 时更激进。 | checklist 需要把“pending compaction debt”写成可观测的写入预算项。 | A | `soft` 可能被 sanitize 到 `hard`，且 0 值语义依赖版本与配置。 |
| Pending compaction bytes stop writes | RocksDB 官方写流文档 + 源码 | `facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:docs/components/write_flow/07_flow_control.md:L16-L23; facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:db/column_family.cc:L1021-L1026` | mechanism | `compaction_needed_bytes >= hard_pending_compaction_bytes_limit` 会直接 stop writes。 | gate 6 应该把 hard limit 视为恢复/后台工作治理边界。 | A | 还需要目标版本的默认值和运维阈值。 |
| Memtable 近满导致 slowdown | RocksDB 官方写流文档 + 源码 | `facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:docs/components/write_flow/07_flow_control.md:L24-L30; facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:db/column_family.cc:L1027-L1032` | mechanism | 未 flush memtable 接近 `max_write_buffer_number` 时会进入 delay，而不是等到完全耗尽才停。 | queue budget 里必须保留 memtable 压力项，不要只盯 L0。 | A | 需要实际 workload 下的 memtable 增长曲线来验证。 |
| `delayed_write_rate` 机制 | RocksDB 官方写流文档 + 源码 | `facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:docs/components/write_flow/07_flow_control.md:L50-L71; facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:db/write_controller.cc:L22-L33; facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:db/write_controller.cc:L51-L99; facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:db/write_controller.h:L26-L35; facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:db/write_controller.h:L62-L79` | mechanism | `GetDelay()` 是 credit-based rate limiter，1ms refill；`delayed_write_rate` 会在 stall 期间动态调整，上限来自 `max_delayed_write_rate`。 | checklist 不能把 delay 写成固定 sleep；它是可调节速率控制。 | A | 还要确认目标版本是否改过默认 `max_delayed_write_rate`。 |
| `no_slowdown` 与阻塞行为 | RocksDB 官方源码 | `facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:db/db_impl/db_impl_write.cc:L2811-L2887` | boundary | `no_slowdown` 时直接返回 `Status::Incomplete("Write stall")`；否则 delay 分支会睡眠，stop 分支会在 `bg_cv_` 上等待。 | checklist 要把“阻塞等待”和“立即失败”分别写进 API / 运行语义。 | A | 还需要上层调用者是否会把 `Incomplete` 重试的约定。 |
| WriteBufferManager 全局 stall | RocksDB 官方文档 + 源码 | `facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:docs/components/write_flow/07_flow_control.md:L83-L119; facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:db/db_impl/db_impl_write.cc:L2173-L2182; facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:db/db_impl/db_impl_write.cc:L2917-L2936` | mechanism | 共享 memtable 预算达到 `buffer_size_` 时会 stall，cause 归类为 `write-buffer-manager-limit`。 | gate 6 要把“跨 DB 共享预算”单独列出来。 | A | 需要项目级确认是否真的启用共享 WBM。 |
| Stall 监控与归因 | RocksDB 官方源码 | `facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:db/write_stall_stats.cc:L14-L28; facebook/rocksdb@d52b520d5168de6be5f1494b2035b61ff0958c11:db/write_stall_stats.cc:L35-L90` | mechanism | `memtable-limit`、`l0-file-count-limit`、`pending-compaction-bytes`、`write-buffer-manager-limit` 都有对应统计枚举。 | gate 7 应要求这些指标进入 artifact，而不是只采吞吐和 P99。 | A | 还缺与项目现有监控系统的映射。 |
| 既有本地证据卡的缺口确认 | 本地既有证据卡 | `../checklist-topic-evidence/03-io-queues.md; ../checklist-topic-evidence/05-background-recovery.md` | gap | 先前证据卡已经确认 RocksDB compaction pressure，但明确标出 write-stall / slowdown 触发阈值缺失。 | 说明这次补证是必要的，不是重复劳动。 | B | 还要把项目使用版本和真实 workload 跑通。 |

## Reusable Takeaway

RocksDB 的 write stall / slowdown 不是一个阈值，而是三类背压入口的组合：`max_write_buffer_number`、`L0 file count`、`pending compaction bytes`，再叠加共享 `WriteBufferManager` 的全局内存限制；其中 `delay` 和 `stop` 是不同语义，`no_slowdown` 还会直接返回 `Incomplete("Write stall")`。检查表应该把这些路径分开写进 gate 4 / 6 / 7，并把 RocksDB 版本、compaction style 和实际配置一起固定住。
