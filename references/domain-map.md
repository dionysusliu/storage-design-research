# 存储系统设计检查表

生成时间：2026-07-11

本文件采用“架构 / 指标”作为最终主结构：

- `Architecture Checklist`：用于立项、架构冻结和周期性架构漂移审查。
- `Metrics Checklist`：用于细节冻结、周期审查、验收、发布和持续回归。

核心原则：架构轴回答系统“怎么工作、为什么这么工作、什么变化需要重审”；指标轴回答“架构承诺是否被正确、稳定、可复现地兑现”。写进程序、改变执行路径或系统不变量的优化方式，属于架构。

## Evidence Base

| 来源 | 用法 |
| --- | --- |
| `design_evidence/checklist-topic-evidence/` | 提供按 checklist 主题聚合的 evidence table。 |
| `design_evidence/source-document-evidence/` | 提供按具体来源文档聚合的机制证据、方法学证据和负证据边界。 |
| `design_evidence/web-snapshots/` | 提供 evidence 文件指向的已抓取网页快照。 |
| `domain_knowledge/38-checklist-entry-details.md` | 提供本文件中 Architecture / Metrics 每个核心 entry 的详解、审查意图、evidence 和不可声明边界。 |
| `domain_knowledge/source-inventory.md` / `domain_knowledge/download-gaps.md` | 提供来源状态、下载缺口和不可强声明材料。 |

## Evidence Levels

| 等级 | 可接受输入 | 使用方式 |
| --- | --- | --- |
| A | 官方规范、源码、版本化文档、设计文档、可复现实验、生产事故/运行数据 | 可写成强检查项。 |
| B | 工程博客、会议演讲、reference card、抓取正文中的机制说明 | 可写成设计压力或候选检查项。 |
| C | 产品页、support hub、动态首页、未给方法学的性能 claim | 只能作为线索、风险提示或待补证项。 |
| D | 抓取失败、登录页、404、过期页面、待核实人物/团队线索 | 只进入补证队列，不能写成机制事实。 |

## Review Flow

| 场景 | 第一步 | 第二步 | 输出裁决 |
| --- | --- | --- | --- |
| 新项目立项 | 先过 `Architecture Checklist`，确定大方向、边界、不变量和非目标。 | 再过 `Metrics Checklist`，确定验收指标、方法学和周期审查节奏。 | `通过立项` / `需补 ADR` / `暂缓立项` |
| 细节冻结 | 检查架构 ADR 是否完整，程序化优化路线是否已经归类。 | 检查指标定义、阈值、benchmark 方法学和故障注入是否可复现。 | `可进入实现` / `需补指标` / `需重审架构` |
| 周期审查 | 先做架构漂移检查。 | 再做指标状态检查。 | `继续` / `局部修正` / `触发架构重审` |
| 发布或论文 claim | 检查 claim 是否仍符合架构边界和证据等级。 | 检查 artifact、误差范围、版本和复现性。 | `可声明` / `降级表述` / `不可声明` |

## Architecture Checklist

架构项状态建议使用：

- `通过`：边界、取舍、产物和重审触发条件清楚。
- `需补 ADR`：方向大致成立，但缺决策记录、替代方案或退出策略。
- `触发重审`：当前实现、需求、硬件、工作负载或优化路线已经偏离原架构。
- `暂不适用`：明确说明为什么不适用，并记录重新启用条件。

| 架构项 | 详解 | 关键问题 | 必须产物 | 重审触发条件 | 证据锚点 |
| --- | --- | --- | --- | --- | --- |
| Workload 与非目标 | [详解](domain_knowledge/38-checklist-entry-details.md#arch-workload) | 系统首先服务什么 workload？明确不优化什么？首要 SLO 是吞吐、尾延迟、恢复、成本、一致性还是 GPU feeding？ | `workload-matrix.md`、`non-goals.md`、`success-contract.md` | 主 workload 变化；非目标变成必须支持；新 SLO 推翻原取舍。 | v1 Gate 1 |
| API 与语义边界 | [详解](domain_knowledge/38-checklist-entry-details.md#arch-api-semantics) | 对外承诺 block/file/object/KV/transaction/snapshot 中哪些语义？哪些语义明确不承诺？ | `api-semantics-contract.md`、semantic test list | 语义承诺扩大，如加入 POSIX rename、事务、强一致或更强 snapshot 语义。 | v1 Gate 2 |
| Metadata truth boundary | [详解](domain_knowledge/38-checklist-entry-details.md#arch-metadata-truth) | authoritative metadata owner、cache、schema、版本迁移在哪里？metadata cache 过期后用户可见行为是什么？ | `metadata-ownership-map.md`、schema version matrix、cache consistency table | owner/cache/schema 变化影响读写可见性、升级、回滚或权限判断。 | v1 Gate 2；Tencent |
| 数据对象与分片边界 | [详解](domain_knowledge/38-checklist-entry-details.md#arch-layout-unit) | 数据对象、分片、Region、placement group、segment、SSTable 等布局单位如何分层？ | layout glossary、logical-to-physical example | 布局单位改变，或多个单位混用且无转换边界。 | v1 Gate 3；Tencent Region/RG |
| Placement 与 failure domain | [详解](domain_knowledge/38-checklist-entry-details.md#arch-placement-failure-domain) | placement 如何同时满足负载均衡、复制、EC、故障域和租户隔离？placement 决策由谁做？ | `layout-placement-matrix.md`、placement decision table | placement/rebalance/failure-domain 变化，或硬件拓扑、区域、租户模型改变。 | v1 Gate 3；Ceph recovery/backfill；Tencent Region/RG |
| Replication group / consensus boundary | [详解](domain_knowledge/38-checklist-entry-details.md#arch-consensus-boundary) | 复制组、leader/follower/learner/witness、quorum、routing cache、fencing、retry uncertainty 如何定义？ | replication group ADR、route/fence/retry table | 复制组成员角色、ack 点、路由失效处理或 retry/idempotency 语义改变。 | Tencent Region/RG/Raft |
| Recovery/backfill/rebalance 架构 | [详解](domain_knowledge/38-checklist-entry-details.md#arch-recovery-rebalance) | 迁移单位、触发条件、容量水位、维护 flags、限速和回滚是什么？ | rebalance/recovery architecture note、capacity watermark policy | 扩容、缩容、故障恢复路径变成主路径或影响前台 SLO。 | Ceph recovery/backfill；v1 Gate 3/6/8 |
| Read path | [详解](domain_knowledge/38-checklist-entry-details.md#arch-read-path) | 一次读经过哪些线程、队列、缓存、网络、设备、内存复制和 completion route？ | `read-path-sequence.md` | 新缓存层、新 remote read、新 completion route 或跨核转发改变路径。 | v1 Gate 4 |
| Write path 与 ack/durable/visible | [详解](domain_knowledge/38-checklist-entry-details.md#arch-write-path) | 写请求何时 ack、durable、visible？有哪些 crash points、stall/fail-fast、retry uncertainty？ | `write-path-sequence.md`、crash point table | ack 点、WAL、replication quorum、flush/FUA/media persist、commit/apply/visible boundary 改变。 | v1 Gate 4/6；RocksDB write stall；Tencent transaction path |
| Backpressure taxonomy | [详解](domain_knowledge/38-checklist-entry-details.md#arch-backpressure) | 背压发生在 admission、queue、device、replication、background、transaction-start 还是 fail-fast？ | `queue-backpressure-budget.md` | 新增 scheduler、ratekeeper、admission controller、fail-fast 语义或后台限流策略。 | RocksDB write stall；FoundationDB Ratekeeper |
| 程序化优化路线 | [详解](domain_knowledge/38-checklist-entry-details.md#arch-programmatic-optimization) | 优化是否写进代码路径并改变系统怎么工作？它改变了什么路径、不变量、fallback 和回滚条件？ | `optimization-adr.md`：路径、不变量、fallback、ablation 指标 | 新增 cache tier、prefetcher、scheduler、compaction policy、route cache、zero-copy、RDMA、GPU direct path。 | 架构/指标模型；DPDK EAL；Tencent routing/fence |
| I/O 栈选择 | [详解](domain_knowledge/38-checklist-entry-details.md#arch-io-stack) | buffered/direct/io_uring/SPDK/DPDK/RDMA/NVMe-oF/CXL 为什么是正确路线？如何退出或降级？ | `io-stack-adr.md` | kernel path 与 bypass path 互换，或依赖新协议、驱动、firmware、硬件。 | v1 Gate 5；DPDK EAL |
| Memory/hardware contract | [详解](domain_knowledge/38-checklist-entry-details.md#arch-memory-hardware) | NUMA、PCIe、DMA buffer、IOMMU、hugepage、mempool/mbuf、IOVA、copy/cycles 约束是什么？ | `memory-hardware-contract.md`、deployment preflight | 设备拓扑、buffer ownership、DMA/RDMA/GPU direct、IOVA/IOMMU、hugepage 生命周期改变。 | DPDK EAL；CXL/Optane lifecycle |
| Hardware lifecycle | [详解](domain_knowledge/38-checklist-entry-details.md#arch-hardware-lifecycle) | NVMe/NVMe-oF/CXL/PMem/Optane 等硬件依赖的版本、生命周期、供应状态、firmware/driver matrix 是否清楚？ | hardware lifecycle matrix、firmware/driver matrix | 依赖从 current 变 historical/obsolete，或 gated spec 被当成生产事实。 | CXL/Optane lifecycle |
| Durability 与 consistency | [详解](domain_knowledge/38-checklist-entry-details.md#arch-durability-consistency) | durable point、一致性模型、retry/idempotency、版本窗口是什么？ | `durability-recovery-plan.md` | durable point、consistency、transaction/window、retry model 改变。 | v1 Gate 6；Tencent |
| Replication / EC / snapshot | [详解](domain_knowledge/38-checklist-entry-details.md#arch-replication-ec-snapshot) | 复制协议、EC、snapshot/backup/versioning 如何组合？ | replication/EC/snapshot ADR | quorum、EC policy、snapshot 语义、backup restore 行为改变。 | v1 Gate 6 |
| Background work model | [详解](domain_knowledge/38-checklist-entry-details.md#arch-background-work) | compaction、GC、scrub、rebuild、backfill、lifecycle 如何影响前台？ | background task inventory、throttle policy、scrub separation policy | 后台任务进入前台关键路径，或引入新 stall/degraded 行为。 | RocksDB write stall；Ceph recovery/backfill |
| Management plane | [详解](domain_knowledge/38-checklist-entry-details.md#arch-management-plane) | 管理 API 是否标准化？资源模型、容量模型、指标对象、安全/合规和 conformance 证据是什么？ | management API ADR、resource model、conformance evidence | 管理面成为自动化、运维、容量或安全的 source of truth，或标准兼容 claim 改变。 | SNIA Swordfish |
| Operability lifecycle | [详解](domain_knowledge/38-checklist-entry-details.md#arch-operability-lifecycle) | 部署、升级、回滚、mixed-version、runbook、release train、退出策略是什么？ | `operability-lifecycle-runbook.md`、exit ADR | mixed-version、rollback、vendor/hardware lock-in、release train 或 support lifecycle 改变。 | v1 Gate 8；Ceph recovery/backfill；CXL/Optane lifecycle |
| Claim policy | [详解](domain_knowledge/38-checklist-entry-details.md#arch-claim-policy) | 什么性能/可靠性/成本/兼容性 claim 可以对外说？证据等级是什么？ | claim policy、evidence-level table | claim 超出 artifact 或证据等级；厂商/博客数字、title-only 材料被当事实。 | fio methodology；HPE support-gated gap |

## Architecture Drift Review

周期审查时先跑这一张表。如果任一项为 `触发重审`，应先重审架构，再看指标。

| 漂移问题 | 典型信号 | 裁决 |
| --- | --- | --- |
| Workload 漂移 | 新 workload 占主流量，原 workload matrix 不再代表真实系统。 | 触发架构重审 |
| 语义漂移 | 用户开始依赖未承诺的 rename/list/transaction/snapshot 行为。 | 触发 API/semantic ADR 重审 |
| Metadata 漂移 | cache、owner、schema migration 改变可见性、权限或升级路径。 | 触发 metadata ADR 重审 |
| Placement 漂移 | 新硬件、拓扑、区域、tenant model 改变 failure domain。 | 触发布局和 failure-domain 重审 |
| 优化路线漂移 | 调参演变成新 scheduler、route cache、cache tier、admission controller、recovery policy。 | 触发 optimization ADR |
| I/O 栈漂移 | kernel path、DPDK、SPDK、RDMA、CXL、GPU direct 路线变化。 | 触发 I/O stack ADR 重审 |
| Durability 漂移 | ack 点、quorum、flush、WAL、commit/apply/visible 或 recovery semantics 改变。 | 触发 crash model 重审 |
| 管理面漂移 | 管理 API 从辅助入口变成容量、安全、指标或自动化 source of truth。 | 触发 management-plane ADR |
| 运维漂移 | 部署、升级、回滚、自动化、release train、硬件生命周期变化。 | 触发 lifecycle/runbook 重审 |

## Metrics Checklist

指标项状态建议使用：

- `green`：达标，方法学可信，趋势稳定。
- `yellow`：接近阈值、趋势变差或方法学仍有缺口。
- `red`：失败，影响架构承诺、发布、论文 claim 或上线条件。
- `gray`：没有可复现数据，不能视为已验证。

| 指标项 | 详解 | 必须记录 | 最低验证动作 | 红旗信号 | 对应架构承诺 |
| --- | --- | --- | --- | --- | --- |
| Workload representativeness | [详解](domain_knowledge/38-checklist-entry-details.md#metric-workload) | trace/synthetic 参数、读写比、对象大小、冷热、并发、租户、生命周期 | trace replay 或 parameter sweep | 只测一个最佳点，不能代表真实流量。 | Workload 与 SLO |
| API semantic correctness | [详解](domain_knowledge/38-checklist-entry-details.md#metric-api-correctness) | rename/list/overwrite/snapshot/transaction/error/retry 行为 | semantic test suite | 文档承诺和实际行为不一致。 | API 与语义边界 |
| Metadata correctness | [详解](domain_knowledge/38-checklist-entry-details.md#metric-metadata-correctness) | owner failover、cache stale、schema migration、mixed-version、routing cache、fencing | metadata migration + stale cache tests | 元数据快但升级、回滚、路由失效不可控。 | Metadata truth boundary |
| Placement correctness | [详解](domain_knowledge/38-checklist-entry-details.md#metric-placement-correctness) | placement 版本、failure domain、skew、region/PG movement、capacity watermarks | expansion/shrink/failure movement tests | 扩容、故障或热点时数据移动不可解释。 | Layout / placement |
| Crash/durability correctness | [详解](domain_knowledge/38-checklist-entry-details.md#metric-crash-durability) | ack 后 crash、power-loss、network partition、commit/apply/visible boundary | crash/power-loss/fault injection | 客户端成功返回但恢复后不可读，或 ack/durable/visible 混为一谈。 | Durability |
| Read path latency | [详解](domain_knowledge/38-checklist-entry-details.md#metric-read-latency) | per-stage read latency、cache hit/miss、copy、completion route | end-to-end trace + histogram | 只有总延迟，看不到慢在哪段。 | Read path |
| Write path latency | [详解](domain_knowledge/38-checklist-entry-details.md#metric-write-latency) | admission、stall/slowdown、WAL、replication、persist、ack、visible | write path trace + crash points | 写延迟平均值好，但 stall/fail-fast/retry uncertainty 不可见。 | Write path |
| Queue/backpressure | [详解](domain_knowledge/38-checklist-entry-details.md#metric-queue-backpressure) | QD、queue bytes、queue age、released/limit rate、stall cause/mode、admission state | overload test + queue dashboard | 队列无限增长，用 OOM/timeout 当限流。 | Backpressure taxonomy |
| 程序化优化有效性 | [详解](domain_knowledge/38-checklist-entry-details.md#metric-optimization-effectiveness) | ablation、fallback、rollout/rollback、正确性回归、tail impact | A/B test 或 ablation test | 优化让平均值变好但破坏一致性、恢复、隔离或尾延迟。 | Optimization ADR |
| Performance steady state | [详解](domain_knowledge/38-checklist-entry-details.md#metric-performance-steady) | throughput、P50/P99/P999、warmup、runtime、steadystate | long-run benchmark | 几分钟测试掩盖 compaction、GC、recovery、backfill。 | SLO 与 workload |
| DPDK / bypass deployment correctness | [详解](domain_knowledge/38-checklist-entry-details.md#metric-dpdk-deployment) | EAL 参数、hugepage、lcore、mempool/mbuf、IOVA/IOMMU、NUMA、driver binding、kernel boot args | bootstrap rehearsal + topology/preflight script | 实验室能跑，生产节点装不上；版本漂移后性能或安全语义改变。 | I/O stack / hardware |
| Hardware lifecycle validation | [详解](domain_knowledge/38-checklist-entry-details.md#metric-hardware-lifecycle) | spec version、firmware、driver、RAS/security、poison/fault injection、reset/reinit、供应状态 | versioned hardware test matrix | 历史 Optane/PMem、gated CXL spec 或 vendor page 被当成当前事实。 | Hardware lifecycle |
| Background impact | [详解](domain_knowledge/38-checklist-entry-details.md#metric-background-impact) | compaction、GC、scrub、rebuild、backfill、lifecycle 对前台影响 | foreground P99 under background load | 后台任务“低峰执行”但没有限流、kill switch、stall cause。 | Background work model |
| Recovery behavior | [详解](domain_knowledge/38-checklist-entry-details.md#metric-recovery-behavior) | RTO/RPO、degraded read/write、rebuild/backfill speed、foreground impact | failure matrix + degraded benchmark | 快速恢复压垮前台，或容量水位阻断恢复。 | Recovery/backfill 架构 |
| Capacity efficiency | [详解](domain_knowledge/38-checklist-entry-details.md#metric-capacity-efficiency) | effective capacity、replication/EC overhead、metadata overhead、WAF/RAF/SAF | size sweep + long-run amplification measurement | 逻辑小写触发巨大 EC/RMW/compaction 放大。 | Layout / EC / lifecycle |
| Resource efficiency | [详解](domain_knowledge/38-checklist-entry-details.md#metric-resource-efficiency) | CPU、memory、NUMA remote ratio、PCIe bandwidth、cycles/byte、power | perf profile + topology counters | 性能靠不可接受的 core、power、remote memory 换来。 | I/O stack / hardware |
| Cost model | [详解](domain_knowledge/38-checklist-entry-details.md#metric-cost-model) | per TB、per IOPS、per GB/s、per GPU feeding、operator cost | TCO sensitivity analysis | 只比较设备峰值，不比较系统总成本。 | Workload / lifecycle |
| Management-plane observability | [详解](domain_knowledge/38-checklist-entry-details.md#metric-management-observability) | resource model、metrics object、source of truth、采集周期、单位、重置语义 | dashboard rehearsal + conformance check | 管理面指标和数据面事实不一致，或兼容标准无 conformance 证据。 | Management plane |
| Observability coverage | [详解](domain_knowledge/38-checklist-entry-details.md#metric-observability-coverage) | metrics、trace、logs、profiles、request ID、dashboard、alerts | dashboard rehearsal + alert drill | 看得到 CPU/磁盘，看不到 queue/background/replication。 | Claim/observability policy |
| Benchmark reproducibility | [详解](domain_knowledge/38-checklist-entry-details.md#metric-benchmark-reproducibility) | fio version、job file hash、ioengine、direct/buffered、iodepth、numjobs、percentile definition | artifact replay | 没有 job file、版本、raw output 或误差范围。 | Claim policy |
| Security/isolation | [详解](domain_knowledge/38-checklist-entry-details.md#metric-security-isolation) | quota、tenant isolation、IOMMU/VFIO/RDMA/DMA containment、bad buffer tests、TLS/authN/authZ | noisy-neighbor + containment tests | kernel bypass 或管理面扩大攻击面但未审计。 | I/O stack / multi-tenant / management plane |
| Operability | [详解](domain_knowledge/38-checklist-entry-details.md#metric-operability) | deploy time、upgrade time、rollback success、config drift、runbook drill | deployment/upgrade/rollback rehearsal | 只有专家能部署，升级后无法回滚。 | Lifecycle/runbook |
| Version/lifecycle status | [详解](domain_knowledge/38-checklist-entry-details.md#metric-version-lifecycle) | current/historical/obsolete/latest/dev、release train、doc version、evidence level | source status registry | `latest`、title-only、历史文档或 support hub 被当作生产事实。 | Lifecycle / claim policy |

## Universal Metrics

以下通用指标不允许被完全跳过。可以按阶段裁剪深度，但必须有最低讨论。

| 通用指标 | 最低立项讨论 | 周期审查必须看 |
| --- | --- | --- |
| 数据正确性 | durable、visible、recoverable 的定义。 | semantic/crash/consistency 测试是否仍通过。 |
| 可用性与恢复 | 故障类型、RTO/RPO、degraded mode。 | 故障演练、rebuild/backfill 前台影响。 |
| 性能与尾延迟 | 核心 workload 的 P99/P999 和稳态窗口。 | 分阶段 latency、queue、stall、background impact。 |
| 容量效率与写放大 | 复制/EC/metadata/compaction 额外成本模型。 | WAF/RAF/SAF、capacity watermarks、lifecycle cost。 |
| 成本与功耗 | 单位 TB、IOPS、GB/s、GPU feeding 的成本边界。 | TCO、perf/watt、cycles/byte、core reservation。 |
| 可运营性 | 部署、升级、回滚、扩容、缩容、替换路径。 | runbook drill、mixed-version、rollback rehearsal。 |
| 可观测性 | 必须能定位关键路径与失败原因。 | dashboard、alert、trace coverage 是否有效。 |
| 安全与隔离 | 权限、租户、DMA/RDMA/VFIO/用户态驱动边界。 | noisy-neighbor、bad buffer、containment tests。 |
| 可复现性 | benchmark 方法学和 artifact 计划。 | job file、版本、raw output、误差范围可复跑。 |

## Metrics Status Template

周期审查建议每个指标用同一格式记录：

| 字段 | 含义 |
| --- | --- |
| `metric` | 指标名称。 |
| `architecture_link` | 对应架构承诺或 ADR。 |
| `target` | 目标阈值或趋势。 |
| `current` | 当前数值或状态。 |
| `methodology` | 方法学、工具版本、job file、采样窗口。 |
| `evidence` | raw output、dashboard、trace、test report、runbook drill。 |
| `status` | `green` / `yellow` / `red` / `gray`。 |
| `risk` | 当前风险。 |
| `next_action` | 下一周期动作。 |

## Cross-Gate Mandatory Artifacts

| Artifact | 覆盖轴 | 最低要求 |
| --- | --- | --- |
| `workload-matrix.md` | 架构 + 指标 | workload、SLO、非目标、成本边界、trace/synthetic 参数。 |
| `api-semantics-contract.md` | 架构 + 指标 | API 行为、可见性、一致性、错误码、重试语义。 |
| `metadata-ownership-map.md` | 架构 + 指标 | owner、shard/Region、cache、schema、迁移、失效、routing/fencing。 |
| `layout-placement-matrix.md` | 架构 + 指标 | layout unit、placement、replication、EC、failure domain、migration/backfill trigger、capacity watermarks。 |
| `read-path-sequence.md` | 架构 + 指标 | stage、thread、queue、cache、copy、completion、metrics。 |
| `write-path-sequence.md` | 架构 + 指标 | admission、stall/slowdown、WAL/replica/persist/commit/ack/visible、retry/fail-fast、crash points。 |
| `queue-backpressure-budget.md` | 架构 + 指标 | QD、queue bytes、queue age、released/limit rate、stall cause、stall mode、background share、priority、reject/block/shed/degrade/fail-fast。 |
| `optimization-adr.md` | 架构 + 指标 | 程序化优化改变的路径、不变量、fallback、ablation、rollout/rollback。 |
| `io-stack-adr.md` | 架构 + 指标 | I/O 选型、绕过内核责任、版本、部署前置条件、退出路径。 |
| `memory-hardware-contract.md` | 架构 + 指标 | NUMA/PCIe、DMA buffer、IOMMU、hugepage、IOVA、mempool/mbuf、copy/cycles budget。 |
| `hardware-lifecycle-matrix.md` | 架构 + 指标 | hardware/spec/firmware/driver/status、current/historical/obsolete、RAS/security test。 |
| `durability-recovery-plan.md` | 架构 + 指标 | durable point、一致性、复制/EC、故障恢复、后台任务、background throttle、scrub separation。 |
| `management-plane-contract.md` | 架构 + 指标 | resource model、API/version、metrics object、security、conformance。 |
| `observability-benchmark-artifact.md` | 指标 | metrics、traces、benchmark matrix、fio job file/hash、artifact、claim evidence level、percentile definition。 |
| `operability-lifecycle-runbook.md` | 架构 + 指标 | failure matrix、versioned degraded runbook、upgrade、rollback、TCO、lifecycle/status、exit strategy。 |

## Open Evidence Gaps

这些缺口不阻塞采用本 checklist 主结构，但会限制具体 claim 的强度。

| 优先级 | 缺口 | 当前裁决 | 影响 |
| --- | --- | --- | --- |
| HPE PSNow / Alletra | HPE PSNow PDF 正文、controller failover、Alletra/Nimble architecture、transition/migration、upgrade/rollback。 | 只能作为 title-only / support-gated gap；不能写成机制事实。 | Gate 8 / lifecycle / claim policy |
| CXL | CXL normative spec 或公开 profile/ECN 摘要，Type-3、poison/reset/security state machine。 | CXL 版本、层次模型、RAS/security 方向可写；Type-3 细节不能强写。 | Gate 5 / hardware lifecycle |
| Optane / PMem | Intel 官方生命周期、支持矩阵、PCN 或替代正式资料。 | Optane/PMem 仅作为 historical / legacy baseline。 | Gate 5 / Gate 8 |
| DPDK | rc 文档与 stable release 参数、release-note drift、目标环境 hugepage/IOMMU/NUMA 实测。 | DPDK 机制可写；具体部署和性能 claim 必须版本绑定。 | Gate 5 / Gate 7 |
| P2-QoS | 多租户 quota、IOPS/bandwidth/cache isolation、noisy-neighbor 测试。 | 仍需专题补证。 | Metrics / security / isolation |
| P2-CI | 性能回归 CI、硬件池、噪声控制、阈值、基线管理。 | 仍需专题补证。 | Benchmark reproducibility |

## Maintenance Notes

维护本检查表时建议遵守以下策略：

1. 保留本文件的 `Evidence Levels`、`Review Flow`、`Architecture Checklist`、`Architecture Drift Review`、`Metrics Checklist`、`Universal Metrics`、`Metrics Status Template`、`Cross-Gate Mandatory Artifacts`、`Open Evidence Gaps`。
2. 不在主 checklist 暴露旧 8-gate 为主结构；8-gate 仅作为内部映射和证据来源。
3. 保留 Architecture / Metrics entry 到 `domain_knowledge/38-checklist-entry-details.md` 的链接，使主表每一项都能跳到对应详解和 evidence。
4. 将 `Open Evidence Gaps` 保留在文档末尾，防止后续把 HPE/CXL/Optane/DPDK 的未证实部分误写成事实。
5. 暂不把参考资料全文搬进主 checklist；主 checklist 只保留证据等级和证据锚点，详细材料留在 `references/design_evidence/`。
