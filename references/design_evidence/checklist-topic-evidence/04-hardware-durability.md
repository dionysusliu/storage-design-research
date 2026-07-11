# 04 Hardware Durability Evidence

## 范围
- 对应 `../../domain-map.md` 的主题 7「CPU、NUMA、PCIe 与内存路径」和主题 8「持久化、一致性、复制与 EC」。
- 证据字段遵循 `README.md`：`check_item/source/local_ref/evidence_type/evidence_note/design_pressure/confidence/gap`。
- 仅使用本地索引、Markdown 快照与汇总表，不联网。

## Evidence Table

| check_item | source | local_ref | evidence_type | evidence_note | design_pressure | confidence | gap |
|---|---|---|---|---|---|---|---|
| Topic 7 - DMA address translation and IOMMU | Linux kernel DMA API HOWTO | ../web-snapshots/batch-05/text/88bebbe24f60979b.md | mechanism | DMA 使用 bus address 而不是 CPU physical address；IOMMU 可以把任意物理页映射成设备可见地址。 | 设备 I/O 路径必须显式处理 PCIe/DMA 地址转换，不能假设 CPU 地址可直接被硬件使用。 | A | None |
| Topic 7 - DMA-safe buffer ownership | Linux kernel DMA API HOWTO | ../web-snapshots/batch-05/text/88bebbe24f60979b.md | boundary | `vmalloc`、用户态内存和栈内存不能直接用于 DMA；DMA 缓冲应来自 page allocator 或 kmalloc-like 来源。 | I/O buffer 的来源和生命周期必须受控，避免把不可 DMA 的虚拟内存路径带入设备访问。 | A | None |
| Topic 7 - Cacheline safety and coherent vs streaming DMA | Linux kernel DMA API HOWTO | ../web-snapshots/batch-05/text/88bebbe24f60979b.md | mechanism | 非一致性缓存下必须注意 cacheline 共享；coherent mapping 适合 ring/descriptor，streaming mapping 需要按传输阶段同步并在合适时机 unmap。 | 避免 CPU 与设备之间的脏数据、伪共享和 stale read/write。 | A | None |
| Topic 7 - DMA mask and coherent allocation constraints | Linux kernel DMA API HOWTO | ../web-snapshots/batch-05/text/88bebbe24f60979b.md | boundary | 默认 32-bit DMA 假设并不总成立；驱动必须设置正确的 DMA mask，并按设备约束分配 coherent memory。 | PCIe endpoint 的可寻址范围和对齐要求决定了哪些物理页能进入高性能 I/O 路径。 | A | None |
| Topic 7 - SPDK zero-copy and PCI BAR mapping | SPDK NVMe driver docs | ../web-snapshots/batch-03/text/223fdef65d3cf51d.md | mechanism | SPDK 在用户态映射 PCI BAR，使用异步 queue pairs，并以 zero-copy 方式绕过内核 I/O 开销。 | 数据平面需要保持用户态控制权和最短拷贝路径，避免额外的内核切换与缓冲复制。 | A | None |
| Topic 7 - SPDK qpair ownership and core pinning | SPDK NVMe driver docs | ../web-snapshots/batch-03/text/223fdef65d3cf51d.md | boundary | 每个 qpair 只有单线程 ownership；队列内存与 tracker 规模受 controller MQES 和固定 SQE/CQE 结构约束，因此常见做法是一核一 qpair 并 pin 线程。 | 并行度必须按 qpair 分片，否则会碰到锁竞争与队列所有权冲突。 | A | None |
| Topic 7 - CXL tiering and persistent-memory semantics | CXL 3.2 announcement; Intel persistent memory overview | ../../domain_knowledge/reference_cards/hardware/index.md | claim | CXL 面向 memory devices / smart I/O devices，并引入 memory tiering、保护与互操作能力；Intel PMem 文档区分 Memory Mode 与 App Direct。 | 内存路径设计不能把所有 RAM 视为同质资源，必须区分分层、持久化语义和设备安全边界。 | B | Index card is a summary of upstream docs, not the full spec PDF. |
| Topic 7 - Optane persistent media modes | Intel Optane technology brief | ../../domain_knowledge/reference_cards/hardware/index.md | claim | Optane persistent memory 支持 Memory Mode 和 App Direct Mode；Optane SSD 是 PCIe-attached persistent device，因此持久化既可以落在 DIMM-like 介质，也可以落在块设备上。 | 持久化保证取决于目标是 byte-addressable PMem 还是 block device persistence，不能混用抽象。 | A | Historical product line; use as architecture reference rather than current product guidance. |
| Topic 8 - ACID durability and transaction-log roles | FoundationDB docs home | ../../domain_knowledge/reference_cards/opensource/index.md | mechanism | FoundationDB 是 ACID transactional ordered KV store，角色分工包括 coordinators、proxies、resolvers、transaction logs 和 storage servers；storage servers 只保留最近约 5 秒的 mutation。 | 持久化设计要把事务日志、恢复窗口和角色分离一起考虑，不能只看单点落盘。 | A | None |
| Topic 8 - Raft replication group failover | TiKV blog / Raft consensus snapshot | ../web-snapshots/batch-10/text/e27e6fe3e18b1e35.md | claim | Raft consensus 提供 strong data consistency、auto-failover 和 fault tolerance；Region replicas 通过 leader election 和 quorum 维持可用性。 | 复制组必须满足 quorum 与 leader 语义，否则故障切换会破坏一致性。 | B | Tencent-specific Raft/RG text was not locally verified; this is an open-source surrogate. |
| Topic 8 - Ceph placement, replication and EC | Ceph docs | ../../domain_knowledge/reference_cards/opensource/index.md | mechanism | Ceph 统一 object/block/file 接口，使用 CRUSH 进行 placement，结合 cluster maps、cephx、BlueStore，并支持 rebalancing 与 erasure coding。 | 复制与 EC 策略必须和 failure domain、placement 以及集群拓扑变更联动。 | A | None |
| Topic 8 - Erasure coding rebuild economics | IBM Storage Scale System | ../../domain_knowledge/reference_cards/enterprise/index.md | mechanism | Storage Scale RAID 基于 erasure coding，并支持分钟级 background disk rebuild，且不影响应用性能。 | Parity width 和 rebuild 策略必须控制恢复时间与业务抖动。 | A | None |
| Topic 8 - Replication, versioning, WORM, compression and dedup | Nutanix Objects | ../web-snapshots/batch-10/text/42c4fc8ddd46e13d.md | mechanism | 对象存储支持 replication、versioning、WORM/immutability、encryption，以及 compression 和 deduplication。 | 数据保护和空间效率经常要在同一控制面中同时满足，不能把它们拆成独立子系统。 | A | None |
| Topic 8 - Point-in-time snapshots without full-copy penalty | NetApp WAFL snapshot | ../../domain_knowledge/reference_cards/enterprise/index.md | mechanism | Snapshot 是 point-in-time copy，基于 WAFL root inode 的元数据方式实现，不需要完整数据拷贝，并且可以在线创建。 | 备份/回滚语义应优先利用元数据级复制和 COW，而不是深拷贝活跃数据。 | A | None |

## Gaps
- 没有在本地快照中稳定定位到 Tencent-specific 的 Raft/RG 原文，因此目前第 8 主题中复制组证据主要由 TiKV / Ceph / FoundationDB 补足。
- CXL 和 Optane 的证据当前主要来自 index card 汇总，若需要严格的版本级论证，仍应回到更细的 upstream 原文快照。
- 主题 7 的 NUMA/PCIe 证据已经覆盖 DMA、cacheline、qpair 和内存介质模式，但还缺少更贴近真实生产拓扑的 NUMA placement 例证。
