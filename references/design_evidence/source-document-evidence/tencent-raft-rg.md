# Tencent TDSQL Boundless / TDStore: Region, Replication Group, Raft 与事务/恢复证据

生成时间：2026-07-11（Asia/Shanghai）

## Source Inventory

| 来源 | 来源类型 | 证据等级 | 已抓取正文 | 生命周期状态 | 备注 |
| --- | --- | --- | --- | --- | --- |
| https://intl.cloud.tencent.com/document/product/1292/78894 | Tencent 官方英文产品文档 | A | 是 | 当前，持续更新（Last updated: 2026-04-17） | `Storage Engine Architecture and Data Model`；给出 TDStore、三层元数据模型、Region/RG/Raft roles、KV 编码。 |
| https://intl.cloud.tencent.com/document/product/1292/76231 | Tencent 官方英文产品文档 | A | 是 | 当前，持续更新（Last updated: 2026-02-10） | `The Lifecycle of an Update SQL`；给出 MC 时间戳、路由缓存、Region split、RPC 重试、commit 失败状态。 |
| https://cloud.tencent.com/document/product/1376/130340 | Tencent 官方中文文档 | A | 是 | 当前，持续更新（最近更新时间：2026-04-08） | `存储引擎架构与数据模型`；与英文页互证，正文更易直接核对术语。 |
| https://cloud.tencent.com/document/product/1376/130341 | Tencent 官方中文文档 | A | 是 | 当前，持续更新（最近更新时间：2026-04-08） | `分布式事务与数据亲和性`；给出 2PC 下沉、Raft log 作为 WAL、重启回放、1PC/2PC 亲和优化。 |
| ../../domain_knowledge/reference_cards/hyperscaler/index.md | 本地 hyperscaler reference card | B | 是（本地摘要，非原文） | 当前，本轮研究摘要 | 已把 Tencent 页提炼成可回写的机制卡，但它不是原始正文。 |
| ../../domain_knowledge/source-inventory.md:314-317 | 本地 source registry | B | 是（登记项） | 当前，源登记入口 | 记录了 Tencent 英文/中文入口和 raw 深链；用于追溯 canonical source。 |

## Mechanism Notes

- **DataObject**
  - 逻辑层对象是 table、index、partition、自增值等；层级是 Database -> Table -> Index/Partition。
  - 它的作用不是描述物理存储位置，而是定义拓扑感知的数据亲和关系，并保存表结构、二级索引等元数据。

- **Region**
  - Region 是连续的 Key Range，是最小物理存储单元。
  - 文档给出的容量边界是 `256MB` 或 `100,000` 行。
  - 一个 RG 可以包含多个 Region；单个分片最多只承载一个 data object 的数据。
  - 事务页明确说 Region 可 split / merge，且 routing 会随之动态变化。

- **Replication Group**
  - RG 是基于 Raft 的物理存储单元，一主 N 备。
  - Leader 处理所有读写请求。
  - Follower 同步数据并可参与选举。
  - Learner 只同步数据，不参与选举。
  - Witness 参与选举，但不存储数据。
  - RG 对应一个 Raft log stream；同一 RG 可管理多个 Region，并支持 data affinity scheduling。

- **TDStore / Raft / KV 编码**
  - TDStore 构建在 RocksDB 之上，包含 data shard module、distributed transaction module 和 Raft consensus module。
  - 所有数据都编码成 KV，key 具备 mem-comparable 特性。
  - 系统为每个 index 分配全局递增唯一 ID；同一 index 的数据共享前缀，逻辑上连续。
  - 文档把 Multi-Raft 用作多副本容灾层，每个 data shard 作为独立日志流同步。

- **事务路径**
  - 事务开始时，executor 从 Metadata Center（MC）获取全局 timestamp，作为 read snapshot / MVCC 基准。
  - SQL engine 先查两级 routing cache，再在 miss 或 stale 时 RPC 到 MC 获取最新 route。
  - 普通读写按 key -> Region 路由；commit / rollback retry 走 RG-level router。
  - 事务读写访问的是目标 RG 的 Leader 副本。
  - 2PC 被下沉到 TDStore 层，SQLEngine 不感知完整提交流程。
  - 提交前事务数据缓存在内存中；真正持久化发生在 commit 阶段。
  - TDStore 直接使用 Raft log 作为 WAL；节点重启后从上一记录点回放 Raft log，磁盘刷新后推进日志点。

- **恢复 / 故障 / 时序**
  - 读取时，如果 storage node 收到带旧 Region version 的请求，会拒绝并要求 SQL engine 刷新路由后重试。
  - Scan 在 Region split 后会失败并重试；executor 会根据新的 routing cache 把剩余范围拆分到新的 Region 上，避免重复或遗漏。
  - Write RPC 遇到网络错误时，文档要求主动断开 client connection，以避免重试包乱序写入导致不一致。
  - Commit RPC 遇到网络错误时，连接也会被断开；客户端进入 uncertain state，需要应用层自行验证结果。
  - DDL 提交时会同时更新 Data Dictionary 和 storage node 上的 Write Fence；storage node 会比对 `<schema_obj_id, schema_obj_version>`，不匹配则拒绝 DML。
  - 官方文档还明确说，节点级变化通常发生在扩容时；更常见的调度发生在 Region split/merge 和 RG 级 primary switchover。

- **不能确认的时序 / 阈值**
  - 未公开 Raft quorum 的精确配置、leader election timeout、follower catch-up 条件、witness 参与规则的边界参数。
  - 未公开 Region split / merge 的触发阈值、迁移限速、失败回滚和恢复完成判据。
  - 未公开 commit 的 durable ack 点是否严格等于 Raft majority commit，还是抽象成更高层的 TDStore 语义。
  - 未公开故障恢复与重平衡的 SLA / RTO / RPO 数值。

## Checklist Impact

### Architecture Checklist

- **Gate 2. API, Metadata, And Semantics**
  - 这组证据直接确认 authoritative metadata owner 至少分成 MC 路由面与 storage node 上的 Write Fence。
  - Schema 版本、路由缓存失效、stale route reject、Write Fence 校验都属于 metadata 语义边界。
  - 适合回写到 `metadata-ownership-map.md`、`metadata ADR`、`schema version matrix`。

- **Gate 3. Layout, Placement, And Failure Domains**
  - Region 是布局单位，RG 是复制/调度单位，placement 由 key-range routing + RG affinity 共同决定。
  - Region split / merge、primary switchover、node-level expansion 都是布局与故障域联动的机制。
  - 适合回写到 `layout-placement-matrix.md`、`rebalance/recovery architecture note`。

- **Gate 6. Durability, Recovery, And Background Work**
  - Raft log 作为 WAL、节点重启回放、write fence、commit uncertainty、routing retry 都直接影响 durable / visible / recoverable 的定义。
  - 复制协议、数据布局和故障域在 Tencent 文档里是同一层级一起描述的，符合 gate 6 的审查口径。
  - 适合回写到 `durability-recovery-plan.md`、`replication/EC/snapshot ADR`。

- **Gate 8. Operability, Lifecycle, And Exit Strategy**
  - 这组页面至少说明了升级/DDL/路由缓存失效/节点 switchover 的运维语义。
  - 但缺少公开 runbook、版本矩阵、RTO/RPO 和容量回滚条件，因此只能支撑 gate 8 的入口级判断，不能直接写成生产结论。

### Metrics Checklist

- **API semantic correctness**
  - stale route reject、schema version mismatch reject、write RPC 断链策略，都要求把 API 语义测试写成可复现用例。

- **Metadata correctness**
  - 需要验证 owner failover、cache stale、schema migration、mixed-version 行为。
  - 目前只确认了校验路径，没有确认 mixed-version / rollback 的完整行为。

- **Crash / durability correctness**
  - 需要验证 commit 前后 crash、network partition、restart replay、Write Fence 持久化是否满足可恢复语义。

- **Write path latency / Recovery behavior**
  - 事务 path 包含 MC timestamp、routing cache、RG leader 访问、2PC 下沉和 Raft log 持久化，应该拆分成阶段性 latency。
  - Region split / merge 与 retry path 需要单独测尾延迟，因为它们会改变请求分段和重试范围。

## Open Gaps

- 需要补原文中关于 leader election、quorum、follower catch-up、witness 的更底层时序或源码证据，尤其是是否有固定 promotion 规则。
- 需要补 Region split / merge 的触发阈值、迁移速率、限流策略和失败回滚语义。
- 需要补 `primary node switchover` 的完整时序图，确认 RG 迁移是否伴随所有 subordinate Regions 一起切换。
- 需要补 commit durable ack 的更精确边界，尤其是与 Raft commit / apply / visible 的关系。
- 需要补版本锚点：当前核对的是 2026-04-17 / 2026-04-08 的持续更新页，后续若 Tencent 改版，需要重新确认术语、图示和链接路径。
- 需要补一个公开实验或内部复现实验，验证 stale route、Region split、write fence mismatch 和网络断链时的可见行为。

## Evidence Table

| check_item | source | local_ref | evidence_type | evidence_note | design_pressure | confidence | gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Gate 2 - authoritative metadata owner | Tencent TDSQL Boundless `Storage Engine Architecture and Data Model` / `The Lifecycle of an Update SQL` | https://intl.cloud.tencent.com/document/product/1292/78894；https://intl.cloud.tencent.com/document/product/1292/76231；../../domain_knowledge/reference_cards/hyperscaler/index.md:88-102 | mechanism | MC 负责全局 timestamp 和路由表；storage node 用 Write Fence 校验 `<schema_obj_id, schema_obj_version>`；stale route 会被拒绝并触发 refresh + retry。 | 元数据 owner、cache、schema 和失效规则必须显式建模。 | A | 缺 mixed-version / rollback / owner failover 的完整公开时序。 |
| Gate 2 - metadata cache 失效语义 | Tencent TDSQL Boundless `The Lifecycle of an Update SQL` | https://intl.cloud.tencent.com/document/product/1292/76231 | mechanism | 两级 routing cache 先查 shard-bucket cache，再查 global cache，miss 或 stale 才回源 MC。 | 元数据缓存不能只写 TTL，要写 stale 行为和重算规则。 | A | 缺 cache 失效的定量时延和一致性窗口。 |
| Gate 3 - layout unit | Tencent TDSQL Boundless `Storage Engine Architecture and Data Model` | https://cloud.tencent.com/document/product/1376/130340；../checklist-topic-evidence/02-layout-paths.md:19-20 | mechanism | Region 是最小物理存储单位，是连续 Key Range；容量上限 256MB 或 10 万行。 | 布局单位必须与物理边界对齐，不能只写抽象 shard。 | A | 缺 Region 拆分 / 合并触发规则。 |
| Gate 3 - placement / failure domain | Tencent TDSQL Boundless `Storage Engine Architecture and Data Model` / `The Lifecycle of an Update SQL` | https://cloud.tencent.com/document/product/1376/130340；https://intl.cloud.tencent.com/document/product/1292/76231；../checklist-topic-evidence/02-layout-paths.md:20 | mechanism | RG 支持 data affinity scheduling；Region split/merge 和 primary node switchover 都发生在 Region / RG 级。 | placement、复制和故障域必须一体设计。 | A | 缺故障域映射和迁移回滚条件。 |
| Gate 6 - replication roles | Tencent TDSQL Boundless `Storage Engine Architecture and Data Model` | https://cloud.tencent.com/document/product/1376/130340；../checklist-topic-evidence/04-hardware-durability.md:21 | mechanism | RG 是 Raft 物理存储单元；Leader 处理读写，Follower 同步并可选举，Learner 只同步，Witness 参与选举不存数据。 | 复制协议与故障角色必须清晰，否则 failover 会漂移。 | A | 缺 quorum、promotion 和 election timeout。 |
| Gate 6 - durable point / WAL | Tencent TDSQL Boundless `分布式事务与数据亲和性` | https://cloud.tencent.com/document/product/1376/130341 | mechanism | TDStore 直接把 Raft log 当 WAL；节点重启从上一记录点回放；数据刷盘后推进日志点，单一 log 同时服务备机同步和故障恢复。 | durable 点、恢复点和 replay 语义必须写明。 | A | 缺 Raft commit/apply/visible 的公开边界。 |
| Gate 6 - transaction commit / recovery | Tencent TDSQL Boundless `The Lifecycle of an Update SQL` | https://intl.cloud.tencent.com/document/product/1292/76231 | mechanism | commit 网络错误会让客户端处于 uncertain state；写 RPC 网络错误则主动断链；Region split 后扫描重试会拆分剩余范围。 | 事务恢复路径必须覆盖网络错误、路由失效和 split 后重试。 | A | 缺完整的 commit 成功/失败判定与重试窗口。 |
| Gate 6 - DDL / DML version fence | Tencent TDSQL Boundless `The Lifecycle of an Update SQL` | https://intl.cloud.tencent.com/document/product/1292/76231 | mechanism | DDL 提交时同步更新 Data Dictionary 与 storage node Write Fence；DML 在 storage node 侧做版本匹配，不匹配则拒绝。 | schema 演进不能只靠客户端缓存，必须有 storage-side fence。 | A | 缺 fence 在 mixed-version 集群中的边界测试。 |
| Metrics - API semantic correctness | Tencent TDSQL Boundless `The Lifecycle of an Update SQL` | https://intl.cloud.tencent.com/document/product/1292/76231；../../domain-map.md| mechanism | stale route、schema mismatch、write network error 都能转化为 API 语义回归测试。 | 语义测试必须覆盖 retry / reject / stale / uncertain state。 | A | 还没有实际测试报告。 |
| Metrics - Recovery behavior | Tencent TDSQL Boundless `Storage Engine Architecture and Data Model` / `The Lifecycle of an Update SQL` | https://cloud.tencent.com/document/product/1376/130340；https://intl.cloud.tencent.com/document/product/1292/76231；../../domain-map.md| mechanism | 节点重启回放 Raft log、Region split 后重算路由、RG switchover 都是 recovery 行为的一部分。 | 恢复指标需要单列 RTO/RPO、degraded 行为和前台影响。 | A | 缺公开恢复速度和前台 P99 数据。 |

