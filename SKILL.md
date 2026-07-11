---
name: "storage-project-investigator"
description: "勘探存储项目的架构、代码路径、性能语义、持久化语义和未决风险。Use when the user wants to 调研、摸清、梳理、审计 or reverse-engineer a storage, database, filesystem, object-store, KV, cache, SPDK, io_uring, RDMA, or distributed-storage project before design, refactor, benchmarking, or research planning."
---

# Storage Project Investigator

## 总览

使用这个 skill 对一个存储项目做系统勘探。目标不是复述 README，而是把项目的真实边界、关键路径、证据强度和未决问题整理成可继续设计、实现或研究的材料。

勘探的核心产物是：项目地图、读写路径、状态与持久化语义、队列和资源模型、风险缺口、下一步调查清单。所有调研 artifact 必须集中写入同一个勘探目录。

## 工作流

0. 确认 artifact 目录。
1. 定义勘探边界。
2. 建立证据索引。
3. 画系统地图。
4. 追踪关键路径。
5. 盘点状态、故障和后台任务。
6. 用存储设计域做缺口标注。
7. 输出调研报告和下一步探针。

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
- `02-system-map.md`
- `03-read-write-paths.md`
- `04-state-failure-background.md`
- `05-domain-gap-map.md`
- `06-next-probes.md`
- `final-report.md`

完成标准：扫描动作、候选目录、用户确认结果和最终工作区路径都已记录；如果没有候选目录，必须先创建 `research/<project-slug>-investigation-YYYYMMDD/` 再询问是否采用；用户确认前不得写任何调研 artifact；确认后所有 artifact 都写入该目录，并在最终报告列出 artifact manifest。

## Step 1: 定义勘探边界

先写下本次勘探的范围：
- 项目类型：block、file、object、KV、database engine、distributed database、cache、log、stream 或自定义 extent 系统。
- 目标读者：研究选题、立项评审、代码接手、性能优化、安全审查、重构计划或论文写作。
- 调研深度：文档级、代码级、路径级、实验级。
- 明确排除项：本轮不评价的模块、平台、工作负载或部署形态。
- Artifact 目录：本轮调研写入的位置，以及是否由本次新建。

完成标准：边界中必须包含项目类型、目标读者、深度、排除项和 artifact 目录；如果用户没有给出，基于现有材料做保守假设并标为“待确认”。

## Step 2: 建立证据索引

按证据强度收集材料：
- 强证据：代码、测试、配置、协议定义、运行脚本、benchmark、trace、设计文档。
- 中证据：README、架构图、注释、issue、PR、release note。
- 弱证据：博客、宣传页、二手总结、命名推断。

为每条关键结论记录来源位置。无法从证据确认的结论必须进入“未知/假设”，不能写成事实。

完成标准：报告中每个高价值结论都能回指到文件、符号、文档段落、命令输出或明确假设。

## Step 3: 画系统地图

至少识别这些表面：
- 对外 API 和客户端交互方式。
- control plane、metadata plane、data plane 的边界。
- 本地状态、复制状态、派生状态和缓存状态。
- 进程、线程、reactor、协程、worker pool、device queue、network queue。
- 数据布局、命名空间、分片、placement、复制或 EC。
- 观测面：metrics、logs、traces、profiles、admin RPC。

完成标准：能用一段文字或图说明一次请求会经过哪些主要模块，以及哪个模块拥有权威状态。

## Step 4: 追踪关键路径

优先追踪：
- 一次 point read 或小读。
- 一次小写，以及客户端收到成功时数据到达的位置。
- 一次大 I/O 或 scan。
- 一次元数据操作。
- 一次慢路径：flush、GC、compaction、rebuild、recovery、rebalance、scrub、snapshot/install。

每条路径记录：入口、线程/队列切换、内存复制、日志/复制/持久化点、completion 点、错误和取消路径。

完成标准：至少一条读路径和一条写路径被追到可解释 ack/visibility/durability 的程度；如果代码不足，列出阻塞的缺失证据。

## Step 5: 盘点状态、故障和后台任务

回答：
- 谁拥有权威状态，谁只是缓存或副本？
- crash、restart、timeout、retry、cancel、network partition、device failure 后如何收敛？
- WAL、journal、manifest、metadata、placement、lease、membership 的提交顺序是什么？
- 后台任务如何限流，是否和前台共享队列、线程、CPU、网络或设备？
- degraded mode 下读写语义、可用性和性能有什么变化？

完成标准：每类状态至少被归入“权威/副本/缓存/派生/未知”之一；每个影响持久化或可见性的后台任务都有风险标注。

## Step 6: 做缺口标注

如果当前项目包含 `design-checklist.md`，或用户提供了类似存储设计检查表，先读取它，再按其中的设计域打标。否则使用 `references/domain-map.md` 作为主检查表。

`references/domain-map.md` 是当前 skill 的入口地图：它把存储设计问题分成架构轴和指标轴，并在每个 entry 中链接到 `references/domain_knowledge/38-checklist-entry-details.md` 的对应 anchor。需要解释某个 entry 的审查意图、证据、边界或探针时，只读取对应 anchor；需要追溯证据时，再进入 `references/design_evidence/`。

每个设计域使用这些状态：
- `未讨论`
- `已分析`
- `已决策`
- `已验证`
- `暂不适用`

对每个 `未讨论` 或只有弱证据支撑的域，写一个可执行探针：读哪个文件、跑哪个测试、加哪个 trace、做哪个 size/QD/failure sweep。

完成标准：缺口表覆盖架构轴和指标轴：目标、工作负载、语义、metadata、layout/placement、读写路径、队列/backpressure、I/O 栈、内存/硬件、持久化、一致性、复制/EC、后台任务、故障恢复、管理面、观测、benchmark、运维、成本和生命周期。

## Step 7: 输出调研报告

使用 `references/output-contract.md`。报告必须区分事实、推断、假设和缺口。

最后给出：
- 最重要的 5-10 个已确认事实。
- 最危险的 5-10 个未知或风险。
- 下一步 3-7 个调查动作，按信息增益排序。

完成标准：读者不需要重新翻完整仓库，也能知道项目是什么、关键路径在哪里、哪些结论可信、下一步该挖哪里。

## 参考加载

只加载本轮需要的材料：

当前 `references/` 结构是稳定材料库，不保存研究过程稿：
- `references/domain-map.md`：主检查表。没有外部检查表时，从这里选择架构轴和指标轴，并跟随表格里的 `详解` 链接。
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
