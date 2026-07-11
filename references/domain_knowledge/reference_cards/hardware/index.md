# Hardware 主题 reference cards

范围：仅基于下列 canonical URLs 的官方网页/文档做静态分析卡片，不下载原件，不修改主 checklist 或其他文件。访问日期统一记为 2026-07-11。

## 1) NVM Express Specifications
- 标题：Specifications - NVM Express
- 组织/团队：NVM Express
- 资料类型：官方规范总览页 / 入口页
- URL：https://nvmexpress.org/specifications/
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：页面明确写明当前 NVMe 规范集最新版本于 2025-08-05 发布；页面内容指向 NVMe 2.3 规范套件，并提示页面包含历史上的 obsolete 规范作为参考。
- 关键机制或文档内容：定义主机软件如何通过 PCIe、RDMA、TCP 等多种传输与非易失介质通信；Base spec 负责协议基础；NVMe-MI 是可选管理接口；Command Set 规范定义数据结构、feature、log page、command、status value；Transport 规范把 NVMe 协议绑定到具体传输；Boot 规范定义从 NVMe 接口启动的构造和指南；页面同时说明已废弃的 NVMe-oF 页面仅作历史参考。
- 对现有 storage checklist 的关联：可作为 hardware 主题里 NVMe 基础、传输层、命令集、管理面、启动路径和规范版本入口的总索引。
- 证据等级：A
- 事实：这是 NVM Express 的官方规范入口；页面给出明确的最新发布日期与文档分层；页面列出 Base、Command Set、Transport、Boot、NVMe-MI 等规范族。
- 推断：如果 checklist 需要按“协议栈层级”组织，应该把这页放在 NVMe 族条目的总入口，而不是单一技术卡。
- 未知/待核验：NVMe 2.3 套件各子文档的具体 PDF 细节、ECN/TP 的逐项影响，需要进一步打开子规范或 PDF 才能确认。
- 是否适合下载 raw 副本，以及建议文件名：适合，建议存网页快照 `nvmexpress-specifications-2026-07-11.html`。

## 2) NVMe over Fabrics 历史页
- 标题：NVMe over Fabrics (oF) Specification (historical reference only)
- 组织/团队：NVM Express
- 资料类型：历史参考页 / 退役规范说明页
- URL：https://nvmexpress.org/specification/nvme-of-specification/
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：页面明确标注为 historical reference only；文中写出 NVMe-oF 1.0 于 2016-06 发布，1.1 于 2019 发布；同时声明不再计划继续开发，相关内容已并入 NVMe 2.0 的 Base specification。
- 关键机制或文档内容：NVMe-oF 用于让 NVMe 命令在网络化 fabric 上传输，早期支持 Ethernet、Fibre Channel、Infiniband、RDMA；1.1 增加更细粒度 I/O 资源管理、端到端流控、NVMe/TCP 和改进的 fabric 通信；页面给出 1.1a current spec 以及 1.1/1.0 系列旧版本与修订、技术提案、errata 入口。
- 对现有 storage checklist 的关联：适用于 remote storage、fabric 互联、NVMe 远程访问、历史兼容性和“规范已迁移到 base spec”的说明卡。
- 证据等级：A
- 事实：这是官方历史页，不是当前活跃规范页；页面直接声明 NVMe-oF 不再继续演进。
- 推断：如果 checklist 里有“NVMe-oF 实现”条目，应额外标记其历史边界，避免把 1.x 旧语义误当作 NVMe 2.x 当前语义。
- 未知/待核验：页面未在正文中展开 1.1a 的逐条更改，若要实现级别对照仍需打开具体 PDF。
- 是否适合下载 raw 副本，以及建议文件名：适合，建议存网页快照 `nvmexpress-nvme-of-historical-reference-2026-07-11.html`。

## 3) NVM Express Specification Archives
- 标题：NVM Express Specification Archives
- 组织/团队：NVM Express
- 资料类型：规范归档索引页
- URL：https://nvmexpress.org/nvm-express-specification-archives/
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：页面是历史版本索引；可见条目包括 Base Specification 2.2（2025-03-11 ratified）、Revision Changes 2025.03.31 与 2025.08.01、ZNS 1.3（2025-03-11 ratified）、Key Value 1.2（2025-03-11 ratified）、Computational Programs 1.1（2025-03-11 ratified）、PCIe Transport 1.2（2025-03-11 ratified）、NVMe-MI 2.0 等。
- 关键机制或文档内容：按文档族分组列出旧版本和修订版，覆盖 Base、NVM Command Set、ZNS、Key Value、Subsystem Local Memory、Computational Programs、PCIe/RDMA/TCP 传输、NVMe-MI、Boot；适合用来追溯规范版本、ratified TP/ECN 和旧版 PDF。
- 对现有 storage checklist 的关联：适合做“版本追踪”和“历史兼容性”底座，尤其是 NVMe、ZNS、KV、CXL 相关条目的版本锚点。
- 证据等级：A
- 事实：这是官方归档页，信息粒度足够定位到具体 revision 和 ratified 日期。
- 推断：若 checklist 需要“当前版本 vs. 历史版本”分层，这页应作为版本控制入口，而不是最终语义来源。
- 未知/待核验：页面只列索引，不替代具体 PDF；个别条目名称在页面上截断或显示不完整，需要点开子链接才能确认完整修订说明。
- 是否适合下载 raw 副本，以及建议文件名：适合，建议存网页快照 `nvmexpress-specification-archives-2026-07-11.html`。

## 4) Compute Express Link 首页
- 标题：Homepage - Compute Express Link
- 组织/团队：Compute Express Link Consortium
- 资料类型：联盟官网首页 / 入口页
- URL：https://computeexpresslink.org/
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：页面当前主视觉明确写出 “CXL 4.0 Specification Now Available”；首页还直接列出当前活动、资源库和 Past CXL Specifications 入口。页面本身没有单独的正式发布日期。
- 关键机制或文档内容：CXL 作为开放一致性互连，提供主机处理器与加速器、memory buffers、smart I/O devices 之间的高带宽、低延迟连接；首页公告写明 CXL 4.0 将带宽从 64GT/s 提升到 128GT/s，并增加 bundled ports、增强 memory RAS；站点导航暴露 CXL Specification、Integrators List、Resource Library、Past CXL Specifications。
- 对现有 storage checklist 的关联：适合硬件互连、内存扩展、memory pooling/sharing、RAS、加速器与存储协同条目的总入口。
- 证据等级：B
- 事实：这是 CXL 联盟官方首页；首页当前重点是 CXL 4.0，而不是规范正文。
- 推断：如果 checklist 需要“当前官方入口”，这页是首选；如果需要实现级语义，应继续落到正式 spec 或发布公告 PDF。
- 未知/待核验：首页没有给出严格的版本发布日期，也没有展示 4.0 的逐条条款。
- 是否适合下载 raw 副本，以及建议文件名：适合，建议存网页快照 `computeexpresslink-homepage-2026-07-11.html`。

## 5) CXL 3.2 公告 PDF
- 标题：CXL Consortium Announces Compute Express Link 3.2 Specification Release
- 组织/团队：CXL Consortium
- 资料类型：官方新闻稿 / 规范发布公告 PDF
- URL：https://computeexpresslink.org/wp-content/uploads/2024/12/CXL_3.2-Spec-Announcement_FINAL-1.pdf
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：PDF 明确写有 2024-12-03；正文说明 CXL 3.2 是 fully backward compatible 的公开规范发布。
- 关键机制或文档内容：3.2 侧重 CXL Memory Devices 的安全、合规和功能增强；包括 CXL Hot-Page Monitoring Unit (CHMU) 用于 memory tiering、common event record、兼容 PCIe Management Message Pass Through (MMPT)、online firmware activation、Post Package Repair 增强、额外的性能监控事件、Trusted Security Protocol (TSP)、meta-bits storage、IDE protection 扩展、HDM-DB memory device security 以及增强互操作性测试。
- 对现有 storage checklist 的关联：适合 memory tiering、设备管理、RAS、安全、互操作测试、CXL memory device 方向的条目。
- 证据等级：A
- 事实：这是官方 PDF 新闻稿，带有明确发布日期和版本号；文中列出可直接落到实现与测试的具体机制名词。
- 推断：若 checklist 需要将 CXL 条目从“概念”细化到“设备管理/安全/RAS”，这份公告足够作为 3.2 的版本锚点。
- 未知/待核验：公告本身不是完整规范；CHMU、TSP、HDM-H/HDM-DB 的规范条文细节仍需打开正式 CXL 3.2 spec。
- 是否适合下载 raw 副本，以及建议文件名：适合，建议存 PDF 副本 `computeexpresslink-cxl-3.2-spec-announcement-2024-12-03.pdf`。

## 6) Intel Persistent Memory 概览页
- 标题：Persistent Memory
- 组织/团队：Intel Developer Zone
- 资料类型：开发者概览页 / 入口页
- URL：https://www.intel.com/content/www/us/en/developer/topic-technology/persistent-memory/overview.html
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：页面未标注明确发布日期；内容是当前可访问的开发者入口，且强烈体现从 Intel Optane persistent memory 向 CXL 的过渡。
- 关键机制或文档内容：页面给出 5 步路径：学习用途、用 VTune Platform Profiler 分析、配置平台、用 PMDK 开发、为 CXL 做准备；明确区分两种 operating mode：Memory Mode = 大容量 volatile memory without modification，App Direct Mode = 低延迟、byte-addressable persistent memory；PMDK 被定义为用于简化 persistent memory-aware 应用开发、调试和管理的开源库与工具集；页面还列出 Linux、Windows、ndctl、ipmctl、pmemcheck、pmempool、FIO 等工具入口。
- 对现有 storage checklist 的关联：适合 persistent memory 编程模型、工具链、运行模式、平台配置和 CXL 迁移条目。
- 证据等级：B
- 事实：这是 Intel 官方开发者页；页面直接给出操作模式、工具链与迁移到 CXL 的推荐路径。
- 推断：如果 checklist 里有“PMEM/Optane”条目，这页更像入口和导航，不是单一规范；应与具体 PMDK/ndctl 文档配合使用。
- 未知/待核验：页面没有公开说明内容更新时间，也没有给出 Optane PM 的生命周期状态；部分链接可能指向其他站点或动态资源。
- 是否适合下载 raw 副本，以及建议文件名：适合，建议存网页快照 `intel-persistent-memory-overview-2026-07-11.html`。

## 7) Intel Optane Technology 技术简报
- 标题：Intel® Optane™ Technology
- 组织/团队：Intel
- 资料类型：技术简报 PDF
- URL：https://www.intel.com/content/dam/www/public/us/en/documents/technology-briefs/optane-technology.pdf
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：PDF 尾注含 “0619/JW/PRW/NSG 340760-001”，可推断为 2019-06 左右的技术简报；正文没有单独的显式发布日期。
- 关键机制或文档内容：简报把 Optane 描述为不同于 NAND 的新架构；区分 Optane DC persistent memory 和 Optane DC SSD 两条路径；App Direct Mode 下的 persistent memory 以 DIMM 形式插在标准内存槽上，提供 persistence 和高密度，文中给出 up to 512 GB per DIMM；Memory Mode 可把 Optane PM 当作扩展的 volatile system memory，且无需重写软件；Optane DC SSD 通过 PCIe bus 提供 persistent storage，文中给出 up to 1.5 TB per SSD，并强调高随机读写、低延迟、写密集型负载和低队列深度性能；表格还列出接口、容量、平台、功能、形态和 OS 支持。
- 对现有 storage checklist 的关联：适合 persistent memory、memory mode/app direct、介质形态、平台约束、NVMe/PCIe 存储层和历史 Optane 方案条目。
- 证据等级：A
- 事实：这是官方技术简报，内容包含可直接引用的容量、接口、模式和适用场景；明确区分 PM 与 SSD 两类产品。
- 推断：这份文档适合作为历史背景与术语说明，但不应当被当作当前 Intel 存储路线的最新状态。
- 未知/待核验：由于 Intel 已把重点转向 CXL，文档中的产品状态和可采购性需要额外核验；尾注日期是推断值，不是正文显式日期。
- 是否适合下载 raw 副本，以及建议文件名：适合，建议存 PDF 副本 `intel-optane-technology-brief-2019-06.pdf`。

## 8) Flash Memory Summit Proceedings
- 标题：Proceedings.html
- 组织/团队：Flash Memory Summit
- 资料类型：会议 proceedings 索引页
- URL：https://www.flashmemorysummit.com/Proceedings.html
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：无法访问；Web fetch 返回 `Failed to fetch ...: Cache miss`，当前没有可引用的正文内容。
- 关键机制或文档内容：无可核验内容。
- 对现有 storage checklist 的关联：在当前访问状态下无法可靠映射；若后续可访问，通常会落到 flash、memory、storage 产业会议论文、演讲与案例材料。
- 证据等级：D
- 事实：官方 URL 在当前抓取环境中不可用，失败原因是 cache miss。
- 推断：这类 proceedings 页面通常用于找产业实践、案例和趋势信号，但本次不能凭空补内容。
- 未知/待核验：页面标题、年份范围、是否有 PDF 目录、是否需要登录或 JS 渲染，都未核实。
- 是否适合下载 raw 副本，以及建议文件名：无法判断，待页面恢复访问后再定；占位建议名可用 `flashmemorysummit-proceedings.html`。

## 共同模式、冲突和缺口
- 共同模式：这组硬件参考都围绕三条主线展开，分别是协议与互连层（NVMe、NVMe-oF、CXL）、内存/持久化编程模型（Persistent Memory、PMDK、App Direct / Memory Mode）、以及版本与归档纪律（archives、ratified revision、historical reference）。
- 冲突：NVMe-oF 已被官方明确降级为历史参考并并入 Base spec；Intel 的 persistent memory 页面仍保留 Optane 叙述，但同时把用户导向 CXL 迁移；CXL 官网首页当前宣传 4.0，而 3.2 公告 PDF 仍是最近可直接引用的版本锚点之一。
- 缺口：Flash Memory Summit proceedings 当前不可访问；Intel persistent memory 概览页缺少显式发布日期；CXL 首页是营销/入口页，不足以替代规范正文；如果 checklist 需要实现级别条款，仍需继续补齐各规范 PDF、ECN、TP 和具体子文档。
