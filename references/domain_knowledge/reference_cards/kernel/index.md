# Kernel 主题 Reference Cards

分析范围：仅基于以下 canonical URL 的官方文档、上游源码页和线上文档快照，不下载任何文件，不修改主 checklist 或其他参考文件。

访问日期：2026-07-11（CST）

## 1. blk-mq
- 标题：Multi-Queue Block IO Queueing Mechanism (blk-mq)
- 组织/团队：Linux Kernel 社区 / block 子系统
- 资料类型：官方内核文档
- URL：https://docs.kernel.org/block/blk-mq.html
- 版本/发布日期/时间状态：docs.kernel.org 线上文档快照，页头显示 `7.2.0-rc2`；属于滚动发布的当前文档视图
- 关键机制或文档内容：blk-mq 通过 software staging queues（`struct blk_mq_ctx`）和 hardware dispatch queues（`struct blk_mq_hw_ctx`）把 `bio` 组装为 `request` 后提交到块设备；支持请求合并、I/O scheduler、dispatch list 公平调度、tag-based completion；文档明确指出完成顺序不由 block layer 或协议保证
- 对现有 storage checklist 的关联：直接关联 block 层多队列、队列深度、调度器、合并/plugging、CPU 本地提交路径、硬件队列映射、NVMe/SSD 高并发 IOPS 设计
- 证据等级：A
- 事实、推断、未知/待核验：事实：blk-mq 是块层高并发队列机制；推断：适合用来解释为何现代存储设备要走多队列和 per-CPU 路径；未知：具体是否与某一块驱动绑定需看驱动实现
- 是否适合下载 raw 副本，以及建议文件名：适合；建议 `kernel-blk-mq-20260711.html`

## 2. VFS
- 标题：Overview of the Linux Virtual File System
- 组织/团队：Linux Kernel 社区 / filesystem 子系统
- 资料类型：官方内核文档
- URL：https://www.kernel.org/doc/html/latest/filesystems/vfs.html
- 版本/发布日期/时间状态：docs.kernel.org 线上文档快照，页头显示 `7.2.0-rc2`；为 latest 文档视图
- 关键机制或文档内容：VFS 是内核中的文件系统抽象层；`open(2)`、`stat(2)`、`read(2)`、`write(2)`、`chmod(2)` 等系统调用经由 VFS 进入；pathname 先查 dentry cache（dcache），dentry 只驻留内存；再通过 inode 解析真实文件系统对象；`permission` 回调可在 RCU-walk 模式下触发，不能随意阻塞
- 对现有 storage checklist 的关联：直接关联路径解析、目录项缓存、inode/metadata 语义、文件权限、锁与并发、VFS 到具体文件系统的边界
- 证据等级：A
- 事实、推断、未知/待核验：事实：VFS 负责 pathname 到 dentry/inode 的抽象；推断：任何存储栈设计若涉及文件语义，都要先过 VFS 这一层；未知：具体文件系统对 `permission`、`get_link` 等回调的实现差异需看各文件系统文档
- 是否适合下载 raw 副本，以及建议文件名：适合；建议 `kernel-vfs-20260711.html`

## 3. DMA API
- 标题：Dynamic DMA mapping using the generic device
- 组织/团队：Linux Kernel 社区 / driver APIs / DMA
- 资料类型：官方内核文档
- URL：https://www.kernel.org/doc/html/latest/core-api/dma-api.html
- 版本/发布日期/时间状态：docs.kernel.org 线上文档快照，页头显示 `7.2.0-rc2`；latest 视图
- 关键机制或文档内容：DMA API 由 `linux/dma-mapping.h` 提供；`dma_addr_t` 是设备可见地址，CPU 不能直接解引用；`dma_alloc_coherent()` 提供 coherent buffer；`dma_map_sg()` 将 scatter/gather 列表映射到 DMA 地址，返回值可能小于输入项数，因为 IOMMU 或物理连续段会合并；文档还给出 IOVA-based DMA mappings，面向 IOMMU 场景的更高效映射/同步/销毁接口
- 对现有 storage checklist 的关联：直接关联设备 DMA 缓冲区、ring buffer、scatter-gather I/O、IOMMU、coherent vs streaming memory、设备提交/完成路径的缓存一致性
- 证据等级：A
- 事实、推断、未知、待核验：事实：DMA 地址空间与 CPU 地址空间可不同；推断：任何高性能块设备/网卡后端都要明确区分 coherent buffer 与 streaming mapping；未知：某驱动是否采用 IOVA 路径或仅使用基础 DMA API 需看驱动代码
- 是否适合下载 raw 副本，以及建议文件名：适合；建议 `kernel-dma-api-20260711.html`

## 4. io_uring.c
- 标题：linux/io_uring/io_uring.c
- 组织/团队：torvalds/linux 上游内核仓库 / io_uring 子系统
- 资料类型：上游源码页（GitHub blob）
- URL：https://github.com/torvalds/linux/blob/master/io_uring/io_uring.c
- 版本/发布日期/时间状态：`master` 分支滚动 HEAD；本次抓取未固定到具体 SHA，时间状态为持续变化
- 关键机制或文档内容：文件头注释直接说明 io_uring 提供 shared application/kernel submission and completion ring pairs，并强调内存屏障顺序要求；代码路径体现 `SQPOLL`、`IOPOLL`、`io_wq` 异步下沉、deferred completion、CQ overflow、`IOSQE_IO_DRAIN`、固定文件/缓冲区选择等机制；这是一份核心实现源码，不是稳定 API 文档
- 对现有 storage checklist 的关联：直接关联异步 I/O 提交模型、completion ring 设计、内存序、轮询模式、workqueue 下沉、请求生命周期、完成溢出处理
- 证据等级：B
- 事实、推断、未知、待核验：事实：io_uring 依赖严格的读写屏障和 ring 共享协议；推断：该文件适合定位请求调度与完成路径的真实实现细节；未知：因未固定 commit，后续 master 变化可能改变实现细节
- 是否适合下载 raw 副本，以及建议文件名：适合；建议 `linux-io_uring.c-20260711`

## 5. nvme/host/ioctl.c
- 标题：linux/drivers/nvme/host/ioctl.c
- 组织/团队：torvalds/linux 上游内核仓库 / NVMe host 驱动
- 资料类型：上游源码页（GitHub blob）
- URL：https://github.com/torvalds/linux/blob/master/drivers/nvme/host/ioctl.c
- 版本/发布日期/时间状态：`master` 分支滚动 HEAD；本次抓取未固定到具体 SHA，时间状态为持续变化
- 关键机制或文档内容：`nvme_validate_passthru_nsid()` 检查命令 nsid 与 namespace 是否匹配；`nvme_user_cmd()` / `nvme_user_cmd64()` 负责从 userspace 拷贝 passthrough 命令、做 `nvme_cmd_allowed()` 权限检查、把 `timeout_ms` 转成 jiffies、将命令提交到 `ns->queue` 或 `ctrl->admin_q` 并把结果回写用户态；后半部分还定义了 `nvme_uring_cmd_pdu`、`nvme_uring_task_cb()`、`nvme_uring_cmd_end_io()`，说明 NVMe ioctl 与 io_uring 命令路径的交界
- 对现有 storage checklist 的关联：直接关联 NVMe passthrough、admin queue / I/O queue、namespace 校验、用户态到内核态命令桥接、io_uring 驱动集成、用户缓冲区解除映射
- 证据等级：B
- 事实、推断、未知、待核验：事实：该文件把用户态 NVMe 命令转成内核命令并回传结果；推断：适合追踪 ioctl/passthrough 的真实参数校验和失败路径；未知：具体 ioctl ABI 兼容细节与最近变更需查看对应 commit 历史
- 是否适合下载 raw 副本，以及建议文件名：适合；建议 `linux-nvme-host-ioctl.c-20260711`

## 6. docs.kernel.org/nvme/index.html
- 标题：NVMe Subsystem
- 组织/团队：Linux Kernel 社区 / NVMe 子系统
- 资料类型：官方内核文档索引页
- URL：https://docs.kernel.org/nvme/index.html
- 版本/发布日期/时间状态：docs.kernel.org 线上文档快照，页头显示 `7.2.0-rc2`；index 页本身不提供发布日期
- 关键机制或文档内容：该页是 NVMe 文档入口，只列出两大块内容：`Linux NVMe feature and quirk policy` 和 `NVMe PCI Endpoint Function Target`，适合作为查找特性支持、quirk 策略、PCI endpoint target 的目录入口
- 对现有 storage checklist 的关联：用于 NVMe 主题索引、feature/quirk 策略、PCI endpoint target、查找更细文档的入口
- 证据等级：B
- 事实、推断、未知、待核验：事实：此页主要是目录；推断：若要落地 NVMe 行为，需要继续跳到 feature/quirk policy 或 endpoint 章节；未知：具体特性支持与 quirk 内容不在该页
- 是否适合下载 raw 副本，以及建议文件名：适合；建议 `kernel-nvme-index-20260711.html`

## 7. SPDK NVMe-oF Target
- 标题：SPDK: NVMe over Fabrics Target
- 组织/团队：SPDK 项目 / storage user-space stack
- 资料类型：官方项目文档
- URL：https://spdk.io/doc/nvmf.html
- 版本/发布日期/时间状态：线上文档快照，页面未标显式版本号或发布日期；可视为滚动维护的当前文档
- 关键机制或文档内容：SPDK NVMe-oF target 是用户态应用，通过 Ethernet、InfiniBand 或 Fibre Channel 提供块设备；当前支持 RDMA 和 TCP 传输；文档明确 target/host 术语，并说明与 Linux kernel NVMe-oF target/host 具备互操作测试；RDMA 部分还要求 OFED、相关内核模块和 NIC 准备
- 对现有 storage checklist 的关联：直接关联用户态 NVMe-oF、RDMA/TCP 传输、互操作、部署前置条件、目标端/主机端术语、Fabric 访问模型
- 证据等级：A
- 事实、推断、未知、待核验：事实：SPDK 采用用户态 target 并支持 RDMA/TCP；推断：适合做内核外高性能 NVMe-oF 参考架构；未知：具体版本对应的支持矩阵与配置差异需对照 release note
- 是否适合下载 raw 副本，以及建议文件名：适合；建议 `spdk-nvmf-20260711.html`

## 8. SPDK DMA
- 标题：SPDK: Direct Memory Access (DMA) From User Space
- 组织/团队：SPDK 项目 / DPDK 依赖栈
- 资料类型：官方项目文档
- URL：https://spdk.io/doc/memory.html
- 版本/发布日期/时间状态：线上文档快照，页面未标显式版本号或发布日期；可视为滚动维护的当前文档
- 关键机制或文档内容：SPDK 解释为何传给它的所有 buffer 必须由 `spdk_dma_malloc()` 或其 siblings 分配，并依赖 DPDK 的 memory management；文档说明 NVMe 设备通过 PCI bus 使用 DMA 访问系统内存，缺少 IOMMU 时使用物理地址；同时给出 NVMe PRP list 的物理布局限制，包括 4KiB page、首尾页对齐规则和可分段描述要求
- 对现有 storage checklist 的关联：直接关联用户态 DMA-safe 内存、PRP layout、PCI DMA、IOMMU 有无、buffer 分配约束、NVMe 数据面内存组织
- 证据等级：A
- 事实、推断、未知、待核验：事实：SPDK 的 DMA buffer 需要专门分配接口；推断：这类约束是 SPDK 高性能路径的前提，而不是实现细节；未知：不同版本 DPDK / SPDK 在内存后端上的差异需看对应版本文档
- 是否适合下载 raw 副本，以及建议文件名：适合；建议 `spdk-dma-20260711.html`

## 共同模式、冲突和缺口
- 共同模式：这组资料都围绕“高性能存储路径的所有权边界”展开，核心关键词是 queue、mapping、ownership、ordering、completion；内核侧强调 block/VFS/DMA 的分层，SPDK 强调用户态 buffer 约束和传输层配置
- 冲突：Linux 内核文档默认“设备 DMA 由内核抽象管理”，而 SPDK 文档默认“用户态必须自己提供 DMA-safe 内存并满足 PRP/传输前置条件”；两者在内存分配与设备可见地址处理上是不同模型
- 缺口：`docs.kernel.org/nvme/index.html` 只是索引，没有机制细节；`io_uring.c` 和 `ioctl.c` 是滚动 `master` 源码，不是固定版本文档；SPDK 两页都未显式标注版本号/发布日期，因此更适合当作当前线上快照而不是长期不变的规范
