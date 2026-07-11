# OpenSource 主题 Reference Cards

分析范围：仅基于以下 canonical URLs 的官方网页/仓库页面做文档分析卡片，不下载副本，不修改其他 checklist 或 skills 文件。所有访问日期均为 `2026-07-11`。对无法直接访问或无法稳定核验的 URL，明确记录失败原因，不补写机制内容。

---

### 1) Alluxio 架构文档
- 标题：Alluxio Architecture / Introduction
- 组织/团队：Alluxio 官方文档团队
- 资料类型：官方产品文档，架构总览页
- URL：https://docs.alluxio.io/os/user/stable/en/overview/Architecture.html
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：`stable` 轨道；页面重定向到 `https://documentation.alluxio.io/os-en`；页面底部显示 `Last updated 7 months ago`
- 关键机制或文档内容：Alluxio 位于应用与底层存储之间，提供统一客户端 API 和全局命名空间；强调 memory-first tiered architecture；支持 HDFS API、S3 API、FUSE API、REST API；文档明确说明其桥接对象存储与分析/AI 应用。
- 对现有 storage checklist 的关联：直接对应 `namespace`、`metadata`、`cache`、`API translation`、`UFS`、`AI training storage`、`data access layer` 这些条目；也适合放入“对象存储上层加速/统一入口”分支。
- 证据等级：B
- 事实：页面明确给出 Alluxio 的位置、统一接口、全局命名空间和多级缓存定位。
- 推断：如果 checklist 关注“计算侧就近缓存 + 对象存储抽象层”，Alluxio 是典型参考。
- 未知/待核验：该页面本身没有给出发布版本号或变更日志；需要更细版本时应再查 release notes。
- 是否适合下载 raw 副本，以及建议文件名：适合；建议 `alluxio-architecture-stable-20260711.html`

---

### 2) Alluxio 白皮书
- 标题：Alluxio Architecture: A Decentralized Data Acceleration Layer for the AI Era
- 组织/团队：Alluxio；作者 Bin Fan、Haoyuan Li
- 资料类型：官方白皮书 / 产品技术文章
- URL：https://www.alluxio.io/whitepaper/alluxio-architecture-a-decentralized-data-acceleration-layer-for-the-ai-era
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：页面未显式标注发布日期；当前可访问的营销/技术白皮书版本；内容强调 DORA（Decentralized Object Repository Architecture）
- 关键机制或文档内容：客户端按 consistent hashing ring 找 worker；worker 先查本地 NVMe Page Store；元数据与数据页共址于 worker 上的 RocksDB；cache miss 时从底层对象存储用 range GET 拉取；用 etcd 做服务注册与协调；没有单一 master 或 journal；UFS 作为持久层和 source of truth；页面指出页大小通常 ≤4 MB、使用 LRU 淘汰、数据路径采用 zero-copy。
- 对现有 storage checklist 的关联：对应 `control plane/data plane`、`decentralized metadata`、`cache locality`、`NVMe`、`metadata colocation`、`failure recovery`、`multi-cloud`、`AI training/inference` 分支；也适合补充“无中心元数据服务”的对照样例。
- 证据等级：B/C
- 事实：白皮书明确描述了 DORA 的数据流、worker 职责、UFS 定位和故障恢复策略。
- 推断：该白皮书更偏面向 AI 数据加速场景，不是通用文件系统设计说明。
- 未知/待核验：页面没有显式发布日期；文中性能数字（如 <1 ms、TB/s、97–98% GPU utilization）属于厂商宣称，仍需独立基准验证。
- 是否适合下载 raw 副本，以及建议文件名：适合；建议 `alluxio-dora-whitepaper-20260711.html`

---

### 3) BeeGFS 架构文档
- 标题：Architecture / Overview
- 组织/团队：BeeGFS 官方文档团队
- 资料类型：官方架构文档
- URL：https://doc.beegfs.io/8.1/architecture/overview.html
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：`BeeGFS Documentation 8.1.0`；版本明确
- 关键机制或文档内容：BeeGFS 通过多个 storage servers 提供 striped file contents；metadata 与 file contents 分离；客户端直接并行访问多个 storage servers；metadata 也可以分布到多个 metadata servers；服务端是用户态 daemon；客户端是 Linux kernel module；支持 Multi Mode 和 converged setup；management service 作为 registry 和 watchdog。
- 对现有 storage checklist 的关联：对应 `striping`、`metadata split`、`parallel I/O`、`kernel client`、`management/registry`、`scale-out filesystem`、`converged deployment` 分支；适合作为“并行文件系统 vs 分布式对象层”的文件系统入口样例。
- 证据等级：A/B
- 事实：页面明确给出三类核心角色（client / metadata service / storage service）以及 management service 的职责。
- 推断：若 checklist 关注“客户端直连数据面、元数据分离、并行吞吐”，BeeGFS 是强参考。
- 未知/待核验：页面未在当前摘录中给出更细的写入一致性、故障恢复或升级路径，需要补查相邻章节。
- 是否适合下载 raw 副本，以及建议文件名：适合；建议 `beegfs-architecture-overview-8.1.0-20260711.html`

---

### 4) SeaweedFS 架构 PDF
- 标题：SeaweedFS_Architecture.pdf
- 组织/团队：SeaweedFS 项目 / seaweedfs 社区
- 资料类型：GitHub Wiki PDF
- URL：https://github.com/seaweedfs/seaweedfs/wiki/SeaweedFS_Architecture.pdf
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：无法直接访问；当前工具对该 PDF 未返回可解析正文，无法核验版本或发布日期
- 关键机制或文档内容：无法核验，未取得正文
- 对现有 storage checklist 的关联：无法核验，暂不写入机制性关联；只保留为待补证条目
- 证据等级：D
- 事实：URL 指向 GitHub wiki 下的 PDF 资源
- 推断：仅从文件名可判断其可能是项目架构说明，但不能据此写入任何实现细节
- 未知/待核验：PDF 内容、发布日期、是否仍与当前 SeaweedFS 主线一致均未知
- 是否适合下载 raw 副本，以及建议文件名：当前不建议；先找到可访问的官方镜像或可解析副本后再保存，建议名 `seaweedfs-architecture.pdf`

---

### 5) OpenEBS Mayastor 用户指南
- 标题：Mayastor 相关页面（当前 URL 无法直接核验）
- 组织/团队：OpenEBS 官方文档团队
- 资料类型：官方产品文档
- URL：https://openebs.io/docs/3.9.x/user-guides/mayastor
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：路径显示 `3.9.x`；但页面在当前工具中无法稳定展开，未能取得正文
- 关键机制或文档内容：无法核验，未取得正文
- 对现有 storage checklist 的关联：无法核验，暂不写入机制性关联；只保留 URL 级别占位
- 证据等级：D
- 事实：URL 语义上指向 OpenEBS 3.9.x 的 Mayastor 用户指南
- 推断：该条目应与 Kubernetes/CSI/块存储/虚拟卷路径有关，但这只是根据路径的弱推断，不能当作事实写入 checklist
- 未知/待核验：标题、版本对应关系、具体功能、限制与故障恢复行为都未核验
- 是否适合下载 raw 副本，以及建议文件名：当前不建议；待页面可访问后再保存为 `openebs-mayastor-user-guide-3.9.x-20260711.html`

---

### 6) Ceph 文档首页 / 架构页
- 标题：Welcome to Ceph / Architecture
- 组织/团队：Ceph 官方文档团队
- 资料类型：官方文档首页 + 架构文档
- URL：https://docs.ceph.com/en/latest/
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：`latest` 轨道；页面明确提示 `This document is for a development version of Ceph`
- 关键机制或文档内容：Ceph 提供 object/block/file 三合一存储；架构页说明了 Ceph Storage Cluster、RADOS、Monitors、OSDs、Manager、MDS；使用 CRUSH 计算对象位置，避免中央查表；cluster map 包括 Monitor Map、OSD Map、PG Map、CRUSH Map、MDS Map；cephx 负责认证；BlueStore 是默认后端；客户端可通过 librados、Ceph Block Device、Ceph Object Storage、Ceph File System 或自定义客户端接入。
- 对现有 storage checklist 的关联：对应 `object/block/file`、`CRUSH`、`placement group`、`cluster map`、`monitor quorum`、`authentication`、`metadata service`、`rebalancing`、`erasure coding`、`cache tiering` 等条目，是“统一存储平台”最强参考之一。
- 证据等级：A/B
- 事实：官方文档明确给出了角色分工、数据放置算法、集群映射和认证模型。
- 推断：如果 checklist 关注“去中心化数据放置 + 多协议统一存储”，Ceph 是基准样例。
- 未知/待核验：当前页面是 development version，和某个具体发行版之间的行为差异需要再按 release notes 约束。
- 是否适合下载 raw 副本，以及建议文件名：适合；建议 `ceph-architecture-latest-20260711.html`

---

### 7) RocksDB 仓库首页
- 标题：facebook/rocksdb
- 组织/团队：Facebook Database Engineering Team / RocksDB maintainers
- 资料类型：GitHub 仓库首页 / README
- URL：https://github.com/facebook/rocksdb
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：仓库 `main` 分支；页面显示 `Releases 215`，最新发布 `RocksDB 11.1.2`，`Jun 25, 2026`
- 关键机制或文档内容：README 明确说明 RocksDB 是嵌入式持久化 KV store，采用 LSM 设计；在 WAF/RAF/SAF 间做权衡；支持多线程 compaction；适合单库 TB 级数据；公共接口放在 `include/`，其他内部头文件不应依赖，内部 API 可能无预警变化。
- 对现有 storage checklist 的关联：对应 `LSM`、`WAL/manifest/compaction`、`embedded storage engine`、`WAF/RAF/SAF`、`internal API boundary`、`flash/SSD storage` 条目；也适合作为存储引擎子系统的基础样例。
- 证据等级：A/B
- 事实：仓库主页给出项目定位、设计风格、公共 API 边界和最新 release 信息。
- 推断：RocksDB 更像可嵌入存储引擎，不是分布式系统；在 checklist 中应归到“单机引擎/组件”而不是“集群控制面”。
- 未知/待核验：主页没有展开更细的读写路径、恢复机制、压实策略参数；需要再查官方 wiki 或源码文档。
- 是否适合下载 raw 副本，以及建议文件名：适合；建议 `rocksdb-readme-github-main-20260711.html`

---

### 8) FoundationDB 文档首页
- 标题：FoundationDB 7.3.77
- 组织/团队：Apple / FoundationDB documentation
- 资料类型：官方文档站点首页 + 架构文档入口
- URL：https://apple.github.io/foundationdb/
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：明确标注 `FoundationDB 7.3.77`
- 关键机制或文档内容：FoundationDB 是面向 commodity servers 的分布式数据库，数据模型是 ordered key-value store；全部操作都通过 ACID transactions；架构页说明了 Coordinators、Cluster Controller、Master、GRV Proxies、Commit Proxies、Transaction Logs、Resolvers、Storage Servers、Data Distributor、Ratekeeper 等角色；客户端通过语言绑定接入，官方支持 C、Go、Python、Java、Ruby；读路径从 GRV proxy 获取 read version，写路径通过 commit proxy / resolver / transaction log 完成；storage servers 只保留最近约 5 秒的 mutation，超过这个窗口会触发 `transaction_too_old`。
- 对现有 storage checklist 的关联：对应 `distributed transactional KV`、`coordination roles`、`read/write path`、`conflict resolution`、`log durability`、`replication`、`rate limiting`、`recovery window`、`client bindings` 条目；是“分布式事务数据库”方向的核心参考。
- 证据等级：A
- 事实：版本、角色分工、事务路径和时间窗口限制都被文档直接写明。
- 推断：如果 checklist 关注“严格一致性、版本化读、事务恢复”，FoundationDB 是最强对照样例之一。
- 未知/待核验：某些实现细节（例如各角色的最新调度/容灾策略）需要继续按 7.3.77 的后续架构页和 release notes 交叉核验。
- 是否适合下载 raw 副本，以及建议文件名：适合；建议 `foundationdb-7.3.77-architecture-20260711.html`

---

### 共同模式
- 这些资料大多都在回答同一组 checklist 轴：`namespace / metadata / placement / client path / recovery / consistency / cache / API boundary`。
- Alluxio、BeeGFS、Ceph、FoundationDB 都把“控制面/元数据”和“数据面”分开，只是分离程度不同：Alluxio 更偏缓存/加速层，BeeGFS 偏并行文件系统，Ceph 偏统一存储平台，FoundationDB 偏事务控制与版本化读写。
- RocksDB 是单机嵌入式引擎，不是分布式系统，但它的 LSM / compaction / API 边界恰好适合补 checklist 中“本地存储引擎”部分。

### 冲突
- Alluxio 白皮书强调“完全去中心化、无单一 master/journal”，而 Ceph / FoundationDB 仍保留显式协调角色或单例控制角色，这两类设计不能混为一谈。
- BeeGFS 和 Ceph 都做元数据分离，但 BeeGFS 更偏“客户端直连多 storage server 的并行文件系统”，Ceph 更偏“对象为中心的统一存储集群”；适合放在 checklist 的不同分区。
- RocksDB 的 LSM 取舍与 Ceph / FoundationDB 的分布式事务或对象存储语义不是同一层级，不能直接拿来比较系统级可用性。

### 缺口
- SeaweedFS Wiki PDF 与 OpenEBS Mayastor 页面在当前工具里无法稳定打开，缺少正文证据，暂时只能留空或标 D 级失败卡。
- Alluxio 白皮书与 Ceph `latest` 文档都缺少强版本锚点，后续如果要做“当前最佳实践”判断，还需要配 release notes 或版本化文档页。
- BeeGFS、RocksDB 的当前摘录足够做架构卡片，但还缺少更细的限制条件与恢复路径，需要时应继续补查官方变更日志或源码文档。
