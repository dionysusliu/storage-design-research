# Evidence 01 - Goals And Metadata
## Scope
本页只覆盖两块：1) 业务目标与工作负载；2) 数据模型、命名与元数据。  
证据只来自你指定的本地片段：checklist 前 70 行、hyperscaler cards、opensource cards、enterprise cards、kernel 的 VFS 卡。

## Evidence Table
| check_item | source | local_ref | evidence_type | evidence_note | design_pressure | confidence | gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| scope contract | Storage Design Checklist v0 草案 | `../../domain-map.md` | boundary | checklist 明确要求每个条目都要给出结论、证据、验证动作和风险信号；因此本页按可审查、可追证的方式整理，而不是只写概述。 | 把 workload 和 metadata 讨论变成可验证的设计问题。 | A | 本轮只覆盖两大主题，布局、读写路径等留到后续证据页。 |
| primary workload is AI storage | Meta’s AI Storage Blueprint at Scale | `../../domain_knowledge/reference_cards/hyperscaler/index.md:8-19` | claim | Meta 把面向 AI 的 BLOB storage 重构为统一扁平元数据和直接读路径，且强调区域级多租户、缓存和动态并发控制，说明主工作负载是 AI 训练/推理数据访问，而不是通用对象存储。 | AI 负载更看重 GPU 利用率、区域化访问和尾延迟控制。 | A | 缺少公开 SLO、吞吐上限和故障注入结果。 |
| workload hot-spot risk | Discord: How Discord Stores Trillions of Messages | `../../domain_knowledge/reference_cards/hyperscaler/index.md:40-54` | claim | Discord 的消息表按 channel + bucket 分区，文中直接点出 Cassandra 时代的热点分区和不可预测延迟，说明消息型工作负载会被分区键和时间排序 ID 强烈塑形。 | 需要优先防热点、减少停机迁移成本。 | A | 没有给出最终迁移后的量化收益和完整 schema。 |
| unified metadata across multiple table types | Snowflake’s Data Architecture | `../../domain_knowledge/reference_cards/hyperscaler/index.md:56-67` | mechanism | Snowflake 用统一 metadata layer 连接 open data lake、native tables 和 Hybrid Tables，并把布局与 table metadata 解耦，说明同一平台要同时承载分析、AI 和事务型负载。 | 元数据必须能跨多种数据格式和表类型做统一治理。 | A | 缺少混合版本、迁移和回滚的细节。 |
| explicit shard and metadata bounds | Tencent Cloud: Storage Engine Architecture and Data Model | `../../domain_knowledge/reference_cards/hyperscaler/index.md:88-102` | boundary | Tencent 把 DataObject、Replication Group、Region 三层元数据讲得很清楚，还给出 Region 256MB 或 100000 行的上限，说明元数据层需要明确容量边界和角色边界。 | 设计不能只说“可水平扩展”，还要说清 shard、region 和 RG 的边界。 | A | 分布式事务冲突处理和再平衡时序未展开。 |
| global namespace and API translation | Alluxio Architecture / Introduction | `../../domain_knowledge/reference_cards/opensource/index.md:7-18` | mechanism | Alluxio 位于应用和底层存储之间，提供统一客户端 API 和全局命名空间，适合作为上层抽象和命名空间统一入口的参考。 | 命名空间设计要兼顾 API 兼容和缓存层抽象。 | B | 该摘录没有版本号和细粒度限制说明。 |
| striped file contents with split metadata | BeeGFS Architecture / Overview | `../../domain_knowledge/reference_cards/opensource/index.md:41-52` | mechanism | BeeGFS 通过多个 storage servers 提供 striped file contents，metadata 与 file contents 分离，客户端可并行直连多个 storage server，体现了文件系统型命名空间和元数据拆分的典型做法。 | 需要把目录、元数据和数据面分开看。 | A | 写一致性、故障恢复和升级边界未在摘录中出现。 |
| object/block/file unification | Ceph Welcome / Architecture | `../../domain_knowledge/reference_cards/opensource/index.md:92-103` | mechanism | Ceph 同时提供 object、block、file 三类接口，并用 CRUSH 和 cluster map 决定对象位置，说明统一存储平台的命名和放置必须显式建模。 | 命名空间、放置和认证要一起设计，不能只看接口表面。 | A | 当前是 latest 开发版视图，和具体发行版仍可能有差异。 |
| ordered KV and transaction semantics | FoundationDB 7.3.77 | `../../domain_knowledge/reference_cards/opensource/index.md:126-139` | boundary | FoundationDB 把数据模型定义为 ordered key-value store，全部操作走 ACID transactions，还写明了约 5 秒 mutation 窗口，说明元数据和读写版本都受严格边界约束。 | 需要把版本、事务窗口和恢复语义写成明确规范。 | A | 各角色最新调度和容灾策略仍需交叉核验。 |
| S3-compatible single namespace | Nutanix Objects Datasheet | `../../domain_knowledge/reference_cards/enterprise/index.md:93-105` | mechanism | Nutanix Objects 明确给出 S3-compatible REST API、single namespace、metadata service、生命周期管理、版本化和 WORM，说明对象存储的命名与元数据职责可以拆成前端、控制器、元数据和后台维护几层。 | 对象存储必须把命名、版本、生命周期和元数据服务一起考虑。 | A | 这是 2019 版资料，和当前产品线可能有命名或功能漂移。 |
| snapshot as point-in-time metadata state | NetApp snapshots technology cloud volumes | `../../domain_knowledge/reference_cards/enterprise/index.md:107-119` | claim | NetApp 把 snapshot 定义为 volume 的 point-in-time copy，且创建时不需要 full copy，这说明快照更像元数据驱动的状态点，而不是完整数据副本。 | 元数据设计要能表达只读状态、时间点和空间效率。 | B | 这是 2018 年博客，后续云平台行为可能已变化。 |
| pathname to dentry/inode boundary | Overview of the Linux Virtual File System | `../../domain_knowledge/reference_cards/kernel/index.md:19-28` | boundary | VFS 把 open、stat、read、write 等系统调用接入统一抽象层，路径先查 dcache，再落到 inode；这说明文件语义的命名和元数据边界首先由 VFS 决定。 | 文件型设计必须尊重 VFS 路径解析、dentry 缓存和 inode 语义。 | A | 不同文件系统对回调的实现差异仍需按子系统继续核验。 |
| ownership boundary across high-performance paths | Kernel common pattern note | `../../domain_knowledge/reference_cards/kernel/index.md:103-106` | evaluation | 内核侧资料把 queue、mapping、ownership、ordering、completion 视为同一组边界词，这说明元数据和命名不仅是结构问题，也是所有权和完成顺序问题。 | 需要把 ownership boundary 写进元数据协议和对象生命周期。 | B | 这组材料更偏边界总结，缺少具体实现细节。 |

## Gaps
- 本轮证据足够说明主要工作负载和元数据边界，但几乎所有来源都缺少统一的容量模型、尾延迟曲线和可复现实验数据。
- AI、消息、对象存储、分布式事务四类负载的目标函数不一样，当前还没有把它们收敛成同一张 workload matrix。
- 元数据版本演进、mixed-version 行为和回滚路径只在少数资料里明确出现，后续如果要落设计，需要继续补这类证据。
- 目前的证据多来自博客、datasheet 和 latest 文档，版本漂移风险存在，尤其是 `latest` 轨道和较老 blog / PDF。
- 如果后续扩展到布局、分片、读写路径和恢复语义，需要补新的证据页，不能直接从本页推断。
