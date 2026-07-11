# fio 方法学证据

生成时间：2026-07-11 17:28:55 CST

## Source Inventory

| 来源 URL / 本地路径 | 来源类型 | 证据等级 | 已抓取正文 |
| --- | --- | --- | --- |
| `https://raw.githubusercontent.com/axboe/fio/master/HOWTO.rst` | 官方文档，HOWTO | A | 是 |
| `https://raw.githubusercontent.com/axboe/fio/master/fio.1` | 官方文档，man page | A | 是 |
| `https://github.com/axboe/fio/blob/master/example_latency_steadystate.fio` | 官方仓库示例 job file | A | 是 |
| `https://github.com/axboe/fio/releases` | 官方 release page | A | 是 |
| `../checklist-topic-evidence/06-observability-benchmark-cost.md` | 本地参考材料，已整理 evidence | B | 是 |
| `../../domain-map.md` | 本地 checklist 草案 | B | 是 |

## Version Note

- 这份证据优先使用 fio 官方 `master` 分支文档与官方示例文件，抓取日期为 2026-07-11。
- fio 官方 release page 显示最新公开版本为 `fio 3.42`，发布时间为 2026-04-07；因此 `master` 文档可能已经领先于稳定发布版，写 claim 时应记录实际使用的 fio 版本。
- 与本题相关的几个选项在当前文档里已经明确版本/平台依赖，例如 `uncached` 仅在 Linux 6.14 起支持，`log_hist_msec` 也明确强调了 percentile 精度与日志窗口的关系。

## Methodology Notes

| 关键点 | fio 官方方法学含义 | 对 storage checklist 的压力 |
| --- | --- | --- |
| job file 是第一性 artifact | fio 以 `ini` 风格 job file 为核心，`global` 段定义共享参数，`include` 可复用标准设置，命令行只是同一配置的展开形式。 | benchmark 不应只保留命令行截图；必须保留 job file、include 层次和 section 结构。 |
| `iodepth` 不是“越大越好” | 官方文档把 `iodepth` 定义为异步引擎下维持的队列深度；某些引擎只支持特定深度行为，`thinktime_blocks=1` 还会把有效 QD 压回 1。 | 必须把 `iodepth` 视为引擎语义的一部分，而不是单独的调参项。 |
| `ioengine` 会改变语义和开销 | `libaio` 需要非 buffered I/O 才能获得真正 queued 行为；`io_uring` 同时支持 direct 和 buffered；`libcufile`、`http`、`xnvme` 等引擎都有自己的约束和额外路径。 | 任何结果都必须写明 engine，不同 engine 之间不能直接对比成“系统性能差异”。 |
| `direct` / `buffered` 是缓存态，不是修饰词 | `direct=1` 表示 non-buffered I/O，通常是 `O_DIRECT`；`buffered=1` 是默认值，等价于走 page cache。 | benchmark matrix 必须显式区分 cache state，否则结果不可比较。 |
| `numjobs` 与 `group_reporting` 要成对看 | `numjobs` 会复制 job；`group_reporting` 让 fio 汇总一组 job 的最终结果，尤其在 `numjobs` 很大时更容易读，但也更容易掩盖 job 间方差。 | claim table 不能只存 group level 总结，至少要保留 per-job 方差或分位数。 |
| `time_based` / `runtime` / `ramp_time` 是稳态窗口控制器 | 官方说明 `ramp_time` 会在开始记录前先跑一段时间，`time_based` + `runtime` 或 `loops` 常用于避免文件大小导致的提前停机。 | 必须把 warmup 和 measured window 分开写，不能把“跑了 10 分钟”混成“测了 10 分钟”。 |
| percentiles 不能靠平滑平均替代 | `log_avg_msec` 会降低分辨率；官方明确说用它计算尾延迟 percentiles 不准确，`log_hist_msec` 才是保留 percentile 准确性的做法。 `log_entries` 还会影响 tail latency，因为运行时动态分配日志条目会污染 99.9th percentile。 | 需要把 percentile 口径、日志粒度、窗口长度和日志条目上限写进 artifact。 |
| `verify` 会改变路径和成本 | `verify` 在 read-after-write 场景下会按已写数据回读验证；异步引擎、`iodepth > 1`、`norandommap` 组合有明确误报风险，官方建议用 `lfsr` 或避免该组合。 | 不能把 verify 当“顺手打开的安全开关”；它是独立的方法学维度，必须记录。 |
| `fsync` / `fdatasync` / `flush` 语义要单列 | fio 提供 `fdatasync`、`end_fsync`、`end_syncfs`、`fsync_on_close` 等控制点，分别影响数据同步、元数据同步、文件级 flush、stage 结束 flush。 | durable/flush 语义必须与性能结果一起记录，否则写放大和尾延迟不可解释。 |
| `steadystate` 是停机条件，不是装饰项 | 官方 `steadystate` 允许按 `iops`、`bw`、`lat` 及其 slope 判断稳态；判断只使用 rolling window 数据，并建议配合 `time_based` / `runtime` / `loops`。 | 长跑 benchmark 必须说明稳态判据，否则“稳定结果”没有定义。 |

## Checklist Impact

### Gate 7 应如何收紧

- Gate 7 里的 `benchmark 是否覆盖 workload matrix，而不是单点最佳参数？` 应升级为“benchmark matrix + fio job file + 结果解释”三件套。
- Gate 7 里的 `测试是否进入稳态并覆盖后台任务？` 应把 `ramp_time`、`runtime`、`steadystate` 和后台任务并列为必填字段，而不是只写“跑久一点”。
- Gate 7 里的 `外部或内部性能 claim 是否有方法学？` 应强制要求 `fio_version`、`job_file_hash`、`engine`、`cache_state` 和 `percentile_definition`。

### benchmark matrix 建议新增字段

| 新增字段 | 用途 |
| --- | --- |
| `fio_version` / `fio_release_tag` | 锁定工具版本，避免 master 与 release 漂移。 |
| `job_file` / `job_file_hash` | 让矩阵行可回放、可审计。 |
| `ioengine` | 区分 sync / async / userspace / GPU path。 |
| `filename` / `device` | 明确被测对象是文件、块设备还是远端端点。 |
| `rw` / `bs` / `size` | 描述访问模式和工作集。 |
| `iodepth` | 描述并发队列深度。 |
| `numjobs` | 描述并行 job 数。 |
| `direct` / `buffered` | 描述 page cache 是否参与。 |
| `time_based` / `runtime` / `ramp_time` | 分离 warmup、测量窗口和总运行时间。 |
| `steadystate` / `steadystate_duration` / `steadystate_ramp_time` / `steadystate_check_interval` | 描述稳态判据和采样窗口。 |
| `verify` / `verify_async` | 描述是否进入验证路径。 |
| `fsync` / `fdatasync` / `end_fsync` / `end_syncfs` / `fsync_on_close` | 描述 durability 和 flush 行为。 |
| `group_reporting` | 描述结果是 per-job 还是 group-level。 |
| `log_hist_msec` / `log_entries` / `output_format` | 描述 percentile 和日志采样精度。 |
| `warmup_state` / `cache_state` | 描述是否已清 page cache、是否预热、是否允许回读命中缓存。 |

### claim table 建议新增字段

| 新增字段 | 用途 |
| --- | --- |
| `metric` | 吞吐、IOPS、P99、P999、CPU/IOPS、功耗等。 |
| `percentile_definition` | 明确 P95/P99/P99.9 的计算方式和来自哪一层日志。 |
| `aggregation_level` | per-job、group-level 还是 cluster-level。 |
| `measurement_window` | warmup 后真正计入的时间窗。 |
| `steady_state_criterion` | 用于终止或截断测试的稳态判据。 |
| `cache_state` | direct/buffered，是否有 page cache 干扰。 |
| `queue_model` | `iodepth`、`numjobs`、engine 组合如何形成并发。 |
| `verification_mode` | verify / read-after-write / verify-only 等。 |
| `sync_mode` | fsync/fdatasync/end_fsync/end_syncfs/fsync_on_close。 |
| `fio_version` | 让 claim 具备版本锚点。 |
| `hardware_software_context` | 设备、内核、文件系统、驱动、CPU 频率状态。 |
| `artifact_link` | job file、raw output、图表、脚本。 |
| `error_bars` / `variance` | 给出方差和重复次数，避免单次峰值误导。 |

## Open Gaps

| 缺口 | 还需要什么 | 为什么还不够 |
| --- | --- | --- |
| 版本差异 | 需要把这套方法学再对齐到一个固定 fio release tag，例如 `fio 3.42` 或你们实验实际使用的版本。 | `master` 文档会漂移，当前结论只能视为“截至 2026-07-11 的最新公开文档”。 |
| 示例 job 文件 | 需要 1 份 `direct=1`、1 份 `buffered=1`、1 份 `verify`、1 份 `fsync/end_fsync`、1 份 `group_reporting + numjobs` 的最小 job file。 | 现在只能靠官方说明和单个 steadystate 示例，缺少可直接复用的四五个模板。 |
| engine 对照实验 | 需要在目标存储栈上实际跑 `libaio`、`io_uring`、必要时 `psync` / `libcufile` 的对照。 | 官方只说明语义差异，没有给出你们设备上的方法学开销。 |
| percentile 口径验证 | 需要一次真实输出验证 `log_hist_msec`、`log_entries`、`json+` 或 `terse` 对尾延迟的影响。 | 目前只有文档上的准确性警告，没有本项目数据。 |
| steadystate 经验参数 | 需要针对目标 workload 验证 `steadystate_duration`、`steadystate_ramp_time`、`steadystate_check_interval` 的可收敛组合。 | 官方给了机制，但不是针对你们 workload 的参数最优值。 |
| sync / flush 成本 | 需要测 `fdatasync`、`end_fsync`、`end_syncfs`、`fsync_on_close` 对 latency / throughput 的真实影响。 | 文档定义了语义，但没告诉你们系统里它们的代价。 |

## Evidence Table

| check_item | source | local_ref | evidence_type | evidence_note | design_pressure | confidence | gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| job file 语义是否完整、可复现？ | `https://raw.githubusercontent.com/axboe/fio/master/HOWTO.rst` | `HOWTO.rst L20-L27` | official docs | 经典 `ini` job file；`global` 段共享参数，`include` 可复用标准设置，命令行只是展开后的等价形式。 | benchmark 必须保留 job file 与 include 层次，不能只留命令行。 | A | 还缺你们项目的最小模板集。 |
| `iodepth` 是否被当成独立并发旋钮？ | `https://raw.githubusercontent.com/axboe/fio/master/HOWTO.rst` / `https://raw.githubusercontent.com/axboe/fio/master/fio.1` | `HOWTO.rst L1-L3` / `fio.1 L267-L271` | official docs | HOWTO 把 `iodepth` 定义为 async engine 的 queuing depth；man page 进一步指出部分设置会让有效队列深度被压回 1，且 offload 会引入额外协调开销。 | 必须把 QD、engine 和 thinktime 一起解释。 | A | 需在目标设备上做 QD sweep。 |
| `ioengine` 差异是否影响结论？ | `https://raw.githubusercontent.com/axboe/fio/master/HOWTO.rst` | `HOWTO.rst L1-L3, L170-L187` | official docs | 文档明确列出 `libaio`、`io_uring`、`libcufile`、`http`、`xnvme` 等引擎及其各自限制；例如 `libaio` 需要 non-buffered I/O 才能表现 queued 行为。 | engine 不是实现细节，而是语义边界。 | A | 需要按目标工作负载做 engine 对照。 |
| `direct` / `buffered` 是否显式分流缓存态？ | `https://raw.githubusercontent.com/axboe/fio/master/HOWTO.rst` / `https://raw.githubusercontent.com/axboe/fio/master/fio.1` | `HOWTO.rst L91-L91` / `fio.1 L78-L78` | official docs | `direct=1` 是 non-buffered I/O，`buffered` 是相反开关，且默认值不同。 | page cache 是否参与必须进入 benchmark matrix。 | A | 需要真实 cache-state 对照实验。 |
| `numjobs` 与结果汇总是否被正确区分？ | `https://raw.githubusercontent.com/axboe/fio/master/HOWTO.rst` / `https://raw.githubusercontent.com/axboe/fio/master/fio.1` | `HOWTO.rst L24-L27` / `fio.1 L343-L343` | official docs | HOWTO 用 `numjobs=4` 说明复制 job 的方式，man page 说明 `group_reporting` 更适合 `numjobs` 场景但会把 per-job 差异藏起来。 | claim table 不能只报 group-level 汇总。 | A | 还需保留 per-job 方差。 |
| `time_based` / `runtime` / `ramp_time` 是否分开？ | `https://raw.githubusercontent.com/axboe/fio/master/HOWTO.rst` / `https://raw.githubusercontent.com/axboe/fio/master/fio.1` | `HOWTO.rst L45-L47, L350-L350` / `fio.1 L32-L32` | official docs | `ramp_time` 是测量前的 lead-in；`time_based` + `runtime` 或 `loops` 避免按文件大小提前结束；`ramp_time` 会增加总时长。 | warmup 与测量窗口必须拆开写。 | A | 需要目标 workload 的稳态长度。 |
| percentiles / tail latency 是否被正确采样？ | `https://raw.githubusercontent.com/axboe/fio/master/HOWTO.rst` / `https://raw.githubusercontent.com/axboe/fio/master/fio.1` | `HOWTO.rst L364-L368, L424-L425` / `fio.1 L351-L355, L407-L407` | official docs | 官方明确说 `log_avg_msec` 会损失 percentile 准确性，`log_hist_msec` 保留 percentile，`log_entries` 过低会影响 99.9th percentile。 | percentile 口径、日志粒度和条目上限都要写入 artifact。 | A | 需要做一次真实 histogram 输出验证。 |
| `verify` 是否改变 I/O 路径或误差模型？ | `https://raw.githubusercontent.com/axboe/fio/master/fio.1` | `fio.1 L320-L327` | official docs | 读取已写数据时验证逻辑不同；异步引擎 + `iodepth > 1` + `norandommap` 可能产生误报，官方建议用 `lfsr` 或避免该组合。 | verify 是方法学维度，不是安全开关。 | A | 需要最小 verify-readback job。 |
| `fsync` / `fdatasync` / `flush` 是否进入方法学？ | `https://raw.githubusercontent.com/axboe/fio/master/HOWTO.rst` | `HOWTO.rst L112-L116` | official docs | `fdatasync` 只同步数据，`end_fsync` 在 write stage 完成后执行 `fsync`，`end_syncfs` 用 `syncfs`，`fsync_on_close` 在关闭时 flush dirty file。 | durable 语义和性能成本必须一起记录。 | A | 还缺你们文件系统/设备上的 cost 测量。 |
| `steadystate` 是否作为停机判据而非装饰项？ | `https://raw.githubusercontent.com/axboe/fio/master/fio.1` / `https://github.com/axboe/fio/blob/master/example_latency_steadystate.fio` | `fio.1 L339-L341` / `example_latency_steadystate.fio L330-L372` | official docs + official example | `steadystate` 支持 `lat`、`lat_slope`、`iops`、`bw` 等判据；官方示例把 `ioengine=libaio`、`iodepth=32`、`direct=1`、`time_based=1`、`runtime=3600`、`steadystate_ramp_time=60`、`steadystate_duration=300` 组合在一起。 | 长跑 benchmark 需要可复述的稳态终止条件。 | A | 还缺针对目标 workload 的参数收敛实验。 |
| `group_reporting` 是否掩盖 job 级差异？ | `https://raw.githubusercontent.com/axboe/fio/master/HOWTO.rst` / `https://raw.githubusercontent.com/axboe/fio/master/fio.1` | `HOWTO.rst L357-L357` / `fio.1 L343-L343` | official docs | `group_reporting` 会把组内 jobs 汇总；文档同时提醒 JSON 输出里有些字段没有自然的 group-level 等价物。 | 聚合口径必须显式记录。 | A | 需要保留 per-job 结果原始文件。 |
| 文档版本是否足够新？ | `https://github.com/axboe/fio/releases` | `releases L180-L245` | official release page | 官方 release page 公开列出 `fio 3.42` 为最新版本，时间为 2026-04-07，且 release note 里有 `uncached buffered I/O`、`sync for file operations`、`verify_only` 等相关变更。 | 方法学应该带版本号，不能抽象成“fio 一直都这样”。 | A | master 文档可能比 3.42 更前沿。 |

