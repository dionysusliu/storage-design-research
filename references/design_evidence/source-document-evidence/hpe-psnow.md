# HPE PSNow / Alletra / Nimble 证据补齐

生成时间：2026-07-11 18:22:04 CST

说明：
- 本卡只记录 HPE 官方 PSNow / support 页能确认到的内容，不把标题页、登录门面页、或本地分析标签当作正文证据。
- 证据等级定义：
  - `A`：已抓取正文，且机制可直接回写 checklist。
  - `B`：已抓取正文，但版本/时间/边界仍需补核。
  - `C`：只拿到标题、目录或 landing page，不能写强机制事实。
  - `D`：正文抓取失败或不可用，只能保留为 gap。

## Source Inventory

| 官方 URL | 本地路径 | 来源类型 | 证据等级 | 已抓取正文 | 生命周期状态 | 抓取状态 / 备注 |
| --- | --- | --- | --- | --- | --- | --- |
| https://support.hpe.com/hpesc/public/docDisplay?docId=sf000108575en_us&docLocale=en_US | `../web-snapshots/batch-07/raw/148ca9aeeed9338b.html` | support landing page / docDisplay 门面页 | C | 否 | 当前 | 页面能确认标题是 `HPE Alletra Storage MP overview`，但实际正文被 HPE auth gate 挡住。 |
| https://www.hpe.com/psnow/doc/a50002410enw | `../web-snapshots/batch-08/results.tsv` | PSNow 架构 PDF 门面页 | C | 否 | 待核实 | 标题可确认是 `HPE Nimble Storage, HPE Alletra 5000, and HPE Alletra 6000 storage architecture`，但下载正文失败。 |
| https://www.hpe.com/psnow/doc/a00072117enw | `../web-snapshots/batch-09/results.tsv` + `../../domain_knowledge/reference_cards/enterprise/index.md` | PSNow 架构 PDF 门面页 | C | 否 | 待核实 | 标题可确认是 `HPE Nimble Storage and HPE Alletra 5000/6000 controller failover and architecture`，但正文未取到。 |
| https://www.hpe.com/psnow/downloadDoc/Transitioning%20from%20HPE%20Nimble%20Storage%20and%20HPE%20Alletra%2050006000%20to%20HPE%20Alletra%20Storage%20MP%20B10000-a00138873enw.pdf | `../../domain_knowledge/source-inventory.md` + `../../domain_knowledge/reference_cards/enterprise/index.md` | PSNow 技术白皮书 canonical PDF URL | D | 否 | 历史 | 只确认到过渡主题与 PDF 直链；正文抓取失败，版本与发布日期未核验。 |

## Mechanism Notes

### 1) controller failover
- 当前只能确认 HPE 有一份专门围绕 `controller failover and architecture` 的 PSNow 文档。
- 由于 PDF 正文没有抓到，不能确认 failover 是 `active-active`、`active-standby`，还是混合模式。
- 也不能确认切换触发条件、路径重选顺序、I/O 中断窗口、RTO/RPO、性能降级幅度或重建行为。

### 2) Alletra / Nimble architecture
- `HPE Nimble Storage, HPE Alletra 5000, and HPE Alletra 6000 storage architecture` 说明这份文档确实覆盖 Nimble 到 Alletra 5000/6000 的架构关系。
- 但目前只有标题级证据，不能把它直接写成 controller ownership、数据布局、协议栈或 control-plane 机制事实。
- support 页 `HPE Alletra Storage MP overview` 只证明有一个 MP 入口页；正文缺失，所以不能把它当成 MP 架构规格书。

### 3) Alletra MP B10000 transition / migration
- `Transitioning from HPE Nimble Storage and HPE Alletra 5000/6000 to HPE Alletra Storage MP B10000` 说明 HPE 确实发布了从旧平台到 MP B10000 的过渡材料。
- 但正文未取到，因此不能确认是否支持在线迁移、是否有停机窗口、是否允许双写/双活过渡、以及是否有兼容矩阵。
- 现阶段只能把它当作“存在迁移主题”的证据，不能把迁移步骤写成事实。

### 4) upgrade / rollback
- 当前四个 HPE 目标里，没有任何一个拿到可核验的升级/回滚正文。
- 所以不能写 HPE 对 upgrade path、rollback条件、mixed-version 窗口、release train 的具体承诺。
- 若后续补到 PDF 正文，这一块才可能上升为 `versioned degraded runbook` 级别证据。

### 5) failure behavior
- 失败行为目前只有“文档主题存在”的证据，没有可验证的 failover 时序、容量水位、降级读写、重建限流、或错误传播语义。
- 这意味着所有 failure behavior 只能暂列 gap，不能回写成强机制事实。

### 6) 本地索引标签，仅作分析提示，不当作 HPE 正文
- `../../domain_knowledge/reference_cards/enterprise/index.md` 和 `../../domain_knowledge/source-inventory.md` 里的本地分析标签把 overview 归成 `active-active` / `FC` / `NVMe-oF` / `iSCSI`，把 transition paper 归成 `active-standby` / `all-active` / 独立扩缩容。
- 这些只是本地分析标签，不是 HPE 正文，因此只能作为后续下钻线索，不能直接写进 checklist 作为已证实事实。

## Checklist Impact

### Architecture Checklist
- `Placement 与 failure domain`：controller failover 文档如果补齐正文，才能判断故障域、切换粒度与冗余模型。
- `Recovery/backfill/rebalance architecture`：transition paper 若补到正文，才可能确认旧平台到 MP B10000 的迁移单位、触发条件、容量水位与维护 flag。
- `Operability lifecycle`：当前没有可核验的 upgrade / rollback / version train 正文，所以这项只能保留为未闭合风险。
- `Claim policy`：HPE 的可用性、故障切换、迁移和升级 claims 不能从标题页直接提升为 A/B 级证据。

### Metrics Checklist
- `Recovery behavior`：缺 RTO/RPO、degraded read/write、rebuild/backfill speed、foreground impact 的正文证据。
- `Operability`：缺升级、回滚、混合版本和恢复演练的官方 runbook，无法做版本化 degraded runbook 验证。
- `Version/lifecycle status`：PDF 没有公开版本号/发布日期，当前无法把这些文档绑定到 release train。
- `Benchmark / claim policy`：没有正文就不能把 HPE 的宣传语当成可复现指标；后续必须补实验或官方运行手册。

## Open Gaps

- 需要可访问的 HPE PDF 正文：`a00072117enw`、`a50002410enw`、`a00138873enw`。
- 需要补版本、发布日期、release train，最好来自官方 PDF 封面、文档元数据或 support runbook。
- 需要官方 runbook 或 KB：upgrade、rollback、degraded mode、failure matrix、迁移窗口。
- 需要确认 `active-active` / `active-standby` / `all-active` 这些形态到底是正文结论，还是仅仅是本地分析标签。
- 若 HPE 站点继续只给 gate 页，下一步只能找官方镜像、PDF 备份或可验证的 support KB 衍生页。

## Evidence Table

| check_item | source | local_ref | evidence_type | evidence_note | design_pressure | confidence | gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| controller failover | `HPE Nimble Storage and HPE Alletra 5000/6000 controller failover and architecture` | `../web-snapshots/batch-09/results.tsv`；`../../domain_knowledge/reference_cards/enterprise/index.md` | title-only | 只能确认 HPE 有一份专门讲 controller failover 的文档，正文未取到。 | 不能把 failover 拓扑、切换顺序、RTO/RPO、性能退化当成已证实事实。 | D | 需要 PDF 正文或官方镜像。 |
| active-active / active-standby 形态 | 本地分析标签（非 HPE 正文） | `../../domain_knowledge/reference_cards/enterprise/index.md`；`../../domain_knowledge/source-inventory.md` | local-inference | 内部索引把 overview 标成 `active-active`，把 transition paper 标成 `active-standby` / `all-active`；这是分析线索，不是正文证据。 | checklist 上必须区分“标题/标签”与“可核验机制”；否则 claim policy 会被污染。 | D | 需要 HPE 正文验证。 |
| Alletra / Nimble architecture | `HPE Nimble Storage, HPE Alletra 5000, and HPE Alletra 6000 storage architecture` | `../web-snapshots/batch-08/results.tsv`；`../../domain_knowledge/source-inventory.md` | title-only | 只能确认架构主题与产品代际，不能确认具体数据面或控制面机制。 | 需要给 `Architecture Checklist` 提供可回写的架构边界，而不是标题级概括。 | D | 需要 PDF 正文。 |
| migration / transition | `Transitioning from HPE Nimble Storage and HPE Alletra 5000/6000 to HPE Alletra Storage MP B10000` | `../../domain_knowledge/source-inventory.md`；`../../domain_knowledge/reference_cards/enterprise/index.md` | title-only | 只能确认存在代际迁移主题，不能确认在线迁移、兼容矩阵、停机窗口或回滚条件。 | `operability lifecycle` 和 `versioned degraded runbook` 不能建立在标题级材料上。 | D | 需要正文、版本和官方 runbook。 |
| upgrade / rollback | 同上四个 HPE 目标 | `../../domain_knowledge/reference_cards/enterprise/index.md` | gap | 当前没有任何可核验正文能说明升级与回滚语义。 | `Operability lifecycle` 必须依赖版本化 runbook；当前无法写入 checklist。 | D | 需要升级 / 回滚 / mixed-version 官方正文。 |
| failure behavior | 同上四个 HPE 目标 | `../../domain_knowledge/download-gaps.md`；`../../domain_knowledge/reference_cards/enterprise/index.md` | gap | 只有 landing page / 下载入口 / 抓取失败记录，没有 failover 时序、降级读写、rebuild 或错误传播正文。 | `Recovery behavior` 相关指标暂时不能设为已验证。 | D | 需要 failure matrix、degraded benchmark 或官方 runbook。 |

## Reusable Takeaway

- 现在能确定的只有：HPE 确实有 controller failover、architecture、transition 这几份官方 PSNow 材料，但它们在当前环境里都还没有拿到可核验正文。
- 所以这批材料目前只能支撑 `gap` 和 `title-only` 级别记录，不能支撑 `active-active`、`active-standby`、`升级回滚语义` 或 `failure behavior` 的强结论。
