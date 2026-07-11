---
name: "storage-project-investigator"
description: "默认使用中文勘探存储项目的架构、代码路径、性能语义、持久化语义和未决风险。Use when the user wants to 调研、摸清、梳理、审计 or reverse-engineer a storage, database, filesystem, object-store, KV, cache, SPDK, io_uring, RDMA, or distributed-storage project before design, refactor, benchmarking, or research planning."
---

# Storage Project Investigator

## 总览

使用这个 skill 对一个存储项目做系统勘探。目标不是复述 README，也不是堆证据表或测试结果，而是先从源代码和项目文档做细致的系统分析：从整体架构、组件、框架开始，逐层拆到子组件、关键数据结构、控制流、数据流、状态机和跨组件交互。完成组件分析后，再参考 `references/domain-map.md` 的架构/指标逻辑，把每个 entry 回填成可继续设计、实现或研究的材料。

分析优先级是：细致代码分析 > 项目文档分析 > 网络/外部评价 > 测试和 benchmark 结果。证据的作用是指出相关代码、文档和外部材料的位置，绝不能替代分析，也不能作为跳过代码分析的理由。测试结果只能用于验证或反驳已经形成的代码/架构分析，不能成为调查的起点。

勘探的核心产物分两层：第一层是系统架构、组件树、子组件和跨组件交互的详细分析；第二层是 `references/domain-map.md` 中每一个 Architecture entry、Metrics entry、Universal Metric 和 Mandatory Artifact 的逐项回答。默认优先使用 HTML 承载面向人阅读的详查、图、代码片段和最终报告；Markdown 只作为轻量索引、机器可 diff 的 companion、草稿或用户明确要求时的兼容输出。每个 entry 必须单独写成一篇详查文档，并从第一层组件分析中补充该 entry 需要的信息。所有调研 artifact 必须集中写入同一个勘探目录。

当 entry 数量较多时，可以使用 subagent 并行处理。主 agent 负责拆分 entry、给每个 subagent 分配清晰边界、合并结果、去重冲突分析、统一材料可信度和最终裁决；subagent 只负责自己分配到的 entry，不应自行改写全局结构。并行数量遵守当前运行环境的 subagent 上限，超出时分批执行。

默认使用中文交流、分析和写作 artifact。只有用户明确要求英文或目标项目必须保留英文原文时，才使用英文；英文术语、代码符号、API 名称和原始引用可以保留原文，但解释和结论仍默认中文。

## 工作流

0. 确认 artifact 目录。
1. 快速记录勘探边界，不把它当成独立研究阶段。
2. 从源代码和项目文档分析整体系统架构、组件树和框架。
3. 对每个组件继续细分子组件，并分析组件内部逻辑和跨组件交互。
4. 加载 `references/domain-map.md`，把它作为回填 entry 的调查合同。
5. 逐项回填 Architecture Checklist、Architecture Drift Review、Metrics Checklist 和 Universal Metrics。
6. 补齐 Cross-Gate Mandatory Artifacts 与代码/文档缺口探针。
7. 输出 domain-map 驱动的 HTML 最终报告；Markdown companion 可选。

## Step 0: 扫描并确认 artifact 工作区

启动调研时先扫描当前工作区，查找已有的 `research/` 子目录、已有调研目录，以及包含 `components/`、`entries/`、调研 manifest、最终报告或其他勘探 artifact 的目录。不要先询问“是否新建”，也不要在确认前写入调研内容。

按扫描结果执行：
- 发现候选目录：列出路径和已有 artifact，询问用户选择哪个作为本次工作区；用户也可以指定其他已有目录。
- 没有发现候选目录：创建 `research/<project-slug>-investigation-YYYYMMDD/` 作为候选目录，然后询问：“工作区中未发现已有调研目录，我已创建 `<path>`；是否将它作为本次调研工作区？”
- 用户确认候选目录：记录为本轮唯一 artifact 工作区，后续所有中间笔记和最终报告都写入这里。
- 用户拒绝候选目录：询问其指定的已有目录；在新目录被确认前，不写任何 artifact，也不在项目根目录散落文件。
- 用户已在初始请求中指定目录：将其作为显式目录输入，但仍先确认该路径可用，不重复询问新建策略。

artifact 目录不强制固定顶层文件名。顶层可以按需要创建少量 scope、manifest、index、source locator、cross-component summary、HTML final report 等轻量文件；Markdown 只作为可选 companion。顶层文件只做导航、状态表、跨组件裁决、可视化浏览和最终汇总，不是详查正文。不要把所有内容压缩进这些单个文档；如果只有顶层汇总/HTML final report 而没有 `components/` 和 `entries/` 下的逐项详查，本轮调研视为未完成。

并为每个组件单独创建详查文档，默认优先 HTML：
- `components/<component-slug>/overview.html`
- `components/<component-slug>/<subcomponent-slug>.html`
- 可选 companion：同名 `.md`，仅用于机器 diff、纯文本引用或用户明确要求。

并为每个 entry 单独创建详查文档，默认优先 HTML：
- `entries/architecture/<entry-slug>.html`
- `entries/metrics/<entry-slug>.html`
- `entries/universal-metrics/<entry-slug>.html`
- `entries/mandatory-artifacts/<artifact-slug>.html`
- 可选 companion：同名 `.md`，仅用于机器 diff、纯文本引用或用户明确要求。

汇总文件只保留索引、状态表、精选解释、短代码片段、图例和跨组件/跨 entry 裁决；详细解释、代码路径、组件交互、文档分析、网络评价和探针必须写入对应组件或 entry 详查文档。优先让这些详查文档本身就是 HTML，而不是只在最终报告里有图。

完成标准：扫描动作、候选目录、用户确认结果和最终工作区路径都已记录；如果没有候选目录，必须先创建 `research/<project-slug>-investigation-YYYYMMDD/` 再询问是否采用；用户确认前不得写任何调研 artifact；确认后所有 artifact 都写入该目录，并在最终报告列出 artifact manifest。

## 详查的最低标准

“详查”不是概括性描述，也不是 source locator 表。每篇组件、子组件、entry 或 mandatory artifact 文档都必须直接分析目标项目的具体代码逻辑。

最低要求：
- 直接列出具体文件、入口函数、核心类型、成员字段、配置项、状态枚举、关键调用链、错误路径和并发/异步边界。能定位行号时写行号；不能定位行号时标 `待精确行号`，不能省略代码对象。
- 对关键逻辑写出“代码如何工作”：谁创建对象，谁持有状态，谁调用谁，输入如何变成输出，失败如何返回或重试，何处产生 ack/durable/visible/commit/apply 等语义。
- 必要时摘录很短的源码片段或函数签名，并紧接着解释该片段证明了什么、还不能证明什么。不要长篇复制源码。
- 任何涉及 3 个以上组件的交互，都要在对应组件文档或跨组件交互汇总文档中写 Mermaid 图，并在图后说明每条边代表函数调用、RPC、队列、日志、文件、设备队列、配置依赖还是人工流程。
- 项目文档、论文、博客、网页评价和测试结果只能放在代码分析之后，用来解释、对照、验证或指出冲突；不能代替源码分析。
- component index、architecture answers、metrics answers 这类汇总文件只链接详查文档和记录状态，不承载完整分析。
- HTML 是默认详查格式：每篇组件/entry 详查都应把解释、短代码和图例放在同一页中。Markdown companion 不能替代 HTML，除非用户明确要求纯 Markdown 或环境无法合理生成 HTML。
- 顶层 HTML final report 是阅读入口；每张卡必须链接回对应 `components/` 或 `entries/` 详查文档。

可以参考 `assets/examples/3fs-component-overview.md`、`assets/examples/3fs-cross-component-interaction.md`、`assets/examples/3fs-entry-analysis.md` 和 `assets/examples/3fs-metric-analysis.md` 的写法。示例只展示输出形态；真实调研必须在当前目标项目 checkout 中重新读取源码、补齐行号和调用链。

## Step 1: 快速记录勘探边界

这一步只用于避免误解，不是正式研究阶段，也不应产出长文档。用几行记录本次勘探的最小边界，然后立刻进入 Step 2；后续读代码后可以回头修正。

快速记录：
- 项目类型：block、file、object、KV、database engine、distributed database、cache、log、stream 或自定义 extent 系统。
- 目标读者：研究选题、立项评审、代码接手、性能优化、安全审查、重构计划或论文写作。
- 当前目标深度：默认代码级和路径级；实验级只在代码/文档分析形成假设后追加。
- 明确排除项：只有用户已说明或代码规模迫使分批时才写。
- Artifact 目录：本轮调研写入的位置，以及是否由本次新建。

完成标准：边界记录不超过一个短节，包含项目类型、目标读者、目标深度和 artifact 目录即可；缺失信息用保守假设标为“待确认”，不要因为 Step 1 不完整而暂停源码分析。

## Step 2: 分析整体系统架构、组件和框架

调查必须从项目自身开始，而不是从 checklist 开始。先阅读源代码目录、构建系统、启动入口、配置、README/设计文档和主要测试，画出系统整体结构。

当不知道系统架构汇总应写到什么粒度时，参考 `assets/examples/3fs-component-overview.md`：它示范了如何从 `main()`、服务类、共享 app framework 和 allocator include 这类具体代码对象推出服务边界，而不是只复述项目 README。

至少回答：
- 系统是什么：block、file、object、KV、database engine、distributed database、cache、log、stream 或其他。
- 进程/服务/库边界是什么。
- control plane、metadata plane、data plane、management plane 是否存在，边界在哪里。
- 对外 API、内部 API、存储格式、网络协议、配置入口、启动入口在哪里。
- 核心组件有哪些，每个组件拥有的状态、输入、输出、依赖、生命周期是什么。
- 组件之间通过函数调用、队列、RPC、日志、共享内存、文件、设备队列还是后台任务交互。

完成标准：整体架构汇总解释系统主要框架；组件树汇总列出组件和子组件；每个顶层组件都有 `components/<component-slug>/overview.html`，说明职责、边界、核心代码位置和与其他组件的交互；Markdown companion 可选。

## Step 3: 组件、子组件和跨组件交互深析

对每个组件继续细分子组件，并做细致代码分析。分析必须从代码控制流和数据流展开，文档和外部资料只能辅助解释，不能替代源码阅读。

组件文档写法参考 `assets/examples/3fs-component-overview.md`；跨组件交互图和逐边解释参考 `assets/examples/3fs-cross-component-interaction.md`。

每个组件/子组件文档至少包含：
- `Role and Boundary`：职责、输入、输出、所有权、生命周期。
- `Code Walkthrough`：关键文件、入口函数、核心类型、成员字段、调用链、状态转移、错误路径、配置开关；必须直接列出具体代码对象，并解释它们如何共同完成该组件的职责。
- `State and Data Flow`：权威状态、副本、缓存、派生状态、数据格式、持久化位置。
- `Control Flow and Concurrency`：线程、协程、reactor、worker pool、队列、锁、回调、completion route。
- `Cross-Component Interactions`：与其他组件的调用、RPC、事件、队列、日志、设备或文件交互；涉及 3 个以上组件时必须给出 Mermaid 图，并解释图中每条边的代码依据。
- `Project Document Analysis`：项目文档如何描述该组件，哪些地方与代码一致或冲突。
- `External Context Locator`：相关外部文档、规范、工程博客或网页快照的位置；这里只做定位和背景，不替代代码分析。
- `Open Questions`：无法从代码或文档确认的地方。

跨组件交互必须单独分析，不要只把组件文档堆在一起。至少覆盖：
- 请求从入口到完成经过哪些组件。
- 写路径中 ack、durable、visible、commit/apply 的边界在哪些组件之间转移。
- 读路径中 cache、metadata、device/network、completion 的跨组件关系。
- 后台任务如何影响前台路径。
- 故障、重试、取消、timeout、restart、recovery 如何跨组件传播。

可以用 subagent 并行处理独立组件或交互链，但每个 subagent 必须交付组件文档草稿和代码分析摘要。主 agent 负责合并组件边界、消除重复和冲突，并统一跨组件交互图。

完成标准：组件分析索引链接所有组件/子组件文档；跨组件交互汇总总结关键跨组件路径；source locator 只记录代码、项目文档、外部材料的位置和等级，不替代组件分析正文。

## Step 4: 加载 domain-map 调查合同并建立 entry 清单

完成系统和组件分析后，再读取 `references/domain-map.md`，把它作为回填 entry 的调查合同。即使目标项目包含自己的 `design-checklist.md`，也只能作为项目本地输入或补充约束；不能替代本 skill 的 `domain-map.md` 主逻辑，除非用户明确要求。

建立 entry 清单时可以参考 `assets/examples/3fs-entry-analysis.md` 的 `Component Context` 写法：每个 entry 必须声明依赖哪些组件文档和跨组件交互分析，不能孤立回答 checklist 问题。

必须抽取这些部分作为本轮待回答清单：
- `Review Flow`
- `Architecture Checklist`
- `Architecture Drift Review`
- `Metrics Checklist`
- `Universal Metrics`
- `Metrics Status Template`
- `Cross-Gate Mandatory Artifacts`
- `Open Evidence Gaps`

对 `Architecture Checklist` 和 `Metrics Checklist` 的每一行，都要跟随 `详解` 链接读取 `references/domain_knowledge/38-checklist-entry-details.md` 的对应 anchor。不要只复制表格问题；必须理解该 entry 的解释、审查意图、分析思路和 cannot-claim 边界。

完成标准：domain-map 合同文档列出本轮必须回答的全部 Architecture entry、Metrics entry、Universal Metric、Mandatory Artifact，并为每个 entry 指定唯一 slug、详查文档路径、负责 agent、适用性、初始优先级，以及它依赖哪些组件分析文档。

## Step 5: 从组件分析回填 Architecture Checklist

按照 `references/domain-map.md` 的 `Architecture Checklist` 顺序逐项回答，不允许跳过。每个 entry 至少使用这个格式：

entry 文档写法参考 `assets/examples/3fs-entry-analysis.md`：先给组件上下文和具体代码分析，再写项目文档、外部评价、source locator、cannot-claim 和 next probes。

- `entry`：Architecture 项名称。
- `status`：`通过` / `需补 ADR` / `触发重审` / `暂不适用`。
- `direct answer`：直接回答该行 `关键问题`。
- `complete code analysis`：从 `components/` 文档回到源码，列出相关模块、入口函数、数据结构、状态机、线程/队列切换、错误路径、配置开关和调用链；对读写路径、持久化、恢复、backpressure、placement 等问题必须追到可解释的代码层。
- `project document analysis`：列出项目文档、注释、配置说明、issue/PR/release note/runbook 中的承诺、遗漏和与代码不一致之处。
- `network/external context`：列出与该 entry 相关的官方规范、论文、厂商文档、社区评价、工程博客、网页快照或在线检索结果；这些材料只能作为背景、对照、评价或风险提示，不能替代本项目代码分析。
- `source locator`：列出相关代码、项目文档和外部材料的位置。
- `required artifacts`：对应 `domain-map.md` 里的必须产物是否存在、是否足够。
- `drift trigger`：是否触发 Architecture Drift Review。
- `material confidence`：A/B/C/D，表示材料可信度；不能替代代码分析完整度。
- `unknowns and probes`：下一步读代码、跑测试、加 trace、联网核验或实验的动作。

每个 Architecture entry 都必须写入 `entries/architecture/<entry-slug>.html`。Architecture answers 汇总只维护总表，包含 entry、详查文档链接、status、分析完整度、drift trigger、top risk 和 next action；Markdown companion 可选。

如果使用 subagent 并行处理，按 entry 或相邻 entry group 分片，例如 metadata/layout、read/write/backpressure、durability/recovery、I/O/hardware、management/operability/claim policy。每个 subagent 的交付物必须是对应 entry 文档草稿、组件分析引用和 source locator；主 agent 合并前必须核查代码分析是否充分、材料定位是否准确、cannot-claim 边界是否保留。

Architecture pass 必须覆盖：workload、API 语义、metadata、layout/placement、replication/consensus、recovery/rebalance、read path、write path、backpressure、程序化优化、I/O 栈、memory/hardware、hardware lifecycle、durability/consistency、replication/EC/snapshot、background work、management plane、operability lifecycle、claim policy。

完成标准：`entries/architecture/` 中每个 Architecture entry 都有独立详查文档，且每篇文档必须先给出来自组件分析的细致代码分析，再给项目文档分析和网络/外部评价定位；缺失的材料必须写成缺口，而不是沉默跳过。Architecture answers 汇总能链接到所有 entry 文档。

## Step 6: 从组件分析回填 Metrics Checklist 和 Universal Metrics

按照 `references/domain-map.md` 的 `Metrics Checklist` 顺序逐项回答，不允许跳过。Metrics 不是状态表，也不是 benchmark 数字表；每个 metric 必须完整论述代码如何产生该指标、项目文档如何定义或承诺该指标、外部方法学如何帮助解释该指标，以及至少一个具体场景例子。写法参考 `assets/examples/3fs-metric-analysis.md`。

每个 metric 至少使用这个格式：

- `metric`：指标项名称。
- `architecture link`：对应 Architecture entry 或 ADR。
- `target/current`：目标、当前状态或“未定义”。
- `code logic under analysis`：该指标对应哪些代码路径、状态机、队列、后台任务或硬件路径；先解释实现如何产生该指标，再谈怎么测。
- `worked example`：给出一个具体请求、后台任务、恢复流程、容量变化、队列拥塞或硬件路径的例子，说明该 metric 在本项目中如何被影响；如果例子还不能从代码确认，标为“待验证例子”。
- `methodology`：如果需要验证，应如何测量；工具版本、参数、采样窗口、job file、trace/profiling 方法。没有完成测试时标为验证缺口。
- `related documents`：列出项目 README、设计文档、配置说明、benchmark 文档、测试说明、runbook、dashboard、issue/PR/release note 中和该 metric 相关的材料；没有相关文档时必须写成文档缺口。
- `project document analysis`：项目如何定义该指标、SLO、测试或发布门槛；与代码分析是否一致，是否遗漏关键路径或失败场景。
- `network/external context`：外部 benchmark、规范方法学、社区/厂商评价、论文 artifact 或已抓取材料如何评价这个指标；只能作为对照和方法学参考，并说明适用边界。
- `source locator`：代码路径、文档位置、外部材料位置，以及可选的 dashboard、trace、test report、runbook drill 位置；只记录位置，不替代分析。
- `status`：`green` / `yellow` / `red` / `gray`。
- `risk`：当前风险。
- `next_action`：下一周期动作。

每个 Metrics entry 都必须写入 `entries/metrics/<entry-slug>.html`。每个 Universal Metric 都必须写入 `entries/universal-metrics/<entry-slug>.html`。Metrics answers 汇总只维护总表，包含 metric、详查文档链接、architecture link、status、methodology gap、top risk 和 next action；Markdown companion 可选。

Universal Metrics 不允许完全跳过。即使项目早期没有数据，也必须给出完整的定性论述和一个具体例子：数据正确性、可用性与恢复、性能与尾延迟、容量效率与写放大、成本与功耗、可运营性、可观测性、安全与隔离、可复现性。缺少代码、项目文档或外部方法学时标为缺口，不能只写“暂无数据”。

完成标准：`entries/metrics/` 和 `entries/universal-metrics/` 中每个 entry 都有独立详查文档，先分析对应代码路径和组件交互，再给出 worked example、相关项目文档、外部方法学/评价、验证方法和下一步动作；没有可复现数据的项必须标 `gray`，不能写成已验证。Metrics answers 汇总能链接到所有 entry 文档。

## Step 7: 补齐 Mandatory Artifacts 与缺口探针

使用 `references/domain-map.md` 的 `Cross-Gate Mandatory Artifacts` 作为产物清单。对每个 artifact 判断：

- 已存在且足够。
- 已存在但证据不足。
- 不存在，需要新建草案。
- 暂不适用，并说明重新启用条件。

Mandatory artifacts 包括但不限于：`workload-matrix.html`、`api-semantics-contract.html`、`metadata-ownership-map.html`、`layout-placement-matrix.html`、`read-path-sequence.html`、`write-path-sequence.html`、`queue-backpressure-budget.html`、`optimization-adr.html`、`io-stack-adr.html`、`memory-hardware-contract.html`、`hardware-lifecycle-matrix.html`、`durability-recovery-plan.html`、`management-plane-contract.html`、`observability-benchmark-artifact.html`、`operability-lifecycle-runbook.html`。同名 `.md` 只作为可选 companion。

每个 Mandatory Artifact 也必须有独立详查文档：`entries/mandatory-artifacts/<artifact-slug>.html`。该文档说明 artifact 是否已存在、是否足够、它应汇总哪些组件分析、缺哪些代码/文档/外部定位材料、是否需要新建草案，以及它覆盖哪些 Architecture/Metrics entry。

对每个缺口写一个可执行探针，必须说明：
- 读哪些代码文件/符号。
- 查哪些项目文档或历史 issue/PR。
- 查哪些外部文档、网页快照或在线来源。
- 若代码/文档分析已经形成假设，再跑哪些测试、benchmark、fault injection、trace、profile 或 size/QD/failure sweep 来验证。
- 完成后能把哪个 `domain-map.md` entry 从 gray/yellow 推到 green，或从 `需补 ADR` 推到 `通过`。

完成标准：`entries/mandatory-artifacts/` 中每个 mandatory artifact 都有独立详查文档；mandatory artifacts 汇总链接并汇总 `Cross-Gate Mandatory Artifacts` 每一行；next probes 文档中的探针能明确补哪一项组件分析、Architecture/Metrics/Universal Metric 的内容。

## Step 8: 输出 HTML-first 调研报告

使用 `references/output-contract.md` 作为内容合同，但默认输出 HTML 最终报告。Markdown final report 只作为可选 companion。最终报告必须区分事实、推断、假设和缺口。

最后给出：
- System / component analysis manifest：整体架构、组件树、组件详查和跨组件交互文档。
- Architecture Checklist 总表：每项状态、分析完整度、source locator 完整度、主要风险。
- Metrics Checklist 总表：每项 green/yellow/red/gray、代码分析状态、方法学状态、主要缺口。
- Universal Metrics 总表：最低讨论是否完成。
- Mandatory Artifacts manifest：存在/不足/需新建/暂不适用。
- Entry document manifest：所有 `entries/**/<slug>.html` 的链接、负责人、状态和最后更新时间；列出可选 Markdown companion 时必须标明它不是主交付。
- 最重要的 5-10 个已确认事实，必须来自代码/组件分析，并能回指到代码和项目文档；外部资料只作为补充定位。
- 最危险的 5-10 个未知或风险，说明触发的 architecture drift 或 claim 降级。
- 下一步 3-7 个调查动作，按信息增益排序。

完成标准：读者不需要重新翻完整仓库，也能从最终报告跳转到 `domain-map.md` 中每一个问题的独立详查文档，并看到完整代码逻辑、项目文档证据、网络/外部评价和下一步探针。

## HTML 报告和详查格式

参考 `improve-codebase-architecture` 的 HTML report 思路，但适配本 skill：
- HTML 文件写入本次 artifact 工作区，不写入 OS temp，也不散落到项目根目录；文件名可以按项目命名，并记录在 artifact manifest。
- HTML 是默认的人类阅读和交付格式，可以使用 Tailwind CDN 和 Mermaid CDN；不需要前端构建、不引入框架。
- Markdown 是可选 companion，不是首选产物；不要先写完整 Markdown 再随手生成一个空 HTML wrapper。
- 可以从 `assets/html/storage-investigation-report-template.html` 复制模板后填充。模板只是起点，必须按实际项目删改。
- 使用 Mermaid 表达 call graph、dependency graph、sequence、read/write path、recovery path；使用手写 CSS/SVG/div 表达层次、状态所有权、队列拥塞、读写放大、claim 降级等更 editorial 的图。
- 每个 HTML card 必须把三件事放在一起：解释、短代码、图例。只写文字或只贴图都不合格。

HTML final report 至少包含这些区域：
- `Investigation Map`：artifact manifest、组件详查、entry 详查、source locator、final report、可选 Markdown companion 的链接。
- `System Architecture`：服务/进程/库边界图、组件树、关键启动入口代码片段。
- `Component Cards`：每个高价值组件一张卡，包含 files、role、code proves、cannot claim、Mermaid/hand-built diagram、详查文档链接。
- `Cross-Component Paths`：read/write/recovery/background/management path，每条边说明代码依据。
- `Architecture Entries`：每个 entry 的 verdict、代码逻辑摘要、项目文档摘要、外部评价摘要、risk、详查文档链接。
- `Metrics Entries`：每个 metric 的 code logic、worked example、related documents、methodology gap、status、详查文档链接。
- `Top Risks and Next Probes`：最危险未知、claim 降级、下一步读代码/补文档/验证动作。

HTML card 的最低字段：
- `Title`：组件、路径、entry 或 metric 名称。
- `Status`：`confirmed` / `partial` / `gap` / `risk`，用 badge 呈现。
- `Files`：涉及的代码文件和文档，使用 monospace。
- `Explanation`：1-3 段中文解释，说明代码如何工作。
- `Code`：短源码片段或函数签名，紧跟“这证明什么 / 不能证明什么”。
- `Diagram`：Mermaid 或手写图，解释组件/路径/状态/指标关系。
- `Links`：回链到 `components/**`、`entries/**` 和相关 source locator。

不要把 HTML 做成漂亮但空的 dashboard。它必须服务于调研：让读者能从图和短代码快速理解系统，再跳回组件/entry HTML 详查看完整证据。Markdown companion 只用于辅助检索和 diff。

## Entry 详查文档模板

每篇 `entries/**/<slug>.html` 都使用同一信息结构；如果生成同名 `.md` companion，也必须保持同样内容顺序：

- `Entry`：原始 checklist entry 名称、所属 section、`domain-map.md` 行/anchor、详解 anchor。
- `Question`：原始关键问题，以及本项目中的具体化问题。
- `Verdict`：当前裁决、分析完整度、材料定位完整度、适用性、是否触发架构重审或指标红旗。
- `Component Context`：该 entry 依赖哪些 `components/**` 文档和跨组件交互分析。
- `Detailed Code Analysis`：完整代码逻辑。列模块、文件、函数、数据结构、状态机、线程/队列、配置、错误路径；必要时给出调用链或状态转换。这里是正文核心，不能用 source locator 或测试结果替代。
- `Project Document Analysis`：README、设计文档、注释、配置、issue/PR、release note、runbook 如何描述这段逻辑，哪些地方与代码一致、冲突或缺失。
- `Network / External Evaluation`：官方规范、论文、厂商文档、社区评价、工程博客、网页快照、在线检索结果；说明它们对本项目分析有什么帮助或限制。
- `Source Locator`：按 `kind / location / why_relevant / limitation` 记录代码、项目文档和外部材料位置。它只负责定位，不替代分析。
- `Cannot Claim`：根据 `38-checklist-entry-details.md` 和本轮证据列出不能宣称的内容。
- `Gaps`：代码分析缺口、文档缺口、外部定位缺口、验证缺口。
- `Next Probes`：下一步可执行探针，优先写清还要读哪个文件、追哪个符号、补哪段组件交互；测试、benchmark 和抓取外部材料放在代码/文档分析之后。

## 参考加载

只加载本轮需要的材料：

当前 `references/` 结构是稳定材料库，不保存研究过程稿：
- `references/domain-map.md`：主调查合同。每轮勘探都必须从这里选择并逐项回答架构轴、指标轴、通用指标和 mandatory artifacts；外部检查表只能作为补充输入。
- `references/domain_knowledge/38-checklist-entry-details.md`：主检查表每个 entry 的逐项详解。文件较长，优先按 `domain-map.md` 中的 anchor 定位读取，不要整篇加载，除非用户要求全量审阅。
- `references/domain_knowledge/source-inventory.md`：来源清单和材料状态。用于判断某类来源是否已覆盖、是否有缺口。
- `references/domain_knowledge/download-gaps.md`：下载失败、弱证据或不可强声明的来源。用于避免把未抓取材料写成已验证事实。
- `references/domain_knowledge/reference_cards/{kernel,hardware,enterprise,hyperscaler,opensource,community}/index.md`：按来源类型整理的参考卡。需要快速了解某类团队、社区、厂商或硬件材料时读取对应卡片。
- `references/design_evidence/checklist-topic-evidence/`：按 checklist 主题聚合的外部参考定位表；用于理解 domain-map 的分析思路和可参考材料，不替代目标项目源码分析。
- `references/design_evidence/source-document-evidence/`：按具体来源文档聚合的机制背景材料；先读 `README.md` 看 Ceph、fio、FoundationDB、RocksDB、Tencent、CXL/Optane、SNIA Swordfish、HPE、DPDK 等文档覆盖范围，再进入单个文件作为背景对照。
- `references/design_evidence/web-snapshots/`：已抓取网页快照。只在需要核对外部原文、评价网络 claim 或追溯背景材料时读取。
- `references/output-contract.md`：最终报告结构和缺口表格式。
- `references/source-strategy.md`：当代码、文档、论文、博客或厂商材料混杂时，用于判定证据优先级。
- `assets/html/storage-investigation-report-template.html`：生成 HTML 详查页或 HTML final report 时使用的静态模板。默认需要 HTML 输出时读取或复制，并按项目实际内容删改。

不要寻找旧版编号中间文档；这些过程稿不属于当前 skill 的参考接口。

## License

Copyright (c) 2026 Chuang Liu <dionysusliu815@qq.com>.

This skill is licensed under CC BY 4.0. Commercial use is permitted, attribution is required, and copyright remains with the copyright holder. See `LICENSE`.
