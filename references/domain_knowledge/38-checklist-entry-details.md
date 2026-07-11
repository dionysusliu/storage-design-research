# Checklist Entry Details

生成时间：2026-07-11

本文件为 `../domain-map.md` 的逐项详解文档。主 checklist 保持扫描友好；本文件承接每个 entry 背后的解释、审查意图、证据来源和不可过度声明的边界。

使用规则：

- 每个 entry 都有稳定 anchor，供主 checklist 链接。
- `Evidence` 字段引用本轮研究目录中的已整理材料，不复制长篇网页正文。
- `Cannot claim yet` 用来阻止把 C/D 级材料写成机制事实。
- 后续如果要把 entry 拆成“一项一个文件”，应保留这些 anchor 作为迁移映射。

## Architecture Entry Details

<a id="arch-workload"></a>
### Architecture: Workload 与非目标

**解释**：存储系统的架构首先由 workload 决定，而不是由“高性能”“可靠”“通用”这类目标决定。AI 训练数据缓存、HPC checkpoint、对象存储、数据库 WAL、KV、文件系统、块存储和消息日志对读写比、对象大小、热点、租户、生命周期、尾延迟和恢复目标的压力完全不同。

**需要审查**：第一 workload、明确 non-goals、SLO 优先级、成本边界、地域边界、数据生命周期，以及哪些场景明确不承诺优化。

**Evidence**：`../domain-map.md` Gate 1；`../design_evidence/checklist-topic-evidence/01-goals-metadata.md`；`../domain-map.md` 的两段式立项模型。

**Cannot claim yet**：如果没有 trace、synthetic 参数或 workload matrix，不能声称系统“适合通用存储场景”。

<a id="arch-api-semantics"></a>
### Architecture: API 与语义边界

**解释**：API 决定系统承诺的可见性、一致性和错误语义。block/file/object/KV/table/transaction/snapshot 不是命名差异，而是不同的不变量集合。

**需要审查**：rename、overwrite、list、transaction、snapshot、consistency、错误码、retry/idempotency，以及哪些语义明确不承诺。

**Evidence**：`../domain-map.md` Gate 2；`../design_evidence/checklist-topic-evidence/01-goals-metadata.md`；Tencent source-document evidence 中 stale route、commit uncertainty、Write Fence 的路径说明。

**Cannot claim yet**：只说“兼容 S3/POSIX/事务”但没有逐项语义表和反例测试，不能视为已通过。

<a id="arch-metadata-truth"></a>
### Architecture: Metadata truth boundary

**解释**：metadata 是存储系统长期复杂度的集中点。owner、cache、schema、migration、lease、generation 和权限都会影响可见性、升级和恢复。

**需要审查**：authoritative metadata owner、shard key、cache 失效、schema 版本、mixed-version、权限元数据、placement metadata 的 source of truth。

**Evidence**：`../domain-map.md` Gate 2；Tencent source-document evidence 的 `DataObject -> Region -> Replication Group`、routing cache、stale route reject/refresh；`../design_evidence/source-document-evidence/README.md` Tencent 部分。

**Cannot claim yet**：metadata “可水平扩展”不等于 owner/cache/schema 语义清楚。

<a id="arch-layout-unit"></a>
### Architecture: 数据对象与分片边界

**解释**：layout unit 是系统把逻辑数据放到物理资源上的基本单位。block、extent、chunk、object、Region、PG、segment、SSTable 的选择会影响恢复、迁移、EC、热点和容量效率。

**需要审查**：逻辑对象到物理单位的映射、分片边界、大小上限、编码方式、split/merge、迁移单位和多层 layout 转换关系。

**Evidence**：`../domain-map.md` Gate 3；Tencent source-document evidence 对 Region/RG 的机制补证；Ceph source-document evidence 对 PG/recovery/backfill 的补证。

**Cannot claim yet**：多个 layout unit 混用但没有转换边界时，不能进入实现冻结。

<a id="arch-placement-failure-domain"></a>
### Architecture: Placement 与 failure domain

**解释**：placement 同时服务负载均衡、复制/EC、故障域、租户隔离和成本。一个只在正常状态下均衡的 placement 方案，故障、扩容或热点时可能失效。

**需要审查**：placement 决策者、输入、输出、版本、故障域、扩缩容重算规则、迁移量、热点/倾斜策略、容量水位。

**Evidence**：`../domain-map.md` Gate 3；Ceph source-document evidence recovery/backfill；Tencent source-document evidence RG/Region；`../design_evidence/checklist-topic-evidence/02-layout-paths.md`。

**Cannot claim yet**：静态放置图不能替代故障、扩容、缩容和热点下的 movement 验证。

<a id="arch-consensus-boundary"></a>
### Architecture: Replication group / consensus boundary

**解释**：复制组定义写入顺序、容错边界和恢复边界。leader/follower/learner/witness、quorum、route cache、fencing 和 retry uncertainty 是同一个一致性故事的一部分。

**需要审查**：复制组成员角色、leader 路由、fencing、commit/apply/visible 边界、retry/idempotency、restart replay、follower catch-up、split/merge 后路由变化。

**Evidence**：Tencent source-document evidence `tencent-raft-rg.md`；`../design_evidence/source-document-evidence/README.md` 的 Tencent 裁决。

**Cannot claim yet**：Tencent 材料没有充分证明 quorum 参数、election timeout、catch-up 细节、RTO/RPO，所以这些不能强写。

<a id="arch-recovery-rebalance"></a>
### Architecture: Recovery/backfill/rebalance 架构

**解释**：恢复、backfill、rebalance 不是运维附录，它们会决定系统在扩容、缩容、故障和容量水位变化时的真实稳态。

**需要审查**：迁移单位、触发条件、限速、容量水位、维护 flag、前台影响、回滚、kill switch、观测指标。

**Evidence**：Ceph source-document evidence `ceph-recovery-backfill.md`；`../design_evidence/source-document-evidence/README.md`；`../domain-map.md` Gate 3/6/8。

**Cannot claim yet**：只写“后台自动恢复”但没有 foreground P99、degraded 行为和容量水位，不能算架构完整。

<a id="arch-read-path"></a>
### Architecture: Read path

**解释**：读路径必须从 API 一直画到设备、缓存、网络、线程和 completion。模块框图不足以发现 copy、queue、cross-core completion、cache miss 和 remote read 的尾延迟来源。

**需要审查**：stage、owner、queue、cache、copy、network hop、device path、completion locality、miss path、retry path。

**Evidence**：`../domain-map.md` Gate 4；`../design_evidence/checklist-topic-evidence/03-io-queues.md`。

**Cannot claim yet**：只有端到端平均延迟，不能支持读路径架构冻结。

<a id="arch-write-path"></a>
### Architecture: Write path 与 ack/durable/visible

**解释**：写路径必须区分 ack、durable、visible、commit、apply 和 retry uncertainty。把这些点混成“写入成功”会掩盖 crash 后不可读、重复写、可见性乱序和恢复不一致。

**需要审查**：admission、stall/slowdown、WAL、replication、persist、commit、apply、ack、visible、fail-fast、crash points。

**Evidence**：RocksDB source-document evidence write stall；FoundationDB source-document evidence Ratekeeper；Tencent source-document evidence Write Fence / Raft log as WAL / commit uncertainty；`../domain-map.md` Gate 4/6。

**Cannot claim yet**：没有 power-loss、process crash、node crash 和 network partition 测试时，不能声称 durable 语义已验证。

<a id="arch-backpressure"></a>
### Architecture: Backpressure taxonomy

**解释**：背压不是“队列满了就慢”。它可以发生在 admission、software queue、device queue、replication、transaction start、background work 或 fail-fast policy。背压位置决定用户可见行为。

**需要审查**：reject/block/shed/degrade/retry/rate limit、queue bytes、queue age、released/limit rate、stall cause、stall mode、tenant fairness。

**Evidence**：RocksDB source-document evidence write stall；FoundationDB source-document evidence Ratekeeper；`../domain-map.md` Gate 4；`../design_evidence/checklist-topic-evidence/03-io-queues.md`。

**Cannot claim yet**：用 OOM、timeout 或无限排队作为隐式限流是红旗。

<a id="arch-programmatic-optimization"></a>
### Architecture: 程序化优化路线

**解释**：写成程序、改变执行路径或系统不变量的优化属于架构，而不是指标调参。cache tier、scheduler、admission controller、prefetcher、compaction policy、route cache、zero-copy、RDMA、GPU direct 都会改变系统工作方式。

**需要审查**：优化改变的路径、不变量、正确性风险、fallback、rollout/rollback、ablation 指标、tail impact。

**Evidence**：用户确认的“写成程序的都算架构”；`../domain-map.md` Optimization Boundary；DPDK source-document evidence；Tencent source-document evidence。

**Cannot claim yet**：只证明平均性能变好，不足以证明程序化优化可接受。

<a id="arch-io-stack"></a>
### Architecture: I/O 栈选择

**解释**：buffered I/O、direct I/O、io_uring、SPDK、DPDK、RDMA、NVMe-oF、CXL 不是纯性能选型。它们改变调度、内存、安全、错误恢复、部署和退出责任。

**需要审查**：选择理由、替代方案、退出策略、内核绕过后继承的新责任、driver/firmware/kernel 版本、部署条件。

**Evidence**：DPDK source-document evidence `dpdk-standalone.md`；`../design_evidence/source-document-evidence/README.md` DPDK 部分；`../domain-map.md` Gate 5。

**Cannot claim yet**：“SPDK/DPDK/io_uring 更快”不是 ADR。

<a id="arch-memory-hardware"></a>
### Architecture: Memory/hardware contract

**解释**：NUMA、PCIe、DMA buffer、IOMMU、hugepage、mempool/mbuf、IOVA、copy/cycles 是数据路径契约。它们改变能否部署、如何隔离、如何恢复和如何复现性能。

**需要审查**：buffer ownership、pin/register/reuse/release、hugepage 生命周期、IOVA/IOMMU 模式、NUMA locality、driver binding、mempool cache、copy budget。

**Evidence**：DPDK source-document evidence；CXL/Optane source-document evidence；`../design_evidence/checklist-topic-evidence/04-hardware-durability.md`；`../domain-map.md` Gate 5。

**Cannot claim yet**：目标环境未验证 hugepage、IOMMU、NUMA、driver binding 时，不能把实验结果直接外推到生产。

<a id="arch-hardware-lifecycle"></a>
### Architecture: Hardware lifecycle

**解释**：硬件名不是证据。NVMe、CXL、PMem、Optane、NIC、GPU direct、firmware 和 driver 都必须绑定版本、生命周期和供应状态。

**需要审查**：current/historical/obsolete、ratified/gated spec、firmware/driver matrix、RAS/security、poison/reset/reinit、供应和支持窗口。

**Evidence**：CXL/Optane source-document evidence；`../design_evidence/source-document-evidence/README.md` CXL 裁决；`../design_evidence/checklist-topic-evidence/04-hardware-durability.md`。

**Cannot claim yet**：Optane/PMem 当前只能作为 historical/legacy baseline；CXL Type-3 细节还不能强写。

<a id="arch-durability-consistency"></a>
### Architecture: Durability 与 consistency

**解释**：durable 和 consistent 必须被写成精确定义。page cache、WAL、media flush、quorum、remote object、snapshot、retry 和 idempotency 的组合决定 crash 后事实。

**需要审查**：durable point、一致性模型、retry/idempotency、版本窗口、partition 行为、read-your-writes、snapshot visibility。

**Evidence**：`../domain-map.md` Gate 6；Tencent source-document evidence；RocksDB source-document evidence；FoundationDB source-document evidence。

**Cannot claim yet**：没有 crash/fault injection 的 durable claim 只能降级。

<a id="arch-replication-ec-snapshot"></a>
### Architecture: Replication / EC / snapshot

**解释**：复制、EC、snapshot、backup 和 versioning 必须一起审。EC 可能改变小写路径，snapshot 可能改变 metadata 和 GC，backup 不是免费的强一致副本。

**需要审查**：primary/quorum/Raft/chain/CRUSH/EC policy、stripe、partial write、RMW、degraded read、snapshot restore、retention、delete。

**Evidence**：`../domain-map.md` Gate 6；Ceph source-document evidence；`../design_evidence/checklist-topic-evidence/04-hardware-durability.md`。

**Cannot claim yet**：把 snapshot 当免费备份或把 EC 当纯容量优化都是红旗。

<a id="arch-background-work"></a>
### Architecture: Background work model

**解释**：compaction、GC、scrub、rebuild、backfill、dedup、prefetch、lifecycle 会定义系统真实稳态。后台任务可能是前台 P99 的主因。

**需要审查**：任务清单、资源共享、priority、token、pause/resume、kill switch、foreground impact metric、scrub 和 recovery/backfill 是否分离。

**Evidence**：RocksDB source-document evidence；Ceph source-document evidence；`../domain-map.md` Gate 6。

**Cannot claim yet**：“低峰期执行”但没有限流和前台影响测试，不算设计。

<a id="arch-management-plane"></a>
### Architecture: Management plane

**解释**：管理面如果承载容量、指标、安全、自动化或 conformance，它就是架构边界。资源模型和数据面事实不一致会让运维和自动化失真。

**需要审查**：API 标准、resource model、capacity model、metrics object、source of truth、security、conformance profile。

**Evidence**：SNIA Swordfish source-document evidence；`../design_evidence/source-document-evidence/README.md` SNIA/Swordfish 部分；Redfish/Swordfish 关系、metrics 对象、安全/合规和 CTP conformance。

**Cannot claim yet**：声称兼容标准但没有版本、profile 或 conformance 证据，只能作为 claim risk。

<a id="arch-operability-lifecycle"></a>
### Architecture: Operability lifecycle

**解释**：部署、升级、回滚、mixed-version、release train、runbook 和退出策略必须设计内生化。存储系统最危险的失败往往是无法升级、无法恢复、无法退出。

**需要审查**：failure matrix、versioned degraded runbook、upgrade/rollback、schema/format migration、release train、TCO、exit ADR。

**Evidence**：`../domain-map.md` Gate 8；Ceph source-document evidence；CXL/Optane source-document evidence。

**Cannot claim yet**：HPE PSNow 当前只有 title-only/support-gated 材料，不能写成 failover/migration/rollback 机制。

<a id="arch-claim-policy"></a>
### Architecture: Claim policy

**解释**：claim policy 决定什么可以对外说。性能、可靠性、兼容性、成本和生命周期 claim 都必须绑定证据等级。

**需要审查**：claim、metric、hardware、software version、dataset、methodology、artifact、evidence level、known gap。

**Evidence**：fio source-document evidence；HPE source-document negative evidence；`../design_evidence/source-document-evidence/README.md` 不应回写为机制结论表。

**Cannot claim yet**：厂商数字、博客数字、support hub、title-only、登录页、404 不能被写成强事实。

## Metrics Entry Details

<a id="metric-workload"></a>
### Metrics: Workload representativeness

**解释**：指标必须证明 workload 代表真实系统，而不是一个最好看的单点。

**必须保留证据**：trace/synthetic 参数、读写比、对象大小、冷热、并发、租户、生命周期、parameter sweep。

**Evidence**：`../domain-map.md` Gate 1/7；`../design_evidence/checklist-topic-evidence/06-observability-benchmark-cost.md`。

<a id="metric-api-correctness"></a>
### Metrics: API semantic correctness

**解释**：API 正确性要用测试证明，不靠文档措辞。rename/list/overwrite/snapshot/transaction/error/retry 都需要正反例。

**必须保留证据**：semantic test suite、错误码矩阵、兼容性反例、mixed-version 语义测试。

**Evidence**：`../domain-map.md` Gate 2；Tencent source-document evidence retry uncertainty。

<a id="metric-metadata-correctness"></a>
### Metrics: Metadata correctness

**解释**：metadata 正确性覆盖 owner failover、cache stale、schema migration、routing/fencing 和权限变更。它经常比数据路径更容易制造长期事故。

**必须保留证据**：metadata migration test、stale cache test、owner failover、route invalidation、mixed-version rollback。

**Evidence**：Tencent source-document evidence；`../design_evidence/checklist-topic-evidence/01-goals-metadata.md`。

<a id="metric-placement-correctness"></a>
### Metrics: Placement correctness

**解释**：placement 正确性要在扩容、缩容、故障、热点和容量水位变化下验证，而不是只看均衡静态图。

**必须保留证据**：movement test、failure-domain injection、capacity watermark、skew/Zipf benchmark、rebalance impact。

**Evidence**：Ceph source-document evidence；Tencent source-document evidence；`../design_evidence/checklist-topic-evidence/02-layout-paths.md`。

<a id="metric-crash-durability"></a>
### Metrics: Crash/durability correctness

**解释**：durability 的核心指标是 ack 后发生 crash/power-loss/partition 时是否仍满足可读、可恢复、可解释。

**必须保留证据**：crash matrix、power-loss/fault injection、ack/durable/visible table、replay log。

**Evidence**：RocksDB source-document evidence；Tencent source-document evidence；`../domain-map.md` Gate 6。

<a id="metric-read-latency"></a>
### Metrics: Read path latency

**解释**：读延迟必须拆到 stage，才能知道慢在 cache、network、device、copy、queue 还是 completion。

**必须保留证据**：per-stage histogram、cache hit/miss、copy counters、completion route、single request trace。

**Evidence**：`../design_evidence/checklist-topic-evidence/03-io-queues.md`；`../domain-map.md` Gate 4/7。

<a id="metric-write-latency"></a>
### Metrics: Write path latency

**解释**：写延迟必须看 admission、stall、WAL、replication、persist、ack、visible 和 retry/fail-fast 分支。

**必须保留证据**：write trace、stall cause、queue age、crash point test、slowdown/fail-fast result。

**Evidence**：RocksDB source-document evidence；FoundationDB source-document evidence；Tencent source-document evidence。

<a id="metric-queue-backpressure"></a>
### Metrics: Queue/backpressure

**解释**：背压指标要能定位在哪一层开始保护系统，以及用户看到的是 reject、block、shed、degrade、retry 还是 fail-fast。

**必须保留证据**：QD、queue bytes、queue age、released/limit rate、oldest request、priority class、stall mode。

**Evidence**：FoundationDB Ratekeeper source-document evidence；RocksDB write stall source-document evidence。

<a id="metric-optimization-effectiveness"></a>
### Metrics: 程序化优化有效性

**解释**：程序化优化必须证明自己没有破坏正确性、恢复、隔离、可运营性和尾延迟。

**必须保留证据**：ablation、fallback test、rollout/rollback、correctness regression、tail impact、resource cost。

**Evidence**：`../domain-map.md`；DPDK source-document evidence；Tencent source-document evidence。

<a id="metric-performance-steady"></a>
### Metrics: Performance steady state

**解释**：稳态性能不是短跑峰值。存储系统常见问题来自 warmup 后的 compaction、GC、scrub、rebuild、backfill 和 cache churn。

**必须保留证据**：warmup、runtime、ramp_time、steadystate 判据、P50/P99/P999、long-run raw output。

**Evidence**：fio source-document evidence；`../domain-map.md` Gate 7。

<a id="metric-dpdk-deployment"></a>
### Metrics: DPDK / bypass deployment correctness

**解释**：DPDK/SPDK/用户态 bypass 的正确性包括能不能部署、是否隔离、是否版本绑定，而不只是 throughput。

**必须保留证据**：EAL 参数、hugepage、lcore、mempool/mbuf、IOVA/IOMMU、NUMA、driver binding、kernel boot args、bootstrap script。

**Evidence**：DPDK source-document evidence `dpdk-standalone.md`；`../design_evidence/source-document-evidence/README.md`。

**Cannot claim yet**：DPDK 当前证据绑定到取到的版本化文档；具体性能 claim 必须补 stable release drift 和目标环境实测。

<a id="metric-hardware-lifecycle"></a>
### Metrics: Hardware lifecycle validation

**解释**：硬件指标必须验证版本和生命周期，不然会把 historical 或 gated 材料误当成生产事实。

**必须保留证据**：spec version、firmware、driver、RAS/security、poison/fault injection、reset/reinit、供应状态。

**Evidence**：CXL/Optane source-document evidence；`../design_evidence/checklist-topic-evidence/04-hardware-durability.md`。

**Cannot claim yet**：CXL Type-3 状态机和 Optane 当前可用性仍是 gap。

<a id="metric-background-impact"></a>
### Metrics: Background impact

**解释**：后台任务影响必须在前台负载下测。只测后台任务吞吐无法证明系统可运营。

**必须保留证据**：foreground P99 under background load、compaction debt、recovery traffic、scrub/backfill separation、kill switch drill。

**Evidence**：RocksDB source-document evidence；Ceph source-document evidence。

<a id="metric-recovery-behavior"></a>
### Metrics: Recovery behavior

**解释**：恢复指标必须同时看 RTO/RPO、degraded read/write、rebuild/backfill speed 和前台影响。

**必须保留证据**：failure matrix、degraded benchmark、capacity watermark、recovery/backfill rate、operator steps。

**Evidence**：Ceph source-document evidence；Tencent source-document evidence restart replay。

<a id="metric-capacity-efficiency"></a>
### Metrics: Capacity efficiency

**解释**：容量效率不仅是 raw/effective ratio，还包括 metadata、EC、replication、compaction、lifecycle 和 small write amplification。

**必须保留证据**：effective capacity、replication/EC overhead、WAF/RAF/SAF、size sweep、capacity watermarks。

**Evidence**：`../design_evidence/checklist-topic-evidence/02-layout-paths.md`；`../design_evidence/checklist-topic-evidence/06-observability-benchmark-cost.md`。

<a id="metric-resource-efficiency"></a>
### Metrics: Resource efficiency

**解释**：资源效率说明性能是不是靠不可接受的 CPU、memory、NUMA remote、PCIe bandwidth 或 power 换来的。

**必须保留证据**：CPU/core reservation、memory footprint、NUMA remote ratio、PCIe counters、cycles/byte、perf/watt。

**Evidence**：DPDK source-document evidence；`../design_evidence/checklist-topic-evidence/04-hardware-durability.md`。

<a id="metric-cost-model"></a>
### Metrics: Cost model

**解释**：成本指标必须绑定 workload。每 TB、每 IOPS、每 GB/s、每 GPU feeding throughput 的成本可能指向不同架构。

**必须保留证据**：TCO sensitivity、device/CPU/network/power/operator cost、capacity efficiency、failure/recovery cost。

**Evidence**：`../design_evidence/checklist-topic-evidence/06-observability-benchmark-cost.md`；`../domain-map.md` Gate 8。

<a id="metric-management-observability"></a>
### Metrics: Management-plane observability

**解释**：管理面指标必须有对象归属、单位、采集周期、重置语义和 source of truth。否则 dashboard 会制造错误事实。

**必须保留证据**：resource model、metrics object、capacity object、conformance result、management API version。

**Evidence**：SNIA Swordfish source-document evidence；`../design_evidence/source-document-evidence/README.md`。

<a id="metric-observability-coverage"></a>
### Metrics: Observability coverage

**解释**：可观测性必须能定位 queue、device、network、replication、background 和 request lifecycle，而不是只看 CPU/磁盘。

**必须保留证据**：metrics、trace、logs、profiles、request ID、dashboard、alerts、alert drill。

**Evidence**：`../design_evidence/checklist-topic-evidence/06-observability-benchmark-cost.md`；SNIA Swordfish source-document evidence。

<a id="metric-benchmark-reproducibility"></a>
### Metrics: Benchmark reproducibility

**解释**：benchmark claim 必须可复跑、可审计、可比较。没有 job file、版本、raw output 和误差范围的图表不能支撑强 claim。

**必须保留证据**：fio version、job file hash、ioengine、direct/buffered、iodepth、numjobs、percentile definition、raw output。

**Evidence**：fio source-document evidence；`../design_evidence/source-document-evidence/README.md`；`../domain-map.md` Gate 7。

<a id="metric-security-isolation"></a>
### Metrics: Security/isolation

**解释**：用户态驱动、DMA、RDMA、VFIO、shared memory 和管理面 API 会扩大安全边界，必须有 containment 证据。

**必须保留证据**：quota、tenant isolation、IOMMU/VFIO/RDMA containment、bad buffer、noisy-neighbor、TLS/authN/authZ。

**Evidence**：DPDK source-document evidence；SNIA Swordfish source-document evidence；`../design_evidence/checklist-topic-evidence/06-observability-benchmark-cost.md`。

<a id="metric-operability"></a>
### Metrics: Operability

**解释**：可运营性要通过演练证明。部署、升级、回滚、config drift、runbook drill 都必须能被普通生产团队执行。

**必须保留证据**：deploy time、upgrade time、rollback success、mixed-version test、runbook drill、operator log。

**Evidence**：Ceph versioned degraded runbook；`../domain-map.md` Gate 8。

**Cannot claim yet**：HPE 相关运维机制仍没有正文证据。

<a id="metric-version-lifecycle"></a>
### Metrics: Version/lifecycle status

**解释**：版本状态是 claim policy 的基础。latest/dev、current、historical、obsolete、support-gated、title-only 必须分开。

**必须保留证据**：source status registry、doc version、release train、抓取状态、evidence level、known gaps。

**Evidence**：`source-inventory.md`；`download-gaps.md`；HPE/CXL/DPDK source-document evidence 裁决。

**Cannot claim yet**：`latest` 或标题入口不能被自动当作生产事实。
