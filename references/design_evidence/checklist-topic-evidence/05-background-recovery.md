# 05. 后台任务与恢复

范围：依据 `README.md`，抽取 `../../domain-map.md` 中第 9 题“后台任务与资源治理”和第 10 题“故障恢复、升级与演进”的 evidence table。仅使用本地 reference cards 与本地网页快照，不联网。

## Evidence Table

| check_item | source | local_ref | evidence_type | evidence_note | design_pressure | confidence | gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 后台任务清单与压实基线 | RocksDB maintainers | `../../domain_knowledge/reference_cards/opensource/index.md` | mechanism | RocksDB 官方仓库主页明确写出 LSM 取舍、WAF/RAF/SAF 权衡和多线程 compaction，说明压实不是边缘优化，而是引擎的核心后台工作。 | 后台压实必须纳入队列预算、限流和长跑稳态测试；不能只看前台读写。 | B | 还缺 current release note、compaction 参数和 stall/回压语义，才能判断生产默认值。 |
| 后台压实的资源治理 | Dropbox Tech / Magic Pocket | `../web-snapshots/batch-09/text/68c4f22d6c9f64e1.md` | evaluation | Magic Pocket 因新放置服务引入碎片化后，旧 compaction 策略无法及时回收空间；后续改成 L1/L2/L3 分层压实、rate limit、cell-local 运行和动态阈值控制。 | 后台任务要按数据分布自适应，而不是只有单一压实启发式；需要显式保护元数据、网络和前台 I/O。 | A | 这是工程文章，不是规格；还缺可复现实验、阈值公式和故障注入结果。 |
| 故障时 placement/rebalance | Ceph 官方文档 | `../../domain_knowledge/reference_cards/opensource/index.md` | mechanism | Ceph 通过 CRUSH 计算对象位置，cluster map 包含 OSD/PG/CRUSH 等映射，证据卡把 rebalancing 直接列为 checklist 关联项。 | 故障恢复与扩容不能依赖中心查表；重平衡语义要与 placement 机制一致。 | B | 还缺具体发行版的 recovery runbook、backfill 限流和 degraded read 的量化数据。 |
| 联邦集群与非中断迁移 | IBM Storage / FlashSystem docs | `../../domain_knowledge/reference_cards/enterprise/index.md` | mechanism | FlashSystem grid 可把多个独立系统编成 federated cluster，最多 32 个系统，支持独立更新、混合代际和 storage partition 非中断迁移。 | 升级/扩容必须和联邦管理语义绑定，不能把“单机可维护”误当成“整网无中断”。 | A | 还缺不同版本的 limits page 和故障切换细则，尤其是认证与管理面限制。 |
| 后台 rebuild / 重建 | IBM Storage Scale System | `../../domain_knowledge/reference_cards/enterprise/index.md` | claim | Storage Scale System 使用 Storage Scale RAID（EC）保护硬件故障，并宣称分钟级后台磁盘重建且不影响应用性能。 | 重建流量必须可控，前台性能不能被“快速恢复”反向拖垮。 | A | 还缺重建并发、带宽上限、degraded 性能曲线和故障域实验。 |
| 生命周期与后台维护 | Nutanix Objects / Atlas | `../../domain_knowledge/reference_cards/enterprise/index.md` | mechanism | Objects datasheet 把 Atlas 明确分配为 lifecycle、audit 和 background maintenance，且同页还写明 versioning、WORM、tagging、multipart、EC、compression、dedup。 | 后台生命周期任务会改变用户可见语义，必须把合规、版本化和归档一起设计。 | A | 这是 2019 版 datasheet，仍需新版本文档确认当前 Atlas 边界和默认行为。 |
| Hedged reads 与分层缓存 | Meta Engineering | `../../domain_knowledge/reference_cards/hyperscaler/index.md` | mechanism | Meta AI storage 文章把直接读路径、read-plan 缓存、hedged reads、动态并发控制、prefetch 和多级缓存串成一个尾延迟治理链路。 | 失败/慢设备不能只靠重试；必须把 hedge、缓存和并发控制当成数据面的一部分。 | A | 缺公开 SLO、尾延迟分布和缓存失效实验，难以验证收益上限。 |
| 热点、迁移与零停机演进 | Discord Engineering | `../../domain_knowledge/reference_cards/hyperscaler/index.md` | counterexample | Discord 先在 MongoDB/Cassandra 体系里遇到高 toil、不可预测延迟和 hot partition，后续迁移到 ScyllaDB，并用 super-disk topology、GeoDNS 和无停机迁移来收敛风险。 | 迁移方案必须先解决热点分区和恢复路径，否则规模一上来就会把运维成本放大。 | A | 还缺迁移完成后的最终指标、schema 细节和回滚窗口。 |
| 架构边界与统一软件层 | Dell PowerScale OneFS | `../../domain_knowledge/reference_cards/enterprise/index.md` | boundary | OneFS 把 file system、volume manager 和 data protection 合并为单一统一软件层，运行在分布式 OneFS cluster 上。 | 恢复、保护和扩容被放进同一 OS 边界后，后台任务和升级策略就必须按集群级设计。 | B | 还缺节点/网络/故障域的更细页面，无法判断控制平面如何分担恢复压力。 |
| 版本兼容与升级边界 | BeeGFS docs | `../../domain_knowledge/reference_cards/opensource/index.md` | boundary | BeeGFS 8.4 文档目录直接列出 version interoperability、mounting multiple versions at the same time 和 BeeGFS 8.4 Upgrade Guide，说明升级路径是显式文档化的。 | 升级不是附属操作，必须先定义混合版本窗口和兼容边界，再谈线上演进。 | B | 还缺升级过程中的失败注入、回滚条件和写入一致性边界。 |
| HPE 失败卡 / 文档缺口 | HPE Storage / PSNow | `../../domain_knowledge/reference_cards/enterprise/index.md` | gap | 两个 HPE 目标当前都只能看到标题和下载入口，正文未取到，无法核验 controller failover、迁移步骤或回滚条件。 | 不能把标题级信息写成事实；在 checklist 中只能保留为未核验缺口。 | D | 需要可访问的 PDF 正文或官方镜像，才能补 failover、升级和迁移细则。 |

## Gaps

- Ceph 目前仍停留在 `latest` 架构入口层，缺少版本化 recovery/rebalance runbook、backfill 限流和 degraded mode 的量化数据。
- RocksDB 证据只证明了 compaction 是核心后台工作，但还没有 current release 的参数表、stall 行为和写放大边界。
- Meta、Discord 和 Dropbox 都是高质量工程文章，但都缺少可复现的实验脚本、故障注入矩阵和统一 SLO。
- BeeGFS 的升级证据已经表明存在 mixed-version 边界，但还需要更细的故障恢复、回滚和一致性约束页面。
- HPE 两个 PSNow 条目仍是正文缺失卡，不能据此判断 controller failover、迁移窗口或架构演进路径。
