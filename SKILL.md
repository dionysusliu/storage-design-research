---
name: "storage-project-investigator"
description: "默认使用中文勘探存储项目的架构、代码路径、性能语义、持久化语义和未决风险。Use when the user wants to 调研、摸清、梳理、审计 or reverse-engineer a storage, database, filesystem, object-store, KV, cache, SPDK, io_uring, RDMA, or distributed-storage project before design, refactor, benchmarking, or research planning."
---

# Storage Project Investigator

## 总览

使用这个 skill 对一个存储项目做系统勘探。目标不是复述 README，而是严格按照 `references/domain-map.md` 的架构/指标逻辑，把项目的真实边界、关键路径、代码实现、文档承诺、外部/网络评价、证据强度和未决问题整理成可继续设计、实现或研究的材料。

勘探的核心产物是：`references/domain-map.md` 中每一个 Architecture entry、Metrics entry、Universal Metric 和 Mandatory Artifact 的逐项回答。每个 entry 必须单独写成一篇详查文档，并包含三条证据线：完整代码逻辑、项目文档/注释/配置证据、网络/外部评价。所有调研 artifact 必须集中写入同一个勘探目录。

当 entry 数量较多时，可以使用 subagent 并行处理。主 agent 负责拆分 entry、给每个 subagent 分配清晰边界、合并结果、去重冲突证据、统一证据等级和最终裁决；subagent 只负责自己分配到的 entry，不应自行改写全局结构。并行数量遵守当前运行环境的 subagent 上限，超出时分批执行。

默认使用中文交流、分析和写作 artifact。只有用户明确要求英文或目标项目必须保留英文原文时，才使用英文；英文术语、代码符号、API 名称和原始引用可以保留原文，但解释和结论仍默认中文。

## 工作流

0. 确认 artifact 目录。
1. 定义勘探边界。
2. 加载 `references/domain-map.md`，把它作为本轮调查合同。
3. 建立代码/项目文档/网络评价三线证据索引。
4. 逐项回答 Architecture Checklist 和 Architecture Drift Review。
5. 逐项回答 Metrics Checklist、Universal Metrics 和 Metrics Status。
6. 补齐 Cross-Gate Mandatory Artifacts 与缺口探针。
7. 输出 domain-map 驱动的最终调研报告。

## Step 0: 扫描并确认 artifact 工作区

启动调研时先扫描当前工作区，查找已有的 `research/` 子目录、已有调研目录，以及包含 `00-scope.md`、`01-evidence-index.md`、`final-report.md` 等勘探 artifact 的目录。不要先询问“是否新建”，也不要在确认前写入调研内容。

按扫描结果执行：
- 发现候选目录：列出路径和已有 artifact，询问用户选择哪个作为本次工作区；用户也可以指定其他已有目录。
- 没有发现候选目录：创建 `research/<project-slug>-investigation-YYYYMMDD/` 作为候选目录，然后询问：“工作区中未发现已有调研目录，我已创建 `<path>`；是否将它作为本次调研工作区？”
- 用户确认候选目录：记录为本轮唯一 artifact 工作区，后续所有中间笔记和最终报告都写入这里。
- 用户拒绝候选目录：询问其指定的已有目录；在新目录被确认前，不写任何 artifact，也不在项目根目录散落文件。
- 用户已在初始请求中指定目录：将其作为显式目录输入，但仍先确认该路径可用，不重复询问新建策略。

目录内建议使用这些文件名：
- `00-scope.md`
- `01-evidence-index.md`
- `02-domain-map-contract.md`
- `03-architecture-answers.md`
- `04-metrics-answers.md`
- `05-mandatory-artifacts.md`
- `06-code-path-index.md`
- `07-doc-network-evaluation.md`
- `08-next-probes.md`
- `final-report.md`

并为每个 entry 单独创建详查文档：
- `entries/architecture/<entry-slug>.md`
- `entries/metrics/<entry-slug>.md`
- `entries/universal-metrics/<entry-slug>.md`
- `entries/mandatory-artifacts/<artifact-slug>.md`

汇总文件只保留索引、状态表和跨 entry 裁决；详细解释、代码路径、文档证据、网络评价和探针必须写入对应 entry 文档。

完成标准：扫描动作、候选目录、用户确认结果和最终工作区路径都已记录；如果没有候选目录，必须先创建 `research/<project-slug>-investigation-YYYYMMDD/` 再询问是否采用；用户确认前不得写任何调研 artifact；确认后所有 artifact 都写入该目录，并在最终报告列出 artifact manifest。

## Step 1: 定义勘探边界

先写下本次勘探的范围：
- 项目类型：block、file、object、KV、database engine、distributed database、cache、log、stream 或自定义 extent 系统。
- 目标读者：研究选题、立项评审、代码接手、性能优化、安全审查、重构计划或论文写作。
- 调研深度：文档级、代码级、路径级、实验级。
- 明确排除项：本轮不评价的模块、平台、工作负载或部署形态。
- Artifact 目录：本轮调研写入的位置，以及是否由本次新建。

完成标准：边界中必须包含项目类型、目标读者、深度、排除项和 artifact 目录；如果用户没有给出，基于现有材料做保守假设并标为“待确认”。

## Step 2: 加载 domain-map 调查合同

先读取 `references/domain-map.md`，并把它作为默认调查结构。即使目标项目包含自己的 `design-checklist.md`，也只能作为项目本地输入或补充约束；不能替代本 skill 的 `domain-map.md` 主逻辑，除非用户明确要求。

必须抽取这些部分作为本轮待回答清单：
- `Review Flow`
- `Architecture Checklist`
- `Architecture Drift Review`
- `Metrics Checklist`
- `Universal Metrics`
- `Metrics Status Template`
- `Cross-Gate Mandatory Artifacts`
- `Open Evidence Gaps`

对 `Architecture Checklist` 和 `Metrics Checklist` 的每一行，都要跟随 `详解` 链接读取 `references/domain_knowledge/38-checklist-entry-details.md` 的对应 anchor。不要只复制表格问题；必须理解该 entry 的解释、审查意图、evidence 和 cannot-claim 边界。

完成标准：`02-domain-map-contract.md` 中列出本轮必须回答的全部 Architecture entry、Metrics entry、Universal Metric、Mandatory Artifact，并为每个 entry 指定唯一 slug、详查文档路径、负责 agent、适用性和初始优先级。

## Step 3: 建立三线证据索引

按证据强度收集材料：
- 代码逻辑证据：源码、测试、配置、协议定义、schema、运行脚本、benchmark、trace、profiling、CI、部署脚本。
- 项目文档证据：README、设计文档、架构图、注释、ADR、issue、PR、release note、runbook、配置说明。
- 网络/外部评价：官方外部文档、规范、论文、工程博客、社区 issue、用户报告、benchmark 文章、vendor docs、已抓取网页快照。优先使用 `references/design_evidence/` 内的材料；如果需要最新资料且环境允许联网，按当前工具规则检索并记录访问日期；如果不能联网，标为“需在线核验”。

每条证据标注 `A/B/C/D` 等级，沿用 `references/domain-map.md` 的 `Evidence Levels`。无法从证据确认的结论必须进入“未知/假设/需在线核验”，不能写成事实。

完成标准：`01-evidence-index.md` 中每条高价值结论都能回指到代码文件/符号/测试、项目文档段落、外部 URL/网页快照/规范条目或明确假设；同时能看出该结论属于代码逻辑、项目文档还是网络评价。

## Step 4: 逐项回答 Architecture Checklist

按照 `references/domain-map.md` 的 `Architecture Checklist` 顺序逐项回答，不允许跳过。每个 entry 至少使用这个格式：

- `entry`：Architecture 项名称。
- `status`：`通过` / `需补 ADR` / `触发重审` / `暂不适用`。
- `direct answer`：直接回答该行 `关键问题`。
- `complete code logic`：列出相关模块、入口函数、数据结构、状态机、线程/队列切换、错误路径、配置开关、测试覆盖；对读写路径、持久化、恢复、backpressure、placement 等问题必须追到可解释的代码层。
- `project docs`：列出项目文档、注释、配置说明、issue/PR/release note/runbook 中的承诺和冲突。
- `network/external evaluation`：列出与该 entry 相关的官方规范、论文、厂商文档、社区评价、工程博客、网页快照或在线检索结果；区分机制证据、claim、反例和缺口。
- `required artifacts`：对应 `domain-map.md` 里的必须产物是否存在、是否足够。
- `drift trigger`：是否触发 Architecture Drift Review。
- `confidence`：A/B/C/D。
- `unknowns and probes`：下一步读代码、跑测试、加 trace、联网核验或实验的动作。

每个 Architecture entry 都必须写入 `entries/architecture/<entry-slug>.md`。`03-architecture-answers.md` 只维护总表，包含 entry、详查文档链接、status、confidence、drift trigger、top risk 和 next action。

如果使用 subagent 并行处理，按 entry 或相邻 entry group 分片，例如 metadata/layout、read/write/backpressure、durability/recovery、I/O/hardware、management/operability/claim policy。每个 subagent 的交付物必须是对应 entry 文档草稿和证据索引；主 agent 合并前必须核查路径、证据等级和 cannot-claim 边界。

Architecture pass 必须覆盖：workload、API 语义、metadata、layout/placement、replication/consensus、recovery/rebalance、read path、write path、backpressure、程序化优化、I/O 栈、memory/hardware、hardware lifecycle、durability/consistency、replication/EC/snapshot、background work、management plane、operability lifecycle、claim policy。

完成标准：`entries/architecture/` 中每个 Architecture entry 都有独立详查文档，且每篇文档至少有代码逻辑、项目文档、网络/外部评价三类证据中的明确状态；缺失的证据必须写成缺口，而不是沉默跳过。`03-architecture-answers.md` 能链接到所有 entry 文档。

## Step 5: 逐项回答 Metrics Checklist 和 Universal Metrics

按照 `references/domain-map.md` 的 `Metrics Checklist` 顺序逐项回答，不允许跳过。每个 metric 至少使用这个格式：

- `metric`：指标项名称。
- `architecture link`：对应 Architecture entry 或 ADR。
- `target/current`：目标、当前状态或“未定义”。
- `methodology`：如何测量；工具版本、参数、采样窗口、job file、trace/profiling 方法。
- `code logic under measurement`：该指标实际覆盖哪些代码路径、状态机、队列、后台任务或硬件路径。
- `project docs`：项目如何定义该指标、SLO、测试或发布门槛。
- `network/external evaluation`：外部 benchmark、规范方法学、社区/厂商评价、论文 artifact 或已抓取证据如何评价这个指标。
- `evidence`：raw output、dashboard、trace、test report、runbook drill、或明确缺失。
- `status`：`green` / `yellow` / `red` / `gray`。
- `risk`：当前风险。
- `next_action`：下一周期动作。

每个 Metrics entry 都必须写入 `entries/metrics/<entry-slug>.md`。每个 Universal Metric 都必须写入 `entries/universal-metrics/<entry-slug>.md`。`04-metrics-answers.md` 只维护总表，包含 metric、详查文档链接、architecture link、status、methodology gap、top risk 和 next action。

Universal Metrics 不允许完全跳过。即使项目早期没有数据，也必须给出最低讨论：数据正确性、可用性与恢复、性能与尾延迟、容量效率与写放大、成本与功耗、可运营性、可观测性、安全与隔离、可复现性。

完成标准：`entries/metrics/` 和 `entries/universal-metrics/` 中每个 entry 都有独立详查文档，包含状态、方法学、代码测量路径、项目文档证据、网络/外部评价和下一步动作；没有可复现数据的项必须标 `gray`，不能写成已验证。`04-metrics-answers.md` 能链接到所有 entry 文档。

## Step 6: 补齐 Mandatory Artifacts 与缺口探针

使用 `references/domain-map.md` 的 `Cross-Gate Mandatory Artifacts` 作为产物清单。对每个 artifact 判断：

- 已存在且足够。
- 已存在但证据不足。
- 不存在，需要新建草案。
- 暂不适用，并说明重新启用条件。

Mandatory artifacts 包括但不限于：`workload-matrix.md`、`api-semantics-contract.md`、`metadata-ownership-map.md`、`layout-placement-matrix.md`、`read-path-sequence.md`、`write-path-sequence.md`、`queue-backpressure-budget.md`、`optimization-adr.md`、`io-stack-adr.md`、`memory-hardware-contract.md`、`hardware-lifecycle-matrix.md`、`durability-recovery-plan.md`、`management-plane-contract.md`、`observability-benchmark-artifact.md`、`operability-lifecycle-runbook.md`。

每个 Mandatory Artifact 也必须有独立详查文档：`entries/mandatory-artifacts/<artifact-slug>.md`。该文档说明 artifact 是否已存在、是否足够、缺哪些代码/文档/外部证据、是否需要新建草案，以及它覆盖哪些 Architecture/Metrics entry。

对每个缺口写一个可执行探针，必须说明：
- 读哪些代码文件/符号。
- 查哪些项目文档或历史 issue/PR。
- 查哪些外部文档、网页快照或在线来源。
- 跑哪些测试、benchmark、fault injection、trace、profile 或 size/QD/failure sweep。
- 完成后能把哪个 `domain-map.md` entry 从 gray/yellow 推到 green，或从 `需补 ADR` 推到 `通过`。

完成标准：`entries/mandatory-artifacts/` 中每个 mandatory artifact 都有独立详查文档；`05-mandatory-artifacts.md` 链接并汇总 `Cross-Gate Mandatory Artifacts` 每一行；`08-next-probes.md` 中的探针能明确补哪一项 Architecture/Metrics/Universal Metric 的证据。

## Step 7: 输出调研报告

使用 `references/output-contract.md`。报告必须区分事实、推断、假设和缺口。

最后给出：
- Architecture Checklist 总表：每项状态、证据等级、主要风险。
- Metrics Checklist 总表：每项 green/yellow/red/gray、方法学状态、主要缺口。
- Universal Metrics 总表：最低讨论是否完成。
- Mandatory Artifacts manifest：存在/不足/需新建/暂不适用。
- Entry document manifest：所有 `entries/**/<slug>.md` 的链接、负责人、状态和最后更新时间。
- 最重要的 5-10 个已确认事实，必须能回指到代码、项目文档或外部证据。
- 最危险的 5-10 个未知或风险，说明触发的 architecture drift 或 claim 降级。
- 下一步 3-7 个调查动作，按信息增益排序。

完成标准：读者不需要重新翻完整仓库，也能从 final report 跳转到 `domain-map.md` 中每一个问题的独立详查文档，并看到完整代码逻辑、项目文档证据、网络/外部评价和下一步探针。

## Entry 详查文档模板

每篇 `entries/**/<slug>.md` 都使用同一结构：

- `Entry`：原始 checklist entry 名称、所属 section、`domain-map.md` 行/anchor、详解 anchor。
- `Question`：原始关键问题，以及本项目中的具体化问题。
- `Verdict`：当前裁决、证据等级、适用性、是否触发架构重审或指标红旗。
- `Complete Code Logic`：完整代码逻辑。列模块、文件、函数、数据结构、状态机、线程/队列、配置、错误路径、测试；必要时给出调用链或状态转换。
- `Project Documents`：README、设计文档、注释、配置、issue/PR、release note、runbook 中的证据和冲突。
- `Network / External Evaluation`：官方规范、论文、厂商文档、社区评价、工程博客、网页快照、在线检索结果；标注机制证据、claim、反例、缺口和访问日期。
- `Evidence Table`：按 `source / location / evidence_type / confidence / claim_supported / limitation` 记录。
- `Cannot Claim`：根据 `38-checklist-entry-details.md` 和本轮证据列出不能宣称的内容。
- `Gaps`：代码缺口、文档缺口、外部证据缺口、实验缺口。
- `Next Probes`：下一步可执行探针，写清读哪个文件、问哪个符号、跑哪个测试、抓哪个外部材料。

## 参考加载

只加载本轮需要的材料：

当前 `references/` 结构是稳定材料库，不保存研究过程稿：
- `references/domain-map.md`：主调查合同。每轮勘探都必须从这里选择并逐项回答架构轴、指标轴、通用指标和 mandatory artifacts；外部检查表只能作为补充输入。
- `references/domain_knowledge/38-checklist-entry-details.md`：主检查表每个 entry 的逐项详解。文件较长，优先按 `domain-map.md` 中的 anchor 定位读取，不要整篇加载，除非用户要求全量审阅。
- `references/domain_knowledge/source-inventory.md`：来源清单和材料状态。用于判断某类来源是否已覆盖、是否有缺口。
- `references/domain_knowledge/download-gaps.md`：下载失败、弱证据或不可强声明的来源。用于避免把未抓取材料写成已验证事实。
- `references/domain_knowledge/reference_cards/{kernel,hardware,enterprise,hyperscaler,opensource,community}/index.md`：按来源类型整理的参考卡。需要快速了解某类团队、社区、厂商或硬件材料时读取对应卡片。
- `references/design_evidence/checklist-topic-evidence/`：按 checklist 主题聚合的 evidence table；先读 `README.md`，再选择 `01-goals-metadata.md` 到 `06-observability-benchmark-cost.md` 中的主题文件。
- `references/design_evidence/source-document-evidence/`：按具体来源文档聚合的机制证据；先读 `README.md` 看 Ceph、fio、FoundationDB、RocksDB、Tencent、CXL/Optane、SNIA Swordfish、HPE、DPDK 等文档覆盖范围，再进入单个文件。
- `references/design_evidence/web-snapshots/`：已抓取网页快照。只在 evidence 文件指向快照、需要核对原文片段、或用户要求追溯网页内容时读取。
- `references/output-contract.md`：最终报告结构和缺口表格式。
- `references/source-strategy.md`：当代码、文档、论文、博客或厂商材料混杂时，用于判定证据优先级。

不要寻找 `00-*.md` 到 `37-*.md` 一类中间文档；这些过程稿不属于当前 skill 的参考接口。

## License

Copyright (c) 2026 Chuang Liu <dionysusliu815@qq.com>.

This skill is licensed under CC BY 4.0. Commercial use is permitted, attribution is required, and copyright remains with the copyright holder. See `LICENSE`.
