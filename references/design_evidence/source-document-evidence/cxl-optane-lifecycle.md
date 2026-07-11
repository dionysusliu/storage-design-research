# CXL / Optane 生命周期证据补齐

生成时间：2026-07-11 18:23:46 CST

## Source Inventory

| local_ref | 官方 URL / 本地路径 | 来源类型 | 证据等级 | 已抓取正文 | 生命周期状态 | 备注 |
| --- | --- | --- | --- | --- | --- | --- |
| `cxl-home` | https://computeexpresslink.org/ | CXL Consortium 官方首页 | A | 是 | current / active | 首页明确写出 `CXL 4.0 Specification Now Available`，是当前公开入口。 |
| `cxl-spec-page` | https://computeexpresslink.org/cxl-specification/ | CXL Consortium 规范下载页 | A | 是 | current / active | 下载页当前面向 `CXL 4.0 Specification`，评估协议写明 `as of February 12, 2026`。 |
| `cxl-4.0-press` | https://computeexpresslink.org/wp-content/uploads/2025/11/CXL_4.0-Specification-Release_FINAL_Website-Copy.pdf | CXL 官方发布说明 PDF | A | 是 | current / active | 官方 release note，明确 2025-11-18 发布 4.0，并列出带宽、bundled ports、memory RAS 改进。 |
| `cxl-4.0-webinar` | https://computeexpresslink.org/wp-content/uploads/2025/12/CXL_4.0-Webinar_December-2025_FINAL.pdf | CXL 官方 webinar / slide deck | B | 是 | current / active | 含版本时间线、Security & Compliance、TEE Security Protocol、memory expander / RAS 相关 slide。 |
| `cxl-intro-paper` | https://arxiv.org/abs/2306.11227 | 辅助论文 | B | 是 | historical / background | 论文是 2023 年综述，覆盖 CXL 1.0 / 2.0 / 3.0 的使用模型与生态，适合补协议语义背景。 |
| `snia-home` | https://www.snia.org/ | SNIA 官方首页 | B | 是 | current / active | 首页可见 `Persistent Memory`、`NVM Programming Model`、`CXL Consortium` 等入口，适合作为关联标准门口。 |
| `nvme-home` | https://nvmexpress.org/ | NVM Express 官方首页 | B | 是 | current / active | 首页说明 NVMe 定义 host software 与 non-volatile memory 的通信方式，是相关 I/O 标准入口。 |
| `intel-optane-newsroom-slug` | https://newsroom.intel.com/news/intel-to-wind-down-optane-memory-business-3d-xpoint-storage-tech-reaches-its-end/ | Intel 官方 newsroom 旧页（已退役） | C | 否（仅 HEAD/404） | retired public page / lifecycle gap | 2026-07-11 抓头返回 404；说明该旧 URL 已退役，但本轮未恢复到 Intel 自己的生命周期正文。 |
| `intel-optane-newsroom-alt` | https://newsroom.intel.com/news/intel-to-wind-down-optane-memory-business/ | Intel 官方 newsroom 旧页（已退役） | C | 否（仅 HEAD/404） | retired public page / lifecycle gap | 另一个常见 slug 也返回 404；进一步说明公开页不可达。 |
| `optane-historical-paper` | https://arxiv.org/abs/1903.05714 | 辅助论文 | B | 是 | historical / background | 2019 论文把 Optane DC PMM 描述为 byte-addressable NVM，用于 memory mode / app direct，是历史能力证据，不是当前生命周期证据。 |

## Mechanism Notes

### CXL：协议栈与版本状态

- CXL 的公开说明和综述都把它描述为面向处理器与设备之间的开放互连，覆盖加速器、memory buffer、persistent memory 和 SSD 等场景。
- 机制上可按三层理解：`CXL.io` 负责配置、发现、管理和基于 PCIe 的 I/O 路径；`CXL.cache` 负责 host/device 的一致性缓存访问；`CXL.mem` 负责对 device-attached memory 的一致性 load/store 访问。
- 当前公开版本锚点已经到 `4.0`：官方首页和 release note 都把 `4.0` 作为最新公开规范，且 release note 明确写了 64GT/s -> 128GT/s、bundled ports、memory RAS 强化。
- 版本时间线在官方 webinar 中给出：`1.0`（2019-03）、`1.1`（2019-09）、`2.0`（2020-11）、`3.0`（2022-08）、`3.1`（2023-11）、`3.2`（2024-12）、`4.0`（2025-11）。
- 这意味着任何 CXL 相关设计或 benchmark 都必须写清楚版本号；把 `3.0/3.1/3.2/4.0` 混写成“CXL”会直接丢失关键能力边界。

### CXL：Type-3 / memory device / RAS / security

- 从官方 release note 和 webinar 的组合看，CXL 的“memory device / memory expander”路线是当前重点之一，4.0 继续强化 memory device 能力、RAS 和安全能力。
- `Type-3 memory device` 可把它理解为 host-managed attached memory / memory expander 这一类设备；本轮证据里这一点是**基于官方 slide + 综述的推断**，不是直接抄规范正文。
- RAS 侧，官方 4.0 资料明确列出 `granular event reporting`、`Post Package Repair (PPR)`、`flexible memory sparing`。
- 安全侧，官方 4.0 资料列出 `TEE Security Protocol`，并把 `security, compliance, and CXL Memory Device enhancements` 作为可交付特性。
- 因此，CXL memory device 的 lifecycle 不是“只看带宽”，而是同时看 protocol version、RAS 能力和安全管理接口。

### Optane / PMem：历史、当前、遗留关系

- Optane 是 Intel 的品牌族，历史上覆盖过 SSD、cache 型 memory 产品，以及 Optane Persistent Memory / DCPMM 这种 DIMM 形态的主存扩展设备。
- 2019 论文显示，Optane DC PMM 当时被用作 byte-addressable persistent memory，支持 memory mode / app direct，并且可以配 DRAM cache。
- 但在 2026-07-11 这轮取证里，我没有恢复到 Intel 自己的可公开生命周期正文；能抓到的是旧 newsroom URL 已退役（404），说明公开页已不可达。
- 所以对当前设计的安全表述应该是：`Optane/PMem = historical / legacy baseline`，不要把它当成当前可采购、可长期依赖的新平台组件。
- 如果要写更强的官方结论，还需要补 Intel 的 product lifecycle / support / discontinuation 正文或 PCN。

## Checklist Impact

### Architecture Checklist

- **I/O stack / hardware contract**
  - CXL 这条线要把 hardware contract 写成 `CXL version + device type + security/RAS profile`，不要只写“支持 CXL memory”。
  - 如果是 memory expansion / pooling，优先写 `CXL.mem + memory device`；如果是加速器，写清楚 `CXL.io / cache / mem` 的组合。
  - NVMe 和 SNIA 入口说明：如果设计最终落到 SSD/block 侧，要明确是 `NVMe` 还是 `CXL-attached memory`，不能混成一个抽象“存储设备”。

- **Lifecycle / status**
  - CXL 当前公开最新版是 `4.0`，所以文档里的“current CXL”必须有日期和版本锚点。
  - Optane / PMem 必须单列为 `legacy / retired / historical baseline`，不要在主路径里写成当前选型。
  - 采购、可复现性和运维条目都要区分“新购 CXL 平台”与“二手 / 库存 Optane 实验机”。

- **Claim policy**
  - 任何性能/容量/一致性/安全 claim 都必须带 `version + date + device class`。
  - 对 Optane 的 claim 只能当历史 baseline；如果没有 Intel 官方 lifecycle 页，就不要写成“官方仍支持”。
  - 对 CXL 的 claim 也不能默认继承 4.0 能力到 3.x；尤其是 RAS / security / bundled ports 这些点。

### Metrics Checklist

- **Versioned benchmark labels**
  - 需要把 `CXL 3.2`、`CXL 4.0`、legacy Optane 分开测，不然数据不可比。
  - 记录至少：spec version、firmware/BIOS、device type、transport path、RAS/security feature set。

- **Hardware contract validation**
  - 验证点不止吞吐和延迟，还要看 `event reporting`、`PPR`、`memory sparing`、`TEE` 这类管理面能力是否实际存在。
  - 对 Optane 基线，只能测历史设备，不要把结果外推成当前供应链能力。

- **Claim reproducibility**
  - 所有 claim 必须能回溯到具体发布页或论文页，最好同时保留正文抓取和发布日期。
  - 如果只拿到 landing/release page，claim 应该降级为“release-level evidence”，而不是规范正文证据。

## Open Gaps

- 需要补 Intel 官方生命周期正文：`product lifecycle / support / discontinuation / PCN`，当前只拿到旧 newsroom URL 的 404 证据，不能作为正式生命周期条款。
- 需要补 CXL 规范正文的可公开细节：Type-3、reset/reinit、poison、security state machine、RAS 管理命令等。
- 需要补 SNIA / NVMe 更精确的关联入口页，如果后续要把 checklist 写成“标准入口树”。
- 需要补实验或采购证据：当前可用硬件是否真的是 `CXL 4.0`、`CXL 3.2`，还是只支持旧代特性。
- 如果要比较 Optane 与 CXL，必须补一个明确的历史基线定义，否则容易把 legacy 设备与当前标准混写。

## Evidence Table

| check_item | source | local_ref | evidence_type | evidence_note | design_pressure | confidence | gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `lifecycle/status` | CXL Consortium homepage / spec page / release note | `cxl-home` / `cxl-spec-page` / `cxl-4.0-press` | official landing + release | 4.0 为当前公开最新版本，首页与 release note 一致。 | `claim policy`、版本锚点、采购判断 | A | 规范正文仍是 gated，landing page 不是完整 normative text。 |
| `version/date` | CXL 4.0 webinar | `cxl-4.0-webinar` | official slide deck | 公开时间线给出 1.0 -> 4.0 的发布日期，适合做版本上下文。 | 版本比较、回归对照 | A | 需要与稳定版发布页交叉确认。 |
| `I/O stack / hardware contract` | CXL intro paper + official 4.0 release | `cxl-intro-paper` / `cxl-4.0-press` | paper + official release | CXL 覆盖 accelerators、memory buffers、persistent memory、SSDs；4.0 继续强化 memory device 能力。 | 设备契约、协议边界 | B | Type-3 仍需直引规范正文。 |
| `Type-3 memory device` | CXL 4.0 webinar + CXL intro paper | `cxl-4.0-webinar` / `cxl-intro-paper` | official slide + paper | `memory expander` / `CXL Memory Device` 可作为 Type-3 语义入口，但这里是推断。 | memory expansion、device lifecycle | C | 需要规范正文逐条确认 device type 对应关系。 |
| `RAS / security` | CXL 4.0 release note / webinar | `cxl-4.0-press` / `cxl-4.0-webinar` | official release + slide | 明确列出 `TEE Security Protocol`、`security, compliance`、`granular event reporting`、`PPR`、`flexible memory sparing`。 | 安全基线、故障管理 | A | 仍需实际实现/固件验证。 |
| `adjacent standards entry` | SNIA homepage | `snia-home` | official org home | SNIA 首页直接暴露 `Persistent Memory`、`NVM Programming Model`、`CXL Consortium` 入口。 | 标准入口树、归类 | B | 需要更深一层的 SNIA 子页或 white paper。 |
| `adjacent standards entry` | NVM Express homepage | `nvme-home` | official org home | NVMe 主页定义 PCIe/RDMA/TCP 上的非易失存储通信方式。 | I/O stack 边界、claim policy | B | 不是 CXL 正文，只能作为相关标准门口。 |
| `legacy Optane page` | Intel newsroom old URL | `intel-optane-newsroom-slug` / `intel-optane-newsroom-alt` | official URL / retired | 2026-07-11 HEAD 返回 404，说明公开页已退役。 | lifecycle/status、procurement | C | 还缺 Intel 自己的 lifecycle/support 正文。 |
| `Optane historical role` | Optane DC PMM paper | `optane-historical-paper` | paper | 2019 论文证明 Optane PMM 曾作为 byte-addressable memory / persistent memory 使用。 | historical baseline | B | 只能支持历史功能，不支持当前可采购状态。 |
| `CXL vs Optane relation` | CXL intro paper + CXL 4.0 release | `cxl-intro-paper` / `cxl-4.0-press` | paper + official release | CXL 已覆盖 memory expansion / pooling / persistent memory 语境，可作为 Optane 这类 vendor-specific PMem 的标准化后继背景。 | claim policy、路线替换 | B | 这是基于 use-case overlap 的推断，不是 deprecation notice。 |

## 主要结论

- `CXL`：当前公开最新版是 `4.0`，官方已把 bandwidth、bundled ports、memory RAS、security/compliance 作为最新演进点。
- `Optane / PMem`：应按 `历史 / 遗留 / legacy baseline` 处理；本轮没恢复到 Intel 的正式生命周期正文，所以不要把“页面 404”误写成官方支持状态。
- 对 checklist 来说，最重要的是把 `版本、设备类型、RAS/security、生命周期状态` 四个维度都写进同一条证据链里。
