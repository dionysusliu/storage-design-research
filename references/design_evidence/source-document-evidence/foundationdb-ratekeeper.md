# FoundationDB Ratekeeper 二次补证

生成时间：2026-07-11（Asia/Shanghai）

## Source Inventory

| 来源 | URL / 本地路径 | 类型 | 证据等级 | 正文已抓取 |
| --- | --- | --- | --- | --- |
| FoundationDB 文档首页 | `https://apple.github.io/foundationdb/` | 官方文档首页 / 版本入口 | A | 是 |
| FoundationDB Architecture | `https://apple.github.io/foundationdb/architecture.html` | 官方 architecture 文档 | A | 是 |
| FDB Read and Write Path | `https://apple.github.io/foundationdb/read-write-path.html` | 官方路径说明 / 设计说明 | B | 是 |
| Monitored Metrics | `https://apple.github.io/foundationdb/monitored-metrics.html` | 官方监控与告警文档 | A | 是 |
| FoundationDB README | `https://github.com/apple/foundationdb/blob/main/README.md` | 官方仓库首页 / 版本状态 | A | 是 |
| 本地既有补证草稿 | `../checklist-topic-evidence/03-io-queues.md:L22-L28` | 本地研究草稿 / 上一轮 evidence | B | 是 |
| 本地 checklist 草案 | `../../domain-map.md` | 本地 checklist 任务定义 | B | 是 |

## Version Note

1. 官方 docs 站点当前版本锚点是 `FoundationDB 7.3.77`，这是本次补证的主版本基线。
2. 同一仓库 `main` 分支 README 在本次抓取时仍写着 latest stable `7.3.69`；这说明“文档站点版本”和“README 里的 stable release”不是同一个锚点，写 checklist 时要明确引用的是哪一个。
3. `FDB Read and Write Path` 明确写了“content is based on FDB 6.2 and is true for FDB 6.3”，所以它适合用来补机制拓扑和术语，不适合单独作为 7.3.77 的精确实现依据。

## Mechanism Notes

1. Ratekeeper 是 FoundationDB 集群里的 singleton 角色之一。官方 architecture 文档说明它自 6.2 起不再和 Master 绑定在同一生命周期里，而是由 Cluster Controller 招募和监控。
2. 它的控制点不在数据面读写本身，而在事务启动入口：GRV proxy 会和 Ratekeeper 协作，Ratekeeper 通过降低 proxy 发放 read version 的速率来“放慢”客户端事务开始速率。
3. 这意味着 Ratekeeper 是集群级 admission control，而不是 storage server 上的本地 queue limiter。真正承压的队列是 storage server 的 write queue 和 transaction log 的 write queue。
4. 官方监控文档把 Ratekeeper 的信号拆成了几类状态量：
   - `cluster.qos.transactions_per_second_limit`：集群允许启动的事务速率。
   - `cluster.qos.batch_transactions_per_second_limit`：batch priority 的更低启动上限。
   - `cluster.qos.released_transactions_per_second`：实际释放的事务速率；接近或超过 limit 时，官方文档明确把它解释为 saturation 信号，并提示 GRV latency 可能上升。
   - `cluster.qos.worst_queue_bytes_storage_server` / `cluster.qos.limiting_queue_bytes_storage_server`：storage server 的最大写队列与被 Ratekeeper 计入限流的最大写队列。
   - `cluster.qos.worst_queue_bytes_log_server`：transaction log 的最大写队列。
   - `cluster.processes.<id>.roles[n].input_bytes.hz`：storage / log 角色的输入速率，官方文档指出这些数据在内存里至少停留 5 秒，速率过高会把队列顶大。
5. 队列与阈值关系已经能确认，但控制环路的实现细节还不能从当前文档完整推出：
   - storage queue 默认 target 是 1.0GB，达到 900MB 时 Ratekeeper 开始尝试降速。
   - storage queue 到 1.5GB 会触发 e-brake，storage server 会停止从 transaction log 拉 mutation，等自己 flush 掉一部分内存再继续。
   - batch priority 在 storage queue 到 500MB 时会被更早限制。
   - log queue 默认 target 是 2.4GB，达到 2.0GB 时 Ratekeeper 开始尝试降速。
   - log queue 到 1.5GB 会 spill 到磁盘上的持久结构，batch priority 在 1.0GB 时会被更早限制。
6. `transaction_too_old` 不是 Ratekeeper 的直接返回值，而是 storage server 只保留约 5 秒 mutation 窗口之后形成的读版本边界。它属于数据保留 / 可读版本窗口问题，不等同于 Ratekeeper 的 admission control。
7. 在写路径上，官方 read/write path 文档说明 proxy 负责把事务 mutation 送入 durable queuing system，按 shard 映射到 `k` 个 log process；HA 写路径文档再补充了 proxy、primary tLogs、satellite tLogs、log router、remote tLogs、remote SSes 的旅行路径。当前能确认的是：Ratekeeper 影响的是上游事务启动速率；文档里没有给出它对 log router 的直接控制接口，所以这一点只能作为路径依赖，不能写成机制事实。

## Checklist Impact

### Gate 4. Read/Write Path And Queue Budget

`../../domain-map.md` 要求把 queue depth 和 backpressure 第一触发点讲清楚。Ratekeeper 这组证据把它从“泛泛限流”变成了可操作拆解：

1. backpressure 第一触发点应写成 `transaction-start admission`，而不是等 storage/log 队列爆满后才处理。
2. queue budget 不能只写客户端 / RPC / 网络队列，必须把 `storage server write queue` 和 `transaction log write queue` 单独列出来。
3. 设计文档里要区分三层信号：
   - `Ratekeeper Limit`：集群允许启动的事务速率。
   - `Max Storage Queue` / `Max Log Queue`：队列层的物理压力。
   - `transaction_too_old`：版本窗口耗尽，不是 rate limit 本身。
4. 这会直接加强 checklist 对 `queue-backpressure-budget.md` 的要求：除了 QD，还要记录 queue age、e-brake、spill、batch priority limit 和 released TPS。

### Gate 7. Observability, Benchmark, And Artifact

`../../domain-map.md` 需要能拆出 queue time 和暴露 queue dashboard。Ratekeeper 的监控面已经给出了应该进 dashboard 的最小字段集：

1. `transactions_per_second_limit` 与 `released_transactions_per_second` 必须并排看，否则只能看到“限额”，看不到“是否已逼近 saturation”。
2. `worst_queue_bytes_storage_server`、`limiting_queue_bytes_storage_server`、`worst_queue_bytes_log_server` 要作为 queue pressure 的主面板，而不是只看 CPU / 磁盘 busy。
3. `data_lag.seconds`、`durability_lag.seconds` 要和 queue bytes 绑在一起看，用来区分“限流成功但还在追赶”与“队列已顶住但下游没有追上”。
4. 告警阈值可以直接借用官方建议：storage 最大队列 500MB、limiting queue 500MB 10 分钟、log queue 1.6GB 3 分钟、worst replica lag 15 秒 3 分钟。

## Open Gaps

1. 还需要补 `fdbserver/ratekeeper/*` 的源码级路径确认，至少要把主实现文件和关键 knob 读出来，才能把“Ratekeeper 如何计算 limit”写成机制而不是推断。
2. 还需要按版本核对 6.2 / 6.3 / 7.3.77 的行为差异。当前能确认的只有：Ratekeeper 从 6.2 起变成 cluster singleton，官方 docs 站点版本为 7.3.77，而 main 分支 README 仍展示 latest stable 7.3.69，二者存在版本锚点差异。
3. 需要验证 queue 阈值是硬编码默认值、配置 knob，还是 status 汇总后的派生值；当前文档只说明了默认 target 和告警阈值，没有展开控制回路。
4. 如果 checklist 需要写到运维 runbook 级别，还要补一个 live cluster 的 status dump 或实验，证明 `released_transactions_per_second` 接近 limit 时 GRV latency 的上升与 queue bytes 的增长是可重复的。

## Evidence Table

| check_item | source | local_ref | evidence_type | evidence_note | design_pressure | confidence | gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Gate 4 - backpressure 第一触发点 | FoundationDB Architecture | `https://apple.github.io/foundationdb/architecture.html` | mechanism | Ratekeeper 是 cluster singleton，和 GRV proxy 协作，直接降低 proxy 发放 read version 的速率；它限的是事务启动入口，不是单机 IO 队列本身。 | 把限流点放在 transaction-start admission，而不是等 storage / log 队列爆满。 | A | 具体控制环路与平滑策略未在当前文档中展开。 |
| Gate 4 - queue depth budget / storage queue | Monitored Metrics | `https://apple.github.io/foundationdb/monitored-metrics.html` | threshold | storage server 默认 target queue 1.0GB，900MB 开始降速，1.5GB 触发 e-brake；batch priority 在 500MB 更早受限。 | 队列预算必须包含 e-brake 和 batch priority 侧的更早门槛。 | A | 阈值是否由 knob 派生、以及 fault-domain 豁免的精确规则仍需源码核对。 |
| Gate 4 - queue depth budget / log queue | Monitored Metrics | `https://apple.github.io/foundationdb/monitored-metrics.html` | threshold | transaction log 默认 target queue 2.4GB，2.0GB 开始降速，1.5GB spill 到磁盘；batch priority 在 1.0GB 更早限制。 | 写路径预算必须把 transaction log 作为独立压力源，不可只看 storage server。 | A | log queue 的控制回路与 storage queue 是否共享同一控制器，还缺源码确认。 |
| Gate 7 - queue dashboard / alert rules | Monitored Metrics | `https://apple.github.io/foundationdb/monitored-metrics.html` | observability | `transactions_per_second_limit`、`released_transactions_per_second`、`worst_queue_bytes_storage_server`、`worst_queue_bytes_log_server`、`data_lag.seconds`、`durability_lag.seconds` 都是可直接进 dashboard 的 status 字段。 | checklist 的 observability 不能只放总延迟和 CPU，要明确 queue bytes、lag 和 limit / released TPS。 | A | 需要一份 live cluster 的 dashboard / alert 实例来验证面板布局。 |
| Gate 4 / Gate 7 - write path 和 durable queue | FDB Read and Write Path | `https://apple.github.io/foundationdb/read-write-path.html` | mechanism | proxy 负责把 mutation 送入 durable queuing system，按 shard 映射到 `k` 个 log process；storage system 则保存 5 秒历史 mutation 并提供读。 | queue/backpressure 设计必须把 proxy、log、storage 三段分开画。 | B | 该文档明确标注内容基于 FDB 6.2 / 6.3，版本外推到 7.3.77 时要复核。 |
| Gate 4 - 版本窗口 / `transaction_too_old` | FoundationDB Architecture | `https://apple.github.io/foundationdb/architecture.html` | boundary | storage server 只保留约 5 秒 mutation，超出读版本窗口会得到 `transaction_too_old`。 | checklist 需要把“版本保留窗口”与“事务启动限流”分开，否则容易把两个控制问题混成一个。 | A | 需要源码或更细设计文档确认 5 秒窗口在新版本中的实现细节是否变化。 |
