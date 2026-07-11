# Evidence Table: 5. I/O 栈与技术选型 / 6. 线程、队列与 Backpressure

## 范围
- 仅基于 `../../domain-map.md` 的第 5、6 章。
- 必读输入已覆盖：`../../domain_knowledge/reference_cards/kernel/index.md`、`../../domain_knowledge/reference_cards/hardware/index.md`、`../../domain_knowledge/reference_cards/opensource/index.md`，以及 `../web-snapshots/` 中各 batch 的抓取结果。
- 仅使用本地 reference cards 与已抓取的本地 markdown 快照，不联网。

## Evidence Table

| check_item | source | local_ref | evidence_type | evidence_note | design_pressure | confidence | gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 5. I/O 栈选型 - blk-mq | Linux Kernel `blk-mq` | `../../domain_knowledge/reference_cards/kernel/index.md:L7-L17` | mechanism | blk-mq 把 software staging queue 和 hardware dispatch queue 分层，`bio` 先组装成 `request`，再通过 tag-based completion 提交；完成顺序不由 block layer 保证。 | 选型必须明确多队列、调度、合并和完成顺序，而不是只说“走块层”。 | A | 需要具体驱动的 queue 映射和硬件队列绑定规则。 |
| 5. I/O 栈选型 - io_uring | Linux Kernel `io_uring` | `../../domain_knowledge/reference_cards/kernel/index.md:L43-L53` | mechanism | io_uring 提供共享 submission/completion rings，并依赖严格的内存屏障；实现里能看到 `SQPOLL`、`IOPOLL`、`io_wq` 下沉、deferred completion 和 CQ overflow。 | 异步 I/O 设计必须显式处理 ring 顺序、溢出和跨线程完成，不要把“async”当成免费午餐。 | B | 这份证据是滚动 `master` 源码摘录，缺少固定 commit。 |
| 5. I/O 栈选型 - NVMe passthrough | Linux Kernel `nvme/host/ioctl.c` | `../../domain_knowledge/reference_cards/kernel/index.md:L55-L65` | boundary | `nvme_validate_passthru_nsid()`、`nvme_cmd_allowed()`、`timeout_ms -> jiffies`、提交到 `admin_q` / `ns->queue`，说明 ioctl/passthrough 不是绕过控制面的“裸通道”，而是带权限和超时约束的命令桥接。 | 若要暴露 NVMe passthrough，必须定义权限、namespace 校验和超时预算。 | B | ABI 兼容和最近变更未做 commit 级核验。 |
| 5. I/O 栈选型 - NVMe 规范版本 | NVM Express Specifications / Archives | `../../domain_knowledge/reference_cards/hardware/index.md:L11-L17; L41-L43` | boundary | 官方规范入口明确当前最新 NVMe 规范集于 2025-08-05 发布，指向 NVMe 2.3 族；归档页还能定位 Base、Command Set、Transport、Boot、NVMe-MI 的 ratified 版本。 | 任何 NVMe 相关结论都要锁定版本和子规范，不能只写“NVMe 支持”。 | A | 子规范 PDF、ECN/TP 的逐项影响尚未展开。 |
| 5. I/O 栈选型 - NVMe-oF 历史边界 | NVM Express NVMe-oF historical reference | `../../domain_knowledge/reference_cards/hardware/index.md:L20-L31` | counterexample | 官方历史页明确说 NVMe-oF 1.0/1.1 已并入 Base spec，页面本身只作 historical reference，不再作为当前演进主线。 | 不能把 1.x 的旧语义当成当前 NVMe-oF 事实。 | A | 若要写当前 fabric 语义，仍需回到 Base / Transport 规范。 |
| 5. I/O 栈选型 - SPDK NVMe-oF target | SPDK `NVMe over Fabrics Target` | `../../domain_knowledge/reference_cards/kernel/index.md:L79-L88` | mechanism | SPDK 文档把 target 定义为用户态应用，支持 RDMA 和 TCP，并与 Linux kernel target/host 做互操作测试；RDMA 还要求 OFED、内核模块和 NIC 前置条件。 | 选用户态 fabric 栈时，必须把部署前置条件和互操作边界一起写进 ADR。 | A | 版本对应的支持矩阵和配置差异未在本页展开。 |
| 6. 线程、队列与 Backpressure - qpair/thread ownership | SPDK `NVMe` docs | `../web-snapshots/batch-03/text/223fdef65d3cf51d.md:L424-L430; L436-L438` | boundary | `spdk_nvme_qpair` 是并行提交路径，但一个 qpair 只能由单线程使用；推荐固定线程池、一个 qpair 对一个线程，并把线程 pin 到 CPU core。队列条目大小和 MQES 直接决定内存预算。 | 队列/线程所有权必须单写单用，否则会退化成未定义行为；队列深度也必须进入容量预算。 | A | 需要把该模型映射到实际 CPU/core 和 device queue 数。 |
| 6. 线程、队列与 Backpressure - DPDK EAL / hugepage | SPDK `NVMe` docs (DPDK EAL section) | `../web-snapshots/batch-03/text/223fdef65d3cf51d.md:L460-L471` | boundary | SPDK 说明 DPDK EAL 用 primary/secondary process 管理 hugepage 共享内存；secondary 通过映射 shared memory 继续做 NVMe 操作并创建 queue pairs。 | 用户态 I/O 栈的 backpressure 和资源隔离，实际落在 hugepage、共享内存分组和进程角色上。 | A | DPDK standalone 资料未在本轮单独展开版本树。 |
| 6. 线程、队列与 Backpressure - Alluxio worker routing | Alluxio Architecture / DORA whitepaper | `../../domain_knowledge/reference_cards/opensource/index.md:L31-L34` | mechanism | Alluxio 通过 consistent hashing ring 把请求路由到 worker；worker 先查本地 NVMe Page Store，元数据与数据页共址于 worker 上的 RocksDB，cache miss 才回源到对象存储；UFS 是 source of truth。 | 线程/队列设计要把 worker locality 当成 fast path 的一部分，而不是把缓存当成纯附属层。 | B | 该白皮书的性能数字较多，但版本锚点和方法学较弱。 |
| 6. 线程、队列与 Backpressure - Alluxio claim | Alluxio homepage / AI claims | `../../domain_knowledge/reference_cards/opensource/index.md:L31-L34` | claim | 页面宣称 sub-millisecond data access、TB/s throughput 和 training performance 提升 35% 等结果，但没有在当前快照中给出完整方法学。 | 这类数字只能作为线索，不能直接当作 backpressure 或容量设计依据。 | C | 需要独立 benchmark、trace 和 workload matrix 验证。 |
| 6. 线程、队列与 Backpressure - FoundationDB roles / Ratekeeper | FoundationDB 7.3.77 | `../../domain_knowledge/reference_cards/opensource/index.md:L127-L134; ../source-document-evidence/foundationdb-ratekeeper.md` | mechanism | FoundationDB 把系统拆成 Coordinators、Cluster Controller、Master、GRV/Commit Proxies、Transaction Logs、Resolvers、Storage Servers、Data Distributor、Ratekeeper；storage servers 只保留约 5 秒 mutation，超窗会触发 `transaction_too_old`。 | backpressure 和限流必须前置到角色层，否则队列和日志窗口很容易被打满。 | A | Ratekeeper 的具体算法和调参项还没在本轮展开。 |
| 6. 线程、队列与 Backpressure - RocksDB compaction pressure | RocksDB repository README | `../../domain_knowledge/reference_cards/opensource/index.md:L109-L117; L146-L151` | mechanism | RocksDB 是嵌入式 LSM KV store，明确在 WAF/RAF/SAF 间做权衡，并支持多线程 compaction；这是典型的后台压实压力源。 | 前台写入与 compaction 必须隔离并观测，不然尾延迟会被后台工作吞掉。 | B | 当前快照没有直接给出 write-stall / slowdown 触发阈值。 |
| 6. 线程、队列与 Backpressure - RocksDB stall gap | RocksDB repository README | `../../domain_knowledge/reference_cards/opensource/index.md:L116-L117` | gap | 现有 snapshot 能证明 compaction 压力和 API 边界，但没有直接落到“什么时候进入 write stall / stop writes”的规则。 | 如果 checklist 要求的是 stall 语义，必须补 RocksDB 的 write-stall/slowdown 源文档或源码。 | D | 需要专门补写 write stall、L0 slowdown、pending compaction bytes 的证据。 |

## Gaps
- RocksDB 这轮只拿到 compaction 压力和 LSM 取舍，没有直接拿到 write-stall / slowdown 的触发条件。
- FoundationDB 只抽到了角色边界和 5 秒 mutation 窗口，Ratekeeper 的具体限流算法、阈值和告警策略还没展开。
- Alluxio 的 worker 机制证据够强，但性能数字属于 claim，仍需要独立 benchmark 或 trace 佐证。
- NVMe 规范已经锁到 2.3 族入口，但子规范 PDF、ECN/TP 影响还没有逐项展开。
- DPDK 相关证据主要来自 SPDK 的 DPDK EAL 说明，standalone DPDK 文档树还可以补一次版本化核验。
