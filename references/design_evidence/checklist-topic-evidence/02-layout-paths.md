# 02-layout-paths

## Scope

基于 `README.md` 的字段规范，抽取 `../../domain-map.md` 中以下两类主题的本地证据：

- 3. 数据布局、分片与放置
- 4. 读写路径

只使用工作区内的 reference cards 和本地 Markdown 快照，不联网，不修改其他文件。

## Evidence Table

### 3. 数据布局、分片与放置

| check_item | source | local_ref | evidence_type | evidence_note | design_pressure | confidence | gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 3.1 布局单位 | Ceph / CRUSH | `../../domain_knowledge/reference_cards/opensource/index.md` | mechanism | Ceph 把对象放入 PG，再用 CRUSH 直接计算落点，配合 OSD/Monitor/CRUSH Map 完成 placement。 | 布局不能靠中央查表或隐式路由，必须明确对象到 PG/OSD/故障域的映射。 | A | 缺本项目自己的故障域映射、rebalance 限流和一致性验证。 |
| 3.2 最小物理分片 | Tencent TDSQL Boundless | `../../domain_knowledge/reference_cards/hyperscaler/index.md` | mechanism | TDStore 的 Region 是最小物理存储单位，最大 256MB 或 100,000 行，KV 采用 mem-comparable key 编码。 | 分片边界要与物理上限对齐，否则热点、迁移成本和局部放大都会失控。 | A | 缺 Region 拆分/合并和热点再切分的具体规则。 |
| 3.3 副本组与亲和调度 | Tencent TDSQL Boundless | `../../domain_knowledge/reference_cards/hyperscaler/index.md` | mechanism | Replication Group 具 leader/follower/learner/witness 角色，并支持 data affinity scheduling。 | 复制语义和调度亲和必须和布局一体设计，不能后补一个复制层。 | A | 缺故障切换、追赶和再平衡的时序细节。 |
| 3.4 条带化布局 | BeeGFS | `../../domain_knowledge/reference_cards/opensource/index.md` | mechanism | BeeGFS 通过多个 storage servers 提供 striped file contents，metadata 与 file contents 分离，客户端直接并行访问多个 storage servers。 | 文件布局必须显式定义 stripe 和元数据/数据分离，否则并行吞吐不可预测。 | A | 缺 striping 参数与负载分布之间的定量对照。 |
| 3.5 本地缓存布局 | Alluxio | `../web-snapshots/batch-04/text/0569a5e1fc8f57db.md` | mechanism | Alluxio 位于对象存储与计算之间，把热数据缓存到每个计算节点的本地 NVMe/SSD。 | 如果采用缓存层，必须定义热数据驻留层、回源路径和失效规则。 | B | 缺缓存命中率、污染和失效行为的 workload-specific 测试。 |
| 3.6 联邦集群与在线迁移 | IBM FlashSystem grid | `../../domain_knowledge/reference_cards/enterprise/index.md` | boundary | FlashSystem grid 可把多个系统组成 federated cluster，最多 32 个系统，storage partitions 可非中断迁移。 | 布局要支持在线迁移和独立升级，否则扩容会变成停机事件。 | A | 缺实际迁移成本、失败回滚和拓扑约束测试。 |
| 3.7 RAID/EC 保护与重建 | IBM Storage Scale System | `../../domain_knowledge/reference_cards/enterprise/index.md` | mechanism | Storage Scale System 使用基于 erasure coding 的 RAID 保护硬件故障，并支持分钟级后台重建且不影响应用性能。 | 如果底层采用 EC/RAID，布局必须把重建窗口和前台性能隔离算清楚。 | A | 缺重建期间的前台 P99、故障域和容量效率实测。 |

### 4. 读写路径

| check_item | source | local_ref | evidence_type | evidence_note | design_pressure | confidence | gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 4.1 读路径时序 | Meta AI Storage Blueprint | `../../domain_knowledge/reference_cards/hyperscaler/index.md` | mechanism | Meta 的 BlockClient 嵌入 SDK，getReadPlan 把路径映射成 blockId / offset / size，并配合 read-plan cache、hedged reads 和 prefetch。 | 读路径不能只画控制面图，必须把 SDK、cache、hedging 和 chunk 查找纳入端到端时序。 | A | 缺真实 read miss 路径和端到端延迟分解。 |
| 4.2 写路径 ack 点 | FoundationDB | `../../domain_knowledge/reference_cards/opensource/index.md` | mechanism | FoundationDB 把全部操作建模为 ACID transactions，写路径经 commit proxy / resolver / transaction log 完成。 | 必须明确 ack 与 durable/commit/visible 的关系，否则写成功语义不可验证。 | A | 缺事务提交成功后可见性的故障注入测试。 |
| 4.3 本地引擎读写与压实 | RocksDB | `../../domain_knowledge/reference_cards/opensource/index.md` | mechanism | RocksDB 是嵌入式 LSM KV store，面向 flash / high-speed disk，读写之外还要面对 compaction filters 和 WAF/RAF/SAF。 | 如果底层是 LSM，读写设计必须把 compaction 和写放大纳入尾延迟预算。 | A | 缺 steady-state compaction under load 的实测。 |
| 4.4 文件路径进入点 | Linux VFS | `../../domain_knowledge/reference_cards/kernel/index.md` | boundary | open/read/write 等系统调用先经 VFS，pathname 先查 dcache，再到 inode 解析真实文件系统对象。 | 面向文件语义的路径不能绕开 VFS 成本，metadata 和 cache 设计要对齐 dentry/inode。 | A | 缺具体文件系统在 permission/get_link 上的实现差异。 |
| 4.5 块层提交与完成 | Linux blk-mq | `../../domain_knowledge/reference_cards/kernel/index.md` | mechanism | blk-mq 用 software staging queue 和 hardware dispatch queue 把 bio 组装成 request，完成顺序不保证 FIFO。 | 设备路径必须显式处理多队列、请求合并和 completion 非 FIFO 语义。 | A | 缺与具体驱动和 NVMe 队列深度的对照实验。 |
| 4.6 DMA / buffer 约束 | Linux DMA API / SPDK DMA | `../../domain_knowledge/reference_cards/kernel/index.md` / `../web-snapshots/batch-05/text/88bebbe24f60979b.md` | mechanism | DMA 地址与 CPU 地址空间不同，scatter/gather 需要 dma_map_sg；SPDK 还要求 DMA-safe buffer 和 PRP 约束。 | 如果走 zero-copy 或用户态数据面，必须写清 buffer 分配、IOMMU 和 SG 映射约束。 | A | 缺本项目驱动或用户态实现的 buffer 生命周期和回收策略。 |

## Gaps

- 主题 3 的主要缺口是本项目自身的 partition / shard / stripe / region 映射规则、rebalance 限流和故障域边界还没有被验证。
- 主题 4 的主要缺口是端到端时序图仍缺可复现实测，尤其是读 miss、写 ack、压实、DMA 和故障注入路径。
- 目前证据足够支撑 checklist 级归纳，但还不足以直接推出本项目的最终参数、阈值和容量上限。
