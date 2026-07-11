# SNIA Swordfish 证据补齐
生成时间：2026-07-11

## Source Inventory

| 官方 URL | 本地路径 | 来源类型 | 证据等级 | 是否已抓取正文 | 生命周期状态 |
| --- | --- | --- | --- | --- | --- |
| [SNIA Swordfish 主入口](https://www.snia.org/forums/smi/swordfish) | 无本地快照 | SNIA 官方门户 / 规范入口 | B | 是 | Active portal，当前页标注 Working Draft v1.2.9（2026-01-26） |
| [Swordfish v1.2.9 Specification PDF](https://www.snia.org/sites/default/files/technical-work/swordfish/draft/v1.2.9/pdf/Swordfish_v1.2.9_Specification.pdf) | 无本地快照 | SNIA 规范正文 / working draft | A | 是 | Current working draft |
| [SNIA Swordfish CTP](https://www.snia.org/swordfish-ctp) | 无本地快照 | SNIA conformance program / 官方测试计划 | B | 是 | Active program，面向特定版本的符合性测试 |
| [Swordfish CTP Results](https://www.snia.org/groups/swordfish-api-conforming-products) | 无本地快照 | SNIA conforming-products registry / 公示列表 | B | 是 | Active registry，列出通过测试的产品 |
| [DMTF Redfish 标准页](https://www.dmtf.org/standards/redfish) | 无本地快照 | DMTF 官方标准入口 / 版本页 | A | 是 | Current standard page；2026.1 / 1.24.0（2026-05-17） |
| [DMTF DSP0266 all published versions](https://www.dmtf.org/dsp/DSP0266) | 无本地快照 | DMTF 官方版本历史 / changelog | A | 是 | Published versions registry；可追版本差异 |
| [DMTF Redfish Storage White Paper](https://www.dmtf.org/sites/default/files/standards/documents/DSP2073_1.0.0.pdf) | 无本地快照 | DMTF 官方 informational white paper | B | 部分 | Published informational，2026-05-07 |

## Mechanism Notes

### 1) 规范定位
- Swordfish 是 SNIA 的可扩展存储管理 API。当前官方门户与规范正文都把它描述为面向 storage and related data services 的 RESTful 接口与标准化数据模型。
- 2026-07-11 可见的官方门户把 Swordfish 标成 `Working Draft v1.2.9`，日期为 2026-01-26；因此这里应按“当前工作草案”而不是“已冻结终版”来写结论。

### 2) 与 DMTF Redfish 的关系
- Swordfish 不是另起炉灶的独立协议，而是对 DMTF Redfish 的扩展。规范正文明确说 Swordfish service interface extends the Redfish service interface，而且 Swordfish service 本身就是 Redfish service。
- 这意味着它必须满足 Redfish 的基础元素、HTTP/REST 交互、JSON/OData 资源表达和 Redfish schema 规则；Swordfish 只是增加 storage-specific model、registry、profile 和约束。
- 官方规范还要求 Swordfish schema / registry / profile 的在线主源与 Redfish 共址在 DMTF 的 schema / registry / profile 站点，SNIA 站点只提供 bundle 指针。
- 当前 DMTF Redfish 官方页显示 Redfish 2026.1 / 1.24.0 已发布，这给 Swordfish 的版本对齐提供了最新 Redfish 基线。

### 3) storage management API 字段 / 模型
- Swordfish 的通用资源字段沿用 Redfish 习惯：`@odata.context`、`@odata.id`、`@odata.type`、`Description`、`Id`、`Name`、`Oem`、`Actions`、`Links`、`RelatedItem`。
- 规范把 `Capacity` 作为共通对象，拆成 `Data`、`Metadata`、`Snapshot`，并要求三者之和等于总容量；`CapacityInfo` 再提供 `AllocatedBytes`、`ConsumedBytes`、`GuaranteedBytes`、`ProvisionedBytes` 等容量细分。
- `StorageService` 是核心 management plane 资源。它通过 `StorageServices` collection 暴露资源，并挂接 `ClassesOfService`、`Drives`、`Enclosures`、`Endpoints`、`FileSystems`、`EndpointGroups`、`StorageGroups`、`StoragePools`、`Volumes`、`HostingSystem`。
- 规范把 `StorageService` 分成 integrated service configuration 与 standalone service configuration 两种建模方式，但两者都围绕 Redfish `Storage` / `StorageController` / `ComputerSystem` / `Chassis` 来表达物理与逻辑关系。
- `StoragePool` 表示未分配容量，可派生 `Volume` 或其他 `StoragePool`；关键字段包括 `AllocatedVolumes`、`AllocatedPools`、`CapacitySources`、`RAIDTypes`、`Capacity`、IO / performance metrics、spare management、pool type。
- `Volume` 是 block-addressable container；它可附带 access capabilities、capacity sources、consumption tracking、replication details、StorageGroup 信息，也支持 reservations / replication / masking 相关 action。
- `FileSystem` 表示层级命名空间中的文件容量，属于 Swordfish 对文件服务的正式覆盖范围。
- `ClassOfService` 机制把高层业务目标映射成可组合的 service levels；`DataSecurityLoSCapabilities` 明确把 FIPS-140、HIPAA、PCI 这类外部安全标准纳入可表达的服务级要求。

### 4) observability / management plane
- Swordfish 把 `Health` 与 `HealthRollup` 语义写得很明确：上层对象必须能反映子对象健康状态，并保留根因可追踪性。这对告警和管理面可观测性很重要。
- 规范还要求 event / message registries 的分层使用：Resource Event、Redfish Base、Redfish StorageDevice、Swordfish Storage / StorageCoS、Task Event、StorageConnection 等；这给 management plane 的状态、错误和 long-running operation 提供了标准化消息边界。
- `StoragePoolMetrics`、`VolumeMetrics`、`StorageServiceMetrics`、`FileSystemMetrics` 都是正式 schema；其中 `IOStatistics` 承载 I/O 统计，`LifetimeStartDateTime` 用于区分 lifetime 统计起点。
- Swordfish 还把 `IOWorkload`、`MaxIOOperationsPerSecondPerTerabyte`、`AverageIOOperationLatencyMicroseconds` 之类 workload-aware 指标写进模型，说明它不只关心总吞吐，也关心 workload context 和容量归一化的性能密度。

### 5) security / compliance / interop
- Swordfish 规范在 Security 小节里直接说：整体遵循 Redfish security requirements，并额外要求实现 TLS，且要按 ISO/IEC 20648 和 SNIA 的 TLS Specification for Storage Systems 执行。
- 在符合性与兼容性方面，SNIA 提供 Swordfish CTP：官方描述它使用 vendor-neutral、open source test suite 去验证某个具体 Swordfish 版本的符合性；结果页则公开列出通过测试的厂商与测试版本。
- 规范同时提供 Swordfish Interoperability Guide、Profile Bundle、Schema Bundle、Property Guide、Metrics White Paper 等配套资料，说明官方把“互操作/可测试”当成规范组成部分，而不是事后博客说明。
- 这套资料组合意味着：如果 checklist 要写成可执行规范，不能只写“兼容 Redfish”这种空话，而要把 `TLS`、`message registries`、`CTP version`、`profile`、`schema bundle`、`metrics bundle` 一起纳入。

### 6) lifecycle / versioning
- 当前官方页面显示 Swordfish 处于 Working Draft v1.2.9；但 CTP 页面仍出现 `latest version is 1.2.7` 和 `1.2.5a or above` 这类旧字样，说明部分官方页面存在版本滞后。
- 这类滞后不是坏证据，但必须在 checklist 里显式标注“来源版本”和“页面状态”，否则很容易把历史版本或工作草案误当成当前生产事实。

## Checklist Impact

| Checklist 区域 | 影响 |
| --- | --- |
| Architecture Checklist - Gate 2 API, Metadata, And Semantics | Swordfish 的 `@odata.*`、`StorageServices`、schema primacy、`ClassOfService`、`StorageService/StoragePool/Volume/FileSystem` 模型，直接要求 checklist 明确 resource model、metadata owner、schema version 和 service root 组织方式。 |
| Architecture Checklist - Gate 5 I/O Stack, Memory, And Hardware Contract | `StoragePool` / `Volume` / `StorageController` / `NVMe` 相关建模，要求 checklist 把 management plane 与底层 I/O 与硬件约束分开写清楚，而不是只给出“支持块存储”这种抽象描述。 |
| Metrics Checklist - observability / benchmark artifact | `IOStatistics`、`VolumeMetrics`、`StoragePoolMetrics`、`StorageServiceMetrics`、`LifetimeStartDateTime`、`IOWorkload`、IOPS density 等字段，说明 metrics checklist 必须要求 workload context、capacity-normalized metric、lifetime start、以及 per-resource metrics，不应只接受总延迟 / 总吞吐。 |
| Metrics Checklist - security review / management plane | `TLS` 强制、标准消息注册表、event/task message registry、HealthRollup 传播和 DataSecurityLoSCapabilities，说明安全 review 不能只看数据面，要把 management plane、错误语义、任务语义和标准合规一起纳入。 |
| Architecture Checklist - Gate 8 Operability, Cost, Lifecycle, And Exit Strategy | CTP、profile bundle、schema bundle、版本化 working draft / standard 以及 asynchronous create/update/delete / Task Monitor 语义，要求 checklist 把版本锚点、runbook、回滚、符合性测试和发布生命周期写进运维要求。 |

## Open Gaps

- 仍需更深一层的规范正文或 schema bundle，才能把 `StorageService`、`StoragePool`、`Volume`、`FileSystem`、`ClassOfService` 的完整字段表、枚举和动作列表写成逐字段证据。
- 仍需把 `Interop Guide`、`Profile Bundle`、`Metrics White Paper` 和 `Property Guide` 再下钻一次，补齐具体 profile 要求和 metrics 字段全量清单。
- 目前已经确认 `TLS` 是强制要求，但还没有把 authN/authZ、角色模型、证书管理、cipher suite、session lifecycle 这几块安全细节整理成可回写 checklist 的结论。
- 官方页面存在版本滞后：Swordfish 门户显示 v1.2.9 Working Draft，但 CTP 页面仍保留 `1.2.7` / `1.2.5a+` 旧措辞；如果 checklist 要用于生产判断，必须继续核对最新 release train。
- 目前拿到的是官方入口页、规范正文和 CTP 说明，尚未建立独立的第三方交叉验证；如果后续要做强结论，最好再补 1 份实现侧参考或公开产品级 conforming 证据。

## Evidence Table

| check_item | source | local_ref | evidence_type | evidence_note | design_pressure | confidence | gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Gate 2: 规范定位与 Redfish 关系 | SNIA Swordfish v1.2.9 spec + SNIA Swordfish portal + DMTF Redfish standards page | 无本地快照 | mechanism | Swordfish 明确是 Redfish 的扩展，同时也是 Redfish service；其资源发现、`ServiceRoot`、`StorageServices`、JSON/OData、schema primacy 都建立在 Redfish 之上。 | management plane 不能按私有 CLI 或独立协议建模，必须保留 Redfish 兼容入口与版本锚点。 | A | 仍需对当前 `2026.1 / 1.24.0` Redfish 基线做一次逐字段对照。 |
| Gate 2 / Gate 5: storage management API 字段与模型 | SNIA Swordfish v1.2.9 spec | 无本地快照 | mechanism | `StorageService`、`StoragePool`、`Volume`、`FileSystem`、`ClassOfService`、`Capacity`、`CapacityInfo` 构成了 Swordfish 的核心模型；它覆盖 block/file/object，并把 logical storage 与 physical topology 通过 Redfish 资源链路关联起来。 | checklist 需要明确管理面资源树、容量模型、映射/掩蔽和类服务，而不是只写“支持存储管理”。 | A | 还缺完整字段表和动作表，尤其是 profile-specific mandatory properties。 |
| Gate 7: observability / benchmark artifact | SNIA Swordfish v1.2.9 spec | 无本地快照 | mechanism | `IOStatistics`、`StoragePoolMetrics`、`VolumeMetrics`、`StorageServiceMetrics`、`FileSystemMetrics` 以及 `LifetimeStartDateTime` / `IOWorkload` / IOPS density 说明规范本身就有 metrics 与 workload context。 | metrics checklist 应要求按 resource 级、lifetime 级、workload 级拆指标，不能只接受单点吞吐图。 | A | 还需补齐各 metrics schema 的全量字段与单位。 |
| Gate 7: security / compliance | SNIA Swordfish v1.2.9 spec | 无本地快照 | mechanism | 规范的 Security 小节要求遵循 Redfish security requirements，并额外强制 TLS；`DataSecurityLoSCapabilities` 还把 FIPS-140、HIPAA、PCI 这类外部标准纳入服务级描述。 | 安全 review 不能只看 data plane，要把 management plane 的传输安全、合规声明和服务级约束一起审。 | A | 仍缺 authN/authZ、证书生命周期和 cipher suite 的细节。 |
| Gate 7 / Gate 8: interoperability / conformance | SNIA Swordfish CTP + CTP Results + Interop Guide / Profile Bundle 指针 | 无本地快照 | evaluation | 官方 CTP 用 vendor-neutral、open source test suite 验证特定版本的 Swordfish 符合性，并公开符合性产品列表；规范还把 Interop Guide、Profile Bundle、Schema Bundle 作为正式配套。 | checklist 应要求可追溯的符合性证据、测试版本和 profile 绑定，而不是“兼容”口头承诺。 | A | 需要更细的 test catalog / coverage matrix 才能把合规写成 hard gate。 |
| Gate 8: 生命周期 / 运行手册 / 异步操作 | SNIA Swordfish portal + SNIA CTP page + DMTF Redfish standards page | 无本地快照 | boundary | 门户当前显示 v1.2.9 Working Draft，但 CTP 页面仍有旧版本措辞；规范同时定义了 create/update/delete 的 201/202/204、skeletal resource、Task Monitor 与 `Status.State` 变化。 | runbook 必须绑定版本、任务监控和状态机，不可直接引用 `latest` 或把草案当成生产结论。 | A | 需要进一步核对 release train 与 CTP 覆盖版本的最新对应关系。 |
