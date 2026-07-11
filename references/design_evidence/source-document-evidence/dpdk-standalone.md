# DPDK Standalone 证据补齐

生成时间：2026-07-11

本文只整理 DPDK 官方版本化文档中的 standalone 机制证据，不把 SPDK 混写进主证据链。当前取证基线是 DPDK `26.07.0-rc2` 文档站点，release notes 索引同时列出了 `26.07 / 26.03 / 25.11 / 25.07 ...` 等历史版本，说明这里拿到的是明确版本化、可追踪的官方资料，而不是动态首页摘要。

## Source Inventory

| local_ref | 官方 URL | 来源类型 | 证据等级 | 已抓取正文 | 生命周期状态 | 备注 |
| --- | --- | --- | --- | --- | --- | --- |
| `dpdk-docs-index` | https://doc.dpdk.org/guides/index.html | 官方文档索引 | B | 是 | current / rc2 | 用于确认站点版本与章节入口 |
| `linux-gsg-sys-req` | https://doc.dpdk.org/guides/linux_gsg/sys_reqs.html | Linux getting started guide | B | 是 | current / rc2 | 系统软件、kernel config、hugepage、NUMA 前置条件 |
| `linux-gsg-eal-params` | https://doc.dpdk.org/guides/linux_gsg/linux_eal_parameters.html | Linux getting started guide | A | 是 | current / rc2 | EAL 启动参数主来源 |
| `linux-gsg-drivers` | https://doc.dpdk.org/guides/linux_gsg/linux_drivers.html | Linux getting started guide | A | 是 | current / rc2 | VFIO / UIO / driver binding / no-IOMMU |
| `linux-gsg-enable-func` | https://doc.dpdk.org/guides/linux_gsg/enable_func.html | Linux getting started guide | B | 是 | current / rc2 | 非 root、hugepage 权限、capabilities |
| `linux-gsg-intel-perf` | https://doc.dpdk.org/guides/linux_gsg/nic_perf_intel_platform.html | Linux getting started guide | B | 是 | current / rc2 | boot cmdline、hugepage、isolcpus、VT-d 建议 |
| `prog-guide-eal` | https://doc.dpdk.org/guides/prog_guide/env_abstraction_layer.html | Programmer’s Guide | A | 是 | current / rc2 | EAL、memory mapping、IOVA、lcore、NUMA、polling |
| `prog-guide-thread-safety` | https://doc.dpdk.org/guides/prog_guide/thread_safety.html | Programmer’s Guide | A | 是 | current / rc2 | 单线程/每 lcore、PMD RX/TX、锁与线程安全 |
| `prog-guide-lcore-var` | https://doc.dpdk.org/guides/prog_guide/lcore_var.html | Programmer’s Guide | A | 是 | current / rc2 | per-lcore state / false sharing / TLS 对比 |
| `prog-guide-mempool` | https://doc.dpdk.org/guides/prog_guide/mempool_lib.html | Programmer’s Guide | A | 是 | current / rc2 | fixed-size allocator、per-core cache、channel alignment |
| `prog-guide-mbuf` | https://doc.dpdk.org/guides/prog_guide/mbuf_lib.html | Programmer’s Guide | A | 是 | current / rc2 | mbuf 结构、headroom、origin pool、buffer chaining |
| `prog-guide-service-cores` | https://doc.dpdk.org/guides/prog_guide/service_cores.html | Programmer’s Guide | B | 是 | current / rc2 | service core 作为 EAL 内建调度/后台执行模型 |
| `rel-notes-index` | https://doc.dpdk.org/guides/rel_notes/index.html | Release notes 索引 | B | 是 | current / rc2 + archive | 用于版本上下文与历史范围 |
| `rel-notes-26.07` | https://doc.dpdk.org/guides/rel_notes/release_26_07.html | Release notes | C | 是 | 26.07 rc 系列 | 版本差异：`--pagesz-mem`、`--no-auto-probing`、mempool cache 行为变化 |

## Mechanism Notes

### 1) EAL 启动参数

- DPDK 应用通过 EAL 接收一组启动参数，这些参数直接决定线程绑定、设备探测、内存布局、IOVA 模式和共享内存行为。
- `--lcores` / `-l`：把 lcore 映射到 CPU 或 CPU set；`-R` 可把 lcore id 重新映射为连续编号；`--main-lcore` 指定主 lcore；`-S` 可把部分 core 切成 service cores。
- 设备相关参数里，`--no-auto-probing` / `--auto-probing` 控制是否在 `rte_eal_init` 时自动探测总线设备；`-a` / `-b` 控制 allow/block list；`--vdev` 支持虚拟设备；`--driver-path` 可加载外部驱动。
- 内存相关参数里，`--legacy-mem`、`--in-memory`、`--no-huge`、`--numa-mem`、`--numa-limit`、`--pagesz-mem`、`--huge-dir`、`--huge-unlink`、`--single-file-segments`、`--iova-mode` 都是会改变运行时内存与地址模型的硬开关。

### 2) Hugepage

- DPDK 以 hugepage 作为大块连续物理内存的基础。EAL 通过 hugepage 进行内存映射和 memzone/mempool 分配。
- `rte_malloc` 的内存分配默认也依赖 hugepage，除非显式使用 `--no-huge`。
- 动态内存模式会按需增长/收缩 hugepage；legacy 模式会在启动时预留全部所需内存并保持 IOVA-contiguous chunk。
- Linux 上 hugepage 既可以运行时预留，也可以 boot-time 预留；对 64-bit 场景，官方文档建议平台支持时优先考虑 1G hugepage。
- `--in-memory` 可以绕开 hugetlbfs 目录和文件访问；但一旦需要 secondary process，就仍需要共享 hugepage 文件/挂载点。
- `--huge-unlink=never` 能复用“脏” hugepage，提高重启速度，但会引入历史数据残留的安全风险。

### 3) lcore

- DPDK 的运行时通常是“每个 logical core 一个线程”的模型。EAL thread 本质上是 pthread，`lcore` 只是 DPDK 对执行单元的抽象。
- lcore 变量用于 per-thread/per-lcore 状态，避免把状态暴露到公共 API。与 TLS 相比，lcore 变量可在分配后更早使用，也更适合 DPDK 的 thread model。
- `--lcores` 允许一个 lcore 绑定单个 CPU 或 CPU set，因此 lcore id 与物理 CPU id 不必一一相等。
- `service cores` 是 EAL 内建概念：把某些 lcore 从应用 lcores 中分离出来，用于运行需要 CPU 周期的服务或软件 PMD 调度。

### 4) Polling / 轮询模型

- DPDK 文档明确指出运行时“几乎完全在 Linux user space 中以 polling mode 工作”。
- PMD 的 RX/TX 是性能关键路径，官方建议避免锁；同一个硬件队列若被多线程共享，则必须加锁或做互斥。
- 事件/中断不是主路径，主要用于 link status change、device removal 这类低频事件；EAL 也提供 interrupt host thread 和 epoll/kqueue 风格的事件模式。
- 这意味着 DPDK 的默认设计不是“事件驱动 I/O”，而是“固定线程 + 忙轮询 + 低频事件旁路”。

### 5) mempool / mbuf

- mempool 是固定大小对象的分配器，默认后端是 ring-based，并提供 per-core cache 和对象对齐辅助，帮助对象在 DRAM channels/ranks 间更均匀分布。
- per-core cache 的目标是减少对 ring 的 CAS/lock 压力，牺牲少量缓存驻留来换取更高吞吐。
- mbuf 是 packet buffer 的基本载体，头部尽量小，当前使用两个 64-byte cache line；buffer chaining 允许 jumbo frame 或长包跨多个 mbuf。
- mbuf 被释放时会回到原始 mempool；`rte_pktmbuf_init()` 会设置 origin pool、buffer start address 等不可变字段。

### 6) IOVA / IOMMU

- Linux 上 EAL 会按总线需求和 IOMMU / physical address 可用性来推导 IOVA 模式：可能是 `RTE_IOVA_PA`、`RTE_IOVA_VA` 或 `RTE_IOVA_DC`。
- 如果总线之间对 IOVA 需求冲突，EAL 可能让部分 bus 失效，这意味着 IOVA 模式不是纯“性能选项”，而是设备可用性的前置条件。
- `--iova-mode=pa|va` 可强制指定模式；官方也明确说某些 PCI driver 只能在 VA 模式下工作，需要 `RTE_PCI_DRV_NEED_IOVA_AS_VA`。
- VFIO 依赖 IOMMU 保护；如果没有 IOMMU，可以启用 no-IOMMU mode，但官方把它标为 inherently unsafe。

### 7) NUMA

- 官方文档把 NUMA 当成运行前必须理解的硬件约束：`--numa-mem`、`--numa-limit`、`rte_malloc` 的 socket-local 语义、mempool 的 channel/rank 对齐，都会影响内存和性能。
- `rte_malloc()` 在 NUMA 系统上通常会返回调用 core 所在 socket 上的内存；内部 heap 也是按 NUMA node 组织。
- hugepage 预留可以按 NUMA node 做定向配置，Intel 性能文档还建议把 NIC 放在同一 CPU socket，并用 `isolcpus` 隔离 DPDK cores。

### 8) driver binding

- 大多数 PMD 需要在运行前把硬件从原 kernel driver 解绑，再绑定到 `vfio-pci`；否则硬件会继续被 Linux kernel 控制，DPDK 无法使用。
- 官方工具是 `usertools/dpdk-devbind.py`，它支持查看状态、bind/unbind、也支持回绑到原 kernel driver。
- `vfio-pci` 是官方优先推荐；如果 vfio 不可用，再退回 UIO (`igb_uio` / `uio_pci_generic`)。
- 某些场景下，IOMMU group、bridge 绑定关系会影响能否成功绑定，PCI bridge 可能也要一并解绑。

### 9) deployment preconditions

- Linux 运行前提包括：kernel >= 5.4、glibc >= 2.7（cpuset 相关）、HUGETLBFS、PROC_PAGE_MONITOR；某些附加功能还要求 HPET/HPET_MMAP。
- 非 root 运行时，hugepages 需要先由 root 预留；如果不是 `--in-memory`，hugepage mount point 及其文件权限也要可写。
- 如果 driver 需要 physical addresses，还要给可执行文件额外 capabilities：至少涉及 `DAC_READ_SEARCH`、`SYS_ADMIN`、`IPC_LOCK`。
- Intel 性能文档还建议：boot cmdline 预留 hugepages、隔离 DPDK CPU core、启用 VT-d / `intel_iommu=on` / `iommu=pt`。

## Checklist Impact

### Architecture Checklist

- `I/O stack 选择`：DPDK 明确是 kernel bypass / user-space polling 路线，EAL + VFIO/UIO + PMD binding 已经把执行路径写死到架构层，必须走 `I/O stack ADR`。
- `Memory/hardware contract`：hugepage、NUMA、IOMMU、IOVA 模式、DMA mapping、CPU/socket 拓扑都属于硬件契约，不是单纯参数调优。
- `Read path / Write path / Queue budget`：polling、per-lcore 绑定、service core、锁规避、queue 级 RX/TX 共享规则，会直接决定 queue/backpressure 设计。
- `Operability lifecycle`：root 权限、driver binding、hugepage 预留、boot cmdline、VFIO no-IOMMU 风险，属于 deployment preflight / lifecycle / exit strategy。
- `Claim policy`：release notes 已经说明 mempool cache 行为会变；任何性能 claim 都必须带版本标签，否则会落入“文档没变但行为变了”的陷阱。

### Metrics Checklist

- `性能与尾延迟`：polling 模型、mempool cache、lcore pinning、NUMA locality 都会影响 P99/P999，需要稳定工作负载下的指标。
- `可复现性`：DPDK release notes 对 mempool cache 语义、`--pagesz-mem`、`--no-auto-probing` 的新增/变化，要求 benchmark job file 和版本号一起记录。
- `资源效率`：CPU、NUMA remote ratio、PCIe / DMA 路径、hugepage footprint、IOMMU 模式，都属于资源效率指标。
- `可运营性`：deployment preflight、`dpdk-devbind.py`、hugepage mount、权限、kernel boot args 需要进入验收清单，而不是只写在 runbook 备注里。

## Open Gaps

- 版本差异仍需补齐：当前主证据是 `26.07.0-rc2`，需要再对照稳定版 `26.07` 和至少一个前一稳定版（如 `25.11`）确认哪些行为只是 release-note 级变化，哪些是长期稳定语义。
- 目标环境实验仍缺：hugepage 大小、NUMA 拓扑、IOMMU 开关、vfio-noiommu、队列数/绑核方式对目标机的实际影响还没有跑实验。
- `SPDK / DPDK` 兼容窗口仍需独立补证：如果后续要把这份 standalone 证据接到 SPDK 证据卡，需要同时锁定双方版本范围和互操作前提。
- release notes 里已经出现 mempool cache 行为变化；如果要做历史对比，需要把 old/new cache 配置和测试方法一起固定。

## Evidence Table

| check_item | source | local_ref | evidence_type | evidence_note | design_pressure | confidence | gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| EAL 启动模型 | [EAL Library](https://doc.dpdk.org/guides/prog_guide/env_abstraction_layer.html) | `prog-guide-eal` | direct_doc | EAL 负责加载、core affinity、memory reservation、trace/debug、interrupt、alarm | I/O stack ADR、memory/hardware contract | A | 需对照稳定版确认参数是否完全一致 |
| EAL 启动参数 | [Linux EAL parameters](https://doc.dpdk.org/guides/linux_gsg/linux_eal_parameters.html) | `linux-gsg-eal-params` | direct_doc | `--lcores`、`--main-lcore`、`--legacy-mem`、`--numa-mem`、`--iova-mode`、`--huge-dir`、`--huge-unlink` 等直接改变运行时模型 | queue/polling/backpressure、deployment preflight | A | 需补 old/new 参数差异 |
| Hugepage 机制 | [System Requirements](https://doc.dpdk.org/guides/linux_gsg/sys_reqs.html) / [EAL Library](https://doc.dpdk.org/guides/prog_guide/env_abstraction_layer.html) / [Linux EAL parameters](https://doc.dpdk.org/guides/linux_gsg/linux_eal_parameters.html) | `linux-gsg-sys-req` / `prog-guide-eal` / `linux-gsg-eal-params` | direct_doc | hugepage 是大块连续物理内存基础；动态/legacy 两种模式；1G hugepage、`--in-memory`、`--huge-unlink` 都会影响生命周期与安全 | memory/hardware contract、deployment preflight | A | 需要目标机实测 hugepage size 和碎片化风险 |
| lcore / per-core state | [Thread Safety](https://doc.dpdk.org/guides/prog_guide/thread_safety.html) / [Lcore Variables](https://doc.dpdk.org/guides/prog_guide/lcore_var.html) / [Service Cores](https://doc.dpdk.org/guides/prog_guide/service_cores.html) | `prog-guide-thread-safety` / `prog-guide-lcore-var` / `prog-guide-service-cores` | direct_doc | 典型模型是 single thread per logical core；lcore 变量与 service cores 体现 per-lcore 状态和后台调度 | queue/polling/backpressure、I/O stack ADR | A | 需确认本项目是否需要 service core 分离 |
| Polling / RX-TX fast path | [Thread Safety](https://doc.dpdk.org/guides/prog_guide/thread_safety.html) / [EAL Library](https://doc.dpdk.org/guides/prog_guide/env_abstraction_layer.html) | `prog-guide-thread-safety` / `prog-guide-eal` | direct_doc | DPDK 运行几乎完全在 polling mode；PMD RX/TX 不建议加锁；低频事件走 interrupt host thread / epoll | queue/polling/backpressure | A | 需要在目标 workload 下测 busy polling 成本 |
| mempool / mbuf | [Memory Pool Library](https://doc.dpdk.org/guides/prog_guide/mempool_lib.html) / [Packet (Mbuf) Library](https://doc.dpdk.org/guides/prog_guide/mbuf_lib.html) / [DPDK Release 26.07](https://doc.dpdk.org/guides/rel_notes/release_26_07.html) | `prog-guide-mempool` / `prog-guide-mbuf` / `rel-notes-26.07` | direct_doc + release_note | fixed-size allocator + per-core cache + channel alignment；mbuf 归属原 pool、带 headroom、支持 chaining；26.07 调整了 cache 行为 | memory/hardware contract、benchmark reproducibility | A | 需补 cache size 和版本对照实验 |
| IOVA / IOMMU | [EAL Library](https://doc.dpdk.org/guides/prog_guide/env_abstraction_layer.html) / [Linux Drivers](https://doc.dpdk.org/guides/linux_gsg/linux_drivers.html) | `prog-guide-eal` / `linux-gsg-drivers` | direct_doc | Linux 上按 bus + IOMMU + physical address availability 推导 IOVA；`--iova-mode` 可强制；VFIO 依赖 IOMMU，no-IOMMU 明确 unsafe | memory/hardware contract、deployment preflight | A | 需要目标环境确认是否必须 PA/VA 固定 |
| NUMA / socket locality | [System Requirements](https://doc.dpdk.org/guides/linux_gsg/sys_reqs.html) / [EAL Library](https://doc.dpdk.org/guides/prog_guide/env_abstraction_layer.html) / [Intel perf guide](https://doc.dpdk.org/guides/linux_gsg/nic_perf_intel_platform.html) | `linux-gsg-sys-req` / `prog-guide-eal` / `linux-gsg-intel-perf` | direct_doc + guide | `--numa-mem`、`--numa-limit`、socket-local allocation、NIC/socket 同侧建议、isolcpus 建议都在官方文档中出现 | memory/hardware contract、queue/polling/backpressure | A | 需把 NUMA 布局映射到实际硬件拓扑 |
| driver binding / vfio | [Linux Drivers](https://doc.dpdk.org/guides/linux_gsg/linux_drivers.html) | `linux-gsg-drivers` | direct_doc | 大多数设备要先从 kernel driver 解绑再绑定到 `vfio-pci`；`dpdk-devbind.py` 是官方工具；root 才能 bind/unbind | deployment preflight、operability lifecycle | A | 需核对目标 NIC 驱动是否为 bifurcated driver 例外 |
| deployment preconditions | [System Requirements](https://doc.dpdk.org/guides/linux_gsg/sys_reqs.html) / [Enable functions](https://doc.dpdk.org/guides/linux_gsg/enable_func.html) / [Intel perf guide](https://doc.dpdk.org/guides/linux_gsg/nic_perf_intel_platform.html) | `linux-gsg-sys-req` / `linux-gsg-enable-func` / `linux-gsg-intel-perf` | guide | kernel >= 5.4、glibc >= 2.7、HUGETLBFS、PROC_PAGE_MONITOR、hugepages 预留、VT-d / iommu boot args、非 root 权限 / capabilities | deployment preflight、operability lifecycle | A | 需要把这些前置条件固化成部署检查表 |
| release-note drift | [DPDK Release 26.07](https://doc.dpdk.org/guides/rel_notes/release_26_07.html) / [Release Notes index](https://doc.dpdk.org/guides/rel_notes/index.html) | `rel-notes-26.07` / `rel-notes-index` | release_note | `--pagesz-mem`、`--no-auto-probing`、mempool cache 改动说明：版本升级会影响性能/方法学 | claim policy、benchmark reproducibility | B | 需要 stable release 对照与回归实验 |

## 主要结论

- DPDK 的 standalone 架构不是“普通用户态网络库”，而是一个由 EAL、hugepage、lcore、polling、mempool/mbuf、NUMA、IOVA/IOMMU 和 driver binding 共同构成的硬件契约系统。
- 对 checklist 来说，这些内容优先落在 `I/O stack ADR`、`memory/hardware contract`、`queue/polling/backpressure` 和 `deployment preflight`，不是单纯性能参数。
- 当前证据已足够把 DPDK 作为 source-document 机制证据补齐，但如果要升级成强结论，还需要补 stable 版本对照和目标环境实验。
