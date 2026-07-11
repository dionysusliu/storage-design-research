# Ceph recovery/backfill 证据卡

生成时间：2026-07-11

> 说明：以下证据优先采用 Ceph 官方文档、配置参考和 troubleshooting/runbook。当前抓取到的官方页主要位于 `en/latest`，页面本身明确标注为 development version，因此凡是涉及默认值、行为边界或运维命令的结论，都保留了版本差异 gap。

## Source Inventory

| 来源 | 来源类型 | 证据等级 | 已抓取正文 | 备注 |
| --- | --- | --- | --- | --- |
| https://docs.ceph.com/en/latest/rados/operations/pg-states/ | Ceph 官方文档，PG 状态定义 | A | 是 | 给出 `active+clean`、`degraded`、`recovering`、`backfilling`、`backfill_wait`、`recovery_wait`、`backfill_toofull` 等状态定义。 |
| https://docs.ceph.com/en/latest/rados/operations/health-checks/ | Ceph 官方文档，健康检查与 flags | A | 是 | 给出 `OSD_BACKFILLFULL`、`OSD_FULL`、`OSDMAP_FLAGS`，并明确 `nobackfill` / `norecover` / `norebalance` / `noscrub` / `nodeep_scrub` 的含义。 |
| https://docs.ceph.com/en/latest/rados/configuration/osd-config-ref/ | Ceph 官方配置参考 | A | 是 | 给出 `osd_max_backfills`、`osd_recovery_max_active`、`osd_backfill_scan_min/max`、`osd_backfill_retry_interval`、`osd_recovery_sleep*` 等限流 knob。 |
| https://docs.ceph.com/en/latest/rados/operations/placement-groups/ | Ceph 官方文档，PG / autoscaling / rebalance | A | 是 | 说明 PG 是 Ceph pool 的内部粒度，`pg_autoscale_mode`、`mon_target_pg_per_osd` 与小规模 backfill 的关系。 |
| https://docs.ceph.com/en/latest/rados/troubleshooting/troubleshooting-osd/ | Ceph 官方 troubleshooting/runbook | A | 是 | 给出维护时 `noout`、OSD down/out、日志、`ceph osd lost`、故障域注意事项等运维路径。 |
| https://docs.ceph.com/en/latest/rados/troubleshooting/troubleshooting-pg/ | Ceph 官方 troubleshooting/runbook | A | 是 | 给出 `ceph pg query`、`ceph pg repair`、`unfound`、`active+degraded` 的处理路径。 |
| https://docs.ceph.com/en/latest/releases/ | Ceph 官方 release index | A | 是 | 明确当前 active release trains 为 Tentacle `20.2.*`、Squid `19.2.*`、Reef `18.2.*`。 |
| ../../domain_knowledge/reference_cards/opensource/index.md | 本地参考卡，Ceph 架构摘要 | B | 是 | 作为本地 baseline，确认 Ceph 的 CRUSH / PG / cluster map / BlueStore / latest 轨道等背景。 |
| ../checklist-topic-evidence/05-background-recovery.md | 本地证据卡，后台恢复总纲 | B | 是 | 已把 Ceph 列为 source-document 补证项，但原卡仅停留在 recovery/backfill 缺口，没有机制细节。 |
| ../../domain-map.md | 本地 checklist 草案 | B | 是 | Gate 3 / 6 / 8 的问题定义与 source-document 补证队列，为本卡提供映射目标。 |

## Mechanism Notes

- Ceph 的数据组织单位是 PG。`Placement Group States` 页面明确说，PG 的最佳状态是 `active+clean`，而 Ceph 在 PG 粒度上管理数据，优于逐对象管理。
- `recovery` 是 OSD 重启、崩溃后重新加入，或同一故障域内多个 OSD 恢复上线时，为把对象与副本同步到最新状态所做的同步过程。官方配置页把它描述成 peering 完成后进入 recovery mode，去追赶最新 copy。
- `backfill` 是 recovery 的特殊情况。Ceph 在 add/remove OSD、CRUSH rebalance 时，会通过 backfill 移动 PG 和对象；它不会只看最近操作日志，而是扫描并同步整个 PG 的内容。
- 状态层面，`recovering` 表示对象与副本正在迁移/同步；`backfilling` 表示整 PG 扫描同步；`recovery_wait` / `backfill_wait` 表示排队等待资源或阈值；`recovery_toofull` / `backfill_toofull` 表示目标 OSD 太满。
- `degraded` 表示 PG 里还有对象没达到正确副本数。`undersized`、`peered`、`incomplete`、`unfound` 进一步区分了还能不能继续服务 I/O。
- degraded read/write 不能粗暴写成“必然停机”。官方 PG troubleshooting 明确给出 `active+degraded` 场景；当对象仍有可用副本且满足 `min_size` 时，I/O 可能继续，但如果进入 `unfound`，I/O 会阻塞而不是直接报错。
- `scrubbing` / `deep` scrub 与 recovery/backfill 是不同机制：scrub 检查 PG 元数据一致性，deep scrub 再拿数据和 checksum 对照。它们不是对象重建路径本身。
- scrub 需要单独治理。PG states 页面把 `scrubbing` / `deep` scrub 作为独立状态，health checks 页面又明确提供 `noscrub` 和 `nodeep_scrub` flags；这说明 scrub 不是 recovery/backfill 的同义词。至于不同 release train 下具体何时触发 scrub，这里不做版本级绝对断言。
- Ceph 的 rebalance 不是独立于 backfill 的另一条数据迁移机制。官方配置页直接把 backfill 定义为 CRUSH 重新平衡时移动 PG 的方式，因此故障恢复、扩容、缩容、故障域维护都要把 backfill 流量预算纳入。
- 常见 throttling/config knobs：
  - `osd_max_backfills`：单个 OSD 允许的 backfill 数量上限，读/写分别计数，默认 1。
  - `osd_recovery_max_active`：单 OSD 同时活跃的 recovery 请求数；默认值为 0，通常转而使用 HDD/SSD 分支值。
  - `osd_recovery_max_active_hdd` / `osd_recovery_max_active_ssd`：旋转盘默认 3、SSD 默认 10。
  - `osd_recovery_max_chunk`：单次 recovery op 携带的数据块总量上限，默认 8Mi。
  - `osd_recovery_max_single_start`：处于 recovery 时可新启动的 recovery op 数量上限，默认 1。
  - `osd_recovery_sleep` / `osd_recovery_sleep_hdd` / `osd_recovery_sleep_ssd` / `osd_recovery_sleep_hybrid` / `osd_recovery_sleep_degraded*`：通过在下一次 recovery/backfill 前 sleep 降低前台冲击。
  - `osd_backfill_scan_min` / `osd_backfill_scan_max`：backfill 每次 scan 的对象数下限/上限，默认 64 / 512。
  - `osd_backfill_retry_interval`：backfill 重试间隔，默认 30s。
- mClock 是一个重要分界线。官方配置页多次说明：当 mClock scheduler 启用时，部分 recovery/backfill 相关设置会被自动 reset 或忽略，包括 `osd_max_backfills`、`osd_recovery_max_active*`、`osd_recovery_sleep*`。这意味着运维 runbook 不能把这些 legacy knob 当成在所有集群上都生效的绝对真值。
- 故障与容量阈值也直接决定 recovery/backfill 能否推进：`OSD_BACKFILLFULL` 表示目标 OSD 已到 `backfillfull`，会阻止数据再平衡过去；`OSD_FULL` 则会阻止集群继续写入。
- 维护与降级 runbook 需要放在 failure domain 语义里看。Ceph troubleshooting 明确建议先看 monitors quorum 和网络，再看 OSD；维护期间可设置 `noout` 防止自动 rebalance，并在维护结束后恢复 flags。

## Checklist Impact

### Gate 3. Layout, Placement, And Failure Domains

- Ceph 证明 placement 不是“对象随便落盘”，而是 `pool -> PG -> OSD`，并由 CRUSH 与 failure domain 一起决定落点。
- 对 Gate 3 的直接加强点是把 `PG`、`CRUSH bucket`、`OSD down/out`、`backfill` 和 `noout` 维护窗口写进 placement/failure-domain matrix，而不是只画静态拓扑图。
- 由于 backfill 伴随 rebalance，Gate 3 还必须要求“扩容/缩容/故障域隔离时的迁移单位、限速和回滚条件”。

### Gate 6. Durability, Recovery, And Background Work

- Ceph 把 recovery/backfill 明确列为后台工作，而且这些后台工作会与前台读写竞争资源。
- 因此 Gate 6 的 `background throttle policy` 不能只写“有个限流参数”，必须区分 legacy knob 与 mClock 两条控制面，并记录哪些参数在 mClock 下会失效。
- Gate 6 还应把 `degraded read/write`、`recovery_wait`、`backfill_wait`、`recovery_toofull`、`backfill_toofull` 这些状态变成可观测告警和压测场景。
- scrub 需要单列，因为它与 recovery/backfill 共享 OSD 资源但语义不同；否则“修复一致性”和“恢复可用副本”会被混成一条路径，runbook 会失真。

### Gate 8. Operability, Cost, Lifecycle, And Exit Strategy

- Ceph 的官方 troubleshooting 已经给出运维主路径：先判断 mon quorum / 网络，再看 OSD，再看 PG query / repair / lost。
- Gate 8 需要把这些命令整理成 degraded mode runbook，并补上“何时允许 `noout`、何时必须解除、何时应该手工 stop 失效 OSD 以让恢复继续”的判断规则。
- 由于 backfillfull / full 会直接阻断再平衡或写入，Gate 8 还应要求容量告警与恢复策略一起设计，而不是只在容量尽头再补扩容动作。
- 版本生命周期要明确写进运维文档：当前抓取的是 `latest` development docs，实际生产若落在 Tentacle / Squid / Reef，必须复核对应 release train 的 config 默认值和 troubleshooting 文案。

## Open Gaps

- 需要补一版按具体 release train 约束的文档映射，至少确认 Tentacle / Squid / Reef 上 `osd_max_backfills`、`osd_recovery_max_active*`、`osd_recovery_sleep*` 的默认值和 mClock 行为是否一致。
- 需要补 Ceph 源码级验证，优先确认 config schema 与 OSD op queue / mClock 的实际实现路径，而不是只靠 generated docs。
- 需要补一个小型实验或生产复现：在 `active+degraded`、`backfill_wait`、`backfillfull` 和 mClock 开启/关闭两种模式下，对前台 P99 和恢复速率做对照。
- 需要补 `scrub` 与 `recovery/backfill` 的相互干扰实验，尤其是 degraded PG、deep scrub、auto repair 与后台恢复同时出现时的尾延迟。
- 需要补 erasure-coded pool 的专门 runbook，重点是 `min_size`、`unfound` 和暂时放宽恢复条件的风险边界。

## Evidence Table

| check_item | source | local_ref | evidence_type | evidence_note | design_pressure | confidence | gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Gate 3.1 布局单位与 PG 粒度 | https://docs.ceph.com/en/latest/rados/operations/placement-groups/；https://docs.ceph.com/en/latest/rados/operations/pg-states/ | ../../domain_knowledge/reference_cards/opensource/index.md；../../domain-map.md | mechanism | PG 是 Ceph 内部数据管理粒度；最佳状态是 `active+clean`。对象先映射到 PG，再由 PG 进入 OSD 级 placement。 | 布局不能只抽象成“对象落盘”，必须明确到 PG / OSD 粒度。 | A | 仍缺项目自己的 pg_num 预算与对象/PG 映射参数。 |
| Gate 3.2 placement 与 failure domain | https://docs.ceph.com/en/latest/rados/troubleshooting/troubleshooting-osd/；https://docs.ceph.com/en/latest/rados/operations/pg-states/ | ../checklist-topic-evidence/05-background-recovery.md；../../domain-map.md | runbook / mechanism | 维护时可用 `noout` 阻止 rebalance；停止 OSD 后 PG 会进入 `degraded`；`recovery` 依赖 failure domain 语义。 | 维护、故障和扩容必须按 rack/host/OSD 故障域做规划。 | A | 仍缺本项目 failure-domain 级维护演练记录。 |
| Gate 6.1 recovery/backfill 机制 | https://docs.ceph.com/en/latest/rados/operations/pg-states/；https://docs.ceph.com/en/latest/rados/configuration/osd-config-ref/ | ../checklist-topic-evidence/05-background-recovery.md | mechanism | `recovering` 是对象同步，`backfilling` 是扫描整个 PG 的特殊 recovery；CRUSH rebalance 时通过 backfill 迁移 PG/对象。 | 后台恢复流量不是附属流量，必须进入前台 SLO 和资源预算。 | A | 仍缺真实集群上恢复速率与前台尾延迟的定量曲线。 |
| Gate 6.2 throttling knobs | https://docs.ceph.com/en/latest/rados/configuration/osd-config-ref/ | ../../domain-map.md | config | `osd_max_backfills`、`osd_recovery_max_active*`、`osd_recovery_max_chunk`、`osd_recovery_sleep*`、`osd_backfill_scan_*`、`osd_backfill_retry_interval` 提供多层限流。 | throttle 必须分层：单 OSD 并发、chunk 大小、scan 粒度、sleep、重试间隔。 | A | 需要确认当前生产版本是否启用 mClock，避免误配被自动 reset。 |
| Gate 6.3 scrub 与 recovery 的关系 | https://docs.ceph.com/en/latest/rados/operations/pg-states/；https://docs.ceph.com/en/latest/rados/operations/health-checks/ | ../checklist-topic-evidence/05-background-recovery.md | mechanism / warning | scrub 检查 PG 元数据和数据 checksum；`noscrub` / `nodeep_scrub` 是独立 flags，不应与 recovery/backfill 混写。 | 一致性检查与副本重建共享资源，必须分开治理。 | A | 仍缺 scrub 与 backfill 同时运行的压测数据。 |
| Gate 6.4 full / backfillfull 阈值 | https://docs.ceph.com/en/latest/rados/operations/health-checks/；https://docs.ceph.com/en/latest/rados/operations/pg-states/ | ../../domain-map.md | warning | `backfill_toofull` / `OSD_BACKFILLFULL` 会阻止数据再平衡；`full` 会阻止写入；`recovery_toofull` / `backfill_toofull` 把容量阈值直接变成恢复阻塞点。 | 容量水位必须和恢复策略联动，否则恢复本身会被容量门槛卡死。 | A | 仍缺本项目容量阈值与告警阈值的实测对应关系。 |
| Gate 8.1 degraded mode runbook | https://docs.ceph.com/en/latest/rados/troubleshooting/troubleshooting-osd/；https://docs.ceph.com/en/latest/rados/troubleshooting/troubleshooting-pg/ | ../checklist-topic-evidence/05-background-recovery.md | runbook | 官方路径包括 `ceph pg query`、`ceph pg repair`、`ceph osd lost`、`ceph osd out`、`noout`、日志和网络检查。 | 运维文档必须能把“读写降级但可继续服务”与“必须阻断/修复”分清。 | A | 仍缺把命令编成可执行 runbook 的本地化版本。 |
| Gate 8.2 版本边界与生命周期 | https://docs.ceph.com/en/latest/releases/；https://docs.ceph.com/en/latest/rados/operations/health-checks/ | ../../domain-map.md | boundary | 当前文档是 development version；active release trains 为 Tentacle 20.2.*、Squid 19.2.*、Reef 18.2.*。 | 不能把 `latest` 行为直接写成生产事实，必须带版本锚点。 | A | 仍缺按目标 release train 的逐项复核。 |
