# hyperscaler 主题 reference cards

- 分析范围：仅覆盖以下 8 个 canonical URL 的网页/文档分析，不下载 raw 文件，不改动其他目录或主 checklist。
- 访问日期：2026-07-11（Asia/Shanghai）
- 证据等级定义：A = 一手且时间明确、机制具体；B = 一手但更偏概览/索引/动态；C = 间接或信息不足；D = 无法访问。
- 说明：本页只记录可公开访问页面的分析结果；若页面属于动态首页、博客索引或文档入口，会明确标出其局限。

## 1) Meta: Meta’s AI Storage Blueprint at Scale

- 标题：Meta’s AI Storage Blueprint at Scale
- 组织/团队：Meta Engineering / Data Center Engineering / Data Infrastructure
- 资料类型：官方工程博客文章
- URL：https://engineering.fb.com/2026/07/01/data-infrastructure/metas-ai-storage-blueprint-at-scale/
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：已发布，2026-07-01；当前可访问，属于时间明确的一手工程文章。
- 关键机制或文档内容：文章讲 Meta 如何把面向 AI 的 BLOB storage 从“多层状态化元数据 + 数据代理”重构为“统一扁平元数据 + 直接读路径”的架构；核心点包括：基于 Tectonic 的区域级多租户底座、用 ZippyDB 承载统一 metadata schema、客户端 SDK 内嵌 BlockClient 直接从 Tectonic 拉取数据、`getReadPlan()` 将路径映射到 `(blockId, offset, size)`、按 chunk 做 O(1) 查找、分布式数据缓存与 read-plan 元数据缓存、hedged reads、动态并发控制、prefetch 与分层缓存（GPU host 内存/flash + 区域 flash L3 + 全局 HDD 源数据）。
- 对现有 storage checklist 的关联：强相关于对象存储、元数据设计、数据面/控制面分离、客户端直连、缓存、预取、尾延迟治理、故障恢复、AI 数据管道、容量/成本与功耗约束。
- 证据等级：A
- 事实：Meta 声称其存储服务已支撑百 EB 级集群；新架构把 metadata 分层压平并把数据代理移出路径；AI workload 采用区域化部署、缓存和动态并发控制。
- 推断：这篇文章适合作为 hyperscaler AI storage 章节的“现代重构模板”，尤其适合说明为什么传统全球默认、代理式对象存储会在 AI 训练里成为瓶颈。
- 未知/待核验：文中没有公开新架构的硬性 SLO、准确吞吐上限、故障注入数据或可复现实验脚本；ZippyDB 与 Owl 的内部接入细节也未展开。
- 是否适合下载 raw 副本，以及建议文件名：适合；建议保存为 `2026-07-01-meta-ai-storage-blueprint-at-scale.html`，若归档为 PDF 可用 `2026-07-01-meta-ai-storage-blueprint-at-scale.pdf`。

## 2) arXiv 论文: Understanding Data Storage and Ingestion for Large-Scale Deep Recommendation Model Training

- 标题：Understanding Data Storage and Ingestion for Large-Scale Deep Recommendation Model Training
- 组织/团队：arXiv / Meta 相关作者团队
- 资料类型：公开论文摘要页
- URL：https://arxiv.org/abs/2108.09373
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：2021-08-20 首次提交，2022-04-22 最后修订到 v4；当前可访问，版本信息明确。
- 关键机制或文档内容：摘要明确指出 datacenter-scale AI training clusters 依赖数据存储与摄取（DSI）管道，负责存放 exabytes 级训练数据并以 tens of TB/s 的规模供给；论文给出 Meta 的端到端 DSI pipeline，包括建立在分布式存储上的 central data warehouse，以及用于消除 data stalls 的 Data PreProcessing Service，并描述 geo-distributed datacenters 上的连续训练、海量过滤与 evolving datasets。
- 对现有 storage checklist 的关联：强相关于数据摄取、训练前处理、吞吐/带宽、hot data、分布式存储、性能工程、AI workload 基准与数据管道瓶颈。
- 证据等级：A
- 事实：论文是正规学术来源，且有明确提交/修订版本；摘要中已给出 pipeline 结构和规模级别；与 Meta 博客形成“论文 + 工程实践”互证。
- 推断：如果 checklist 需要“为什么 AI storage 会被训练数据摄取卡住”的学术证据，这篇论文比博客更适合做底层论据。
- 未知/待核验：当前只核了摘要页，没有读取 PDF 全文，因此方法细节、实验设置和图表结论仍需以论文 PDF 为准。
- 是否适合下载 raw 副本，以及建议文件名：适合；建议保存为 `2108.09373-understanding-data-storage-and-ingestion-for-large-scale-deep-recommendation-model-training.pdf`。

## 3) Discord: How Discord Stores Trillions of Messages

- 标题：How Discord Stores Trillions of Messages
- 组织/团队：Discord Engineering / Engineering & Developers
- 资料类型：官方工程博客文章
- URL：https://discord.com/blog/how-discord-stores-trillions-of-messages
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：已发布，2023-03-06；当前可访问，时间明确。
- 关键机制或文档内容：文章回顾 Discord 从 MongoDB 迁移到 Cassandra 后仍遭遇高 toil、不可预测延迟和热点分区；描述消息表按 channel + bucket 分区、Snowflake ID 可时间排序、Cassandra 读写特性导致 hot partition；后续迁移到 ScyllaDB，并在迁移时使用 super-disk storage topology，将 Local SSD 的速度与持久盘的耐久性结合；迁移目标是“trillions of messages、no downtime、quickly”。
- 对现有 storage checklist 的关联：强相关于大规模消息存储、分区热点、数据库维护成本、迁移策略、存储拓扑、性能工程、无停机迁移。
- 证据等级：A
- 事实：页面直接给出了数据规模、节点规模、分区模型和迁移方向；它是典型的“从 Cassandra 到更适合负载的系统”的工程复盘。
- 推断：如果 checklist 关注“日志/消息系统如何在超大规模下避免热分区与高运维成本”，这篇是最直接的参考之一。
- 未知/待核验：文章提到了后续 ScyllaDB 迁移，但当前摘取页面未核到迁移完成后的最终指标；也没有公开完整 schema 或负载分布。
- 是否适合下载 raw 副本，以及建议文件名：适合；建议保存为 `2023-03-06-discord-how-discord-stores-trillions-of-messages.html`。

## 4) Snowflake: Snowflake’s Data Architecture: Enabling AI Apps, Next-Gen Lakehouse Analytics And More

- 标题：Snowflake’s Data Architecture: Enabling AI Apps, Next-Gen Lakehouse Analytics And More
- 组织/团队：Snowflake Engineering Blog / Data Engineering
- 资料类型：官方工程博客文章
- URL：https://www.snowflake.com/en/blog/engineering/snowflake-s-data-architecture--enabling-ai-apps--next-gen-lakeho/
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：已发布，2025-02-25；当前可访问，时间明确。
- 关键机制或文档内容：文章说明 Snowflake 用统一 metadata layer 连接 open data lake architecture、native Snowflake tables 和 Hybrid Tables；支持 Iceberg、native columnar format、row-oriented + columnar encodings；列式数据使用 Snowflake columnar format 或 Apache Parquet，并依赖 PAX 风格布局、块级压缩和文件级 min/max 元数据做谓词裁剪；还明确指出数据布局与 table metadata、以及 data flow engine 的 in-memory 表示是解耦的。
- 对现有 storage checklist 的关联：强相关于存算分离、统一元数据、异构表格式、列式存储、数据治理、predicate pruning、hybrid transactional + analytical workload。
- 证据等级：A
- 事实：Snowflake 公开确认其架构要同时覆盖 structured / semi-structured / unstructured data，并以统一平台承载 AI apps、analytics 和 transactional processing。
- 推断：这篇文章适合放在“多数据布局 + 统一治理 + 计算/存储解耦”的 checklist 小节，尤其能补足“单一存储格式无法覆盖多工作负载”的论据。
- 未知/待核验：当前页未给出具体对象大小、微分区实现细节或成本数字；如果要做更细的 storage design card，仍需补 micro-partition、cache 和 failover 的官方文档。
- 是否适合下载 raw 副本，以及建议文件名：适合；建议保存为 `2025-02-25-snowflake-data-architecture-ai-apps-lakehouse.html`。

## 5) Huawei: Decoupled Storage-Compute Architecture: The New De facto Standard for Distributed Databases

- 标题：Decoupled Storage-Compute Architecture: The New De facto Standard for Distributed Databases
- 组织/团队：Huawei Blog / Huawei Storage
- 资料类型：官方工程博客文章
- URL：https://blog.huawei.com/en/post/2023/11/30/decoupled-storage-compute-architecture-standard-distributed-databases
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：页面 URL 自带日期 2023-11-30；当前可访问，但属于观点型博客而非规格文档。
- 关键机制或文档内容：文章讨论分布式数据库为什么走向存算分离：弹性扩缩、峰谷负载、O&M 成本；页面强调共享存储、资源独立伸缩、以及数据库系统从传统耦合形态向解耦形态迁移的行业趋势。就结构而言，这是偏“架构趋势论证”的文章，而不是细粒度 API/协议说明。
- 对现有 storage checklist 的关联：中强相关于存算分离、资源弹性、运维成本、共享存储、数据库架构演进和企业系统重构。
- 证据等级：B
- 事实：它确实是华为官方博客页面，也有明确日期和架构主张。
- 推断：适合用来补“行业趋势”与“为什么要解耦”的叙述，但不适合当作实现级别的证据。
- 未知/待核验：当前摘取内容没有核到可复现的协议、接口、性能边界或失败语义；如果要做 checklist 落地，仍需补产品文档或白皮书。
- 是否适合下载 raw 副本，以及建议文件名：适合做时间点快照；建议保存为 `2023-11-30-huawei-decoupled-storage-compute-architecture.html`。

## 6) Tencent Cloud: Storage Engine Architecture and Data Model

- 标题：Storage Engine Architecture and Data Model
- 组织/团队：Tencent Cloud / TDSQL Boundless 文档
- 资料类型：官方产品文档
- URL：https://intl.cloud.tencent.com/document/product/1292/78894
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：Last updated: 2026-04-17 12:21:17；当前可访问，时间明确，且明显属于持续维护的产品文档。
- 关键机制或文档内容：文档介绍 TDStore storage engine for TDSQL Boundless，说明其基于 RocksDB，包含 data shard module、distributed transaction module 和底层 Raft consensus protocol；三层 metadata model 包括 DataObject、Replication Group、Region(data shard)；Region 是最小物理存储单位，容量标准为最大 256MB 或 100,000 行；KV 编码采用 mem-comparable key，索引具备全局递增 ID、同索引前缀一致、逻辑连续；Replication Group 有 leader/follower/learner/witness 角色，支持多副本、一致性与 data affinity scheduling。
- 对现有 storage checklist 的关联：强相关于元数据分层、分片、复制、事务、一致性、扩容、再平衡、数据亲和、KV 编码与物理布局。
- 证据等级：A
- 事实：这是一份能直接落到设计 checklist 的产品文档，包含明确的容量限制、角色定义和数据模型。
- 推断：如果 checklist 需要“具体到 shard/region/replication group 该如何描述”的参考，这份文档可直接用作模板。
- 未知/待核验：当前页面没有展开分布式事务冲突处理、再平衡算法细节或故障恢复流程的完整时序；这些通常在相邻文档里。
- 是否适合下载 raw 副本，以及建议文件名：适合；建议保存为 `2026-04-17-tencent-tdsql-boundless-storage-engine-data-model.html`。

## 7) AWS: AWS Storage Blog

- 标题：AWS Storage Blog
- 组织/团队：AWS Storage Blog / AWS
- 资料类型：官方博客首页 / 动态索引页
- URL：https://aws.amazon.com/blogs/storage/
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：无单一固定发布日期；这是持续更新的博客索引，当前首页可见 2026-05-27 到 2026-06-12 的多篇新文章。
- 关键机制或文档内容：首页展示的是存储主题文章目录，不是单篇机制文档；当前可见条目覆盖 Diskless Kafka + Amazon S3 / FSx for NetApp ONTAP、CIFS share-level access controls、Amazon S3 Vectors、AWS Backup / GuardDuty 联动、EBS gp2 to gp3 迁移、S3 audit logging 等，能看出 AWS 存储博客的覆盖面主要落在对象存储、块存储、文件存储、备份、日志、成本和性能优化。
- 对现有 storage checklist 的关联：广覆盖对象存储、块存储、文件系统、备份恢复、日志审计、迁移、成本优化、性能工程，但因为它是首页索引，适合作为入口，不适合作为单一事实来源。
- 证据等级：B
- 事实：页面是官方 AWS Storage Blog 入口，且能直接看到近期主题分布；它不是单篇文章，也没有单一时间点的稳定正文。
- 推断：这页更适合用来继续追踪具体 AWS 存储文章，而不是作为 checklist 的最终证据页。
- 未知/待核验：首页内容会频繁变化；如果要把某个具体 AWS 机制写成卡片，应改抓对应 permalink，而不是这个索引页。
- 是否适合下载 raw 副本，以及建议文件名：不优先；如果一定要留时间点快照，可保存为 `2026-07-11-aws-storage-blog-index.html`。

## 8) Google Cloud: Cloud Storage documentation

- 标题：Cloud Storage documentation
- 组织/团队：Google Cloud Documentation / Cloud Storage 团队
- 资料类型：官方产品文档入口 / 文档首页
- URL：https://cloud.google.com/storage/docs
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：Last updated 2026-07-07 UTC；当前可访问，属于持续维护的官方文档入口。
- 关键机制或文档内容：当前核到的是 Cloud Storage 文档首页本身，它是 storage 文档导航中心，连接到 guides、reference、samples、release notes、quickstarts 和相关产品资源；页面明确属于 Google Cloud Storage 的官方 docs 栈，但首页本身不承载具体 API 细节、配额或生命周期规则。
- 对现有 storage checklist 的关联：相关于对象存储、生命周期、耐久性、安全、API/SDK、配额与限流、成本与区域选择，但这一级页面更像目录，需要再下钻到具体子页才能形成实现级卡片。
- 证据等级：B
- 事实：它是 Google Cloud 的官方 Storage 文档首页，且明确显示最近更新日期。
- 推断：如果 checklist 需要 Google Cloud Storage 的具体机制，应该从这个入口继续追 `storage classes`、`bucket/object`、`lifecycle`、`quotas and limits`、`release notes` 等子页。
- 未知/待核验：当前页面没有直接展开 bucket API、XML/JSON API、生命周期规则和限制值；这些都需要单独子页核验。
- 是否适合下载 raw 副本，以及建议文件名：适合做时间点快照，但更优先保存具体子页；建议文件名 `2026-07-11-google-cloud-storage-docs-index.html`。

## 共同模式

- 多数 hyperscaler / hyperscaler-like 来源都在强调“元数据与数据面解耦、客户端直连、分层缓存、预取、以及 tail latency 治理”。
- AI / 大规模训练场景普遍把 storage 问题重新定义为“GPU 利用率问题”和“研究迭代速度问题”，而不只是容量问题。
- 数据库 / 存储趋势都在朝“存算分离、地域化部署、共享底座、多副本、一致性、弹性伸缩”收敛，但实现路径差异明显。
- 公开材料里，博客文章更适合回答“为什么这么做”和“架构长什么样”，产品文档更适合回答“限制是什么、接口怎么用、边界在哪”。

## 冲突

- Meta 新架构强调 regional deployment 和 on-host / regional tiered cache，而部分传统云存储叙述仍偏 global-by-default 或统一入口模型，二者在性能与可用性取舍上并不相同。
- Snowflake 的统一 metadata layer 试图抽象多格式存储，而 Tencent TDStore 则把重点放在 KV 编码、Region、Replication Group 和 Raft 角色上，抽象层级不同，不能直接混用。
- AWS Storage Blog 和 Google Cloud Storage docs 都是“入口页”，但前者偏新闻/文章流，后者偏产品文档目录；两者都不能直接当成单篇机制证据。

## 缺口

- 这组来源里，真正给出明确限制值、角色定义或 API 行为的只有 Tencent 文档最完整，其他大多是架构描述或博客叙述。
- 多数来源缺少可复现实验、故障注入数据、SLO、容量上限、成本模型和失败语义时序。
- AWS 和 Google 这两个入口页还需要继续下钻到具体子页，才能补足 API、配额、生命周期、类目和限制条件。
- 当前未下载任何 raw 副本；如果后续要做长期留档，优先保存 arXiv PDF、Tencent / Google docs 子页、以及各篇博客的 permalink 快照。
