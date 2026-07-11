# Checklist Topic Evidence

生成时间：2026-07-11

本目录把 `../../domain-map.md` 的存储设计检查项聚合成 6 组主题证据表。它回答“某个 checklist 主题背后有哪些机制、边界、claim、评估证据和缺口”，适合作为快速定位入口。

如果需要追溯到某个具体系统、规范、源码或厂商文档，进入 `../source-document-evidence/`。如果需要核对已抓取网页原文，进入 `../web-snapshots/`。

## 文件索引

| 文件 | 覆盖主题 | Evidence 条数 | 主要强证据 | 主要缺口 |
| --- | --- | ---: | --- | --- |
| `01-goals-metadata.md` | 业务目标/工作负载；数据模型/命名/元数据 | 13 | Meta、Discord、Snowflake、Tencent、Alluxio、BeeGFS、Ceph、FoundationDB、Nutanix、VFS | workload matrix、元数据版本演进、mixed-version 和回滚路径仍需补证 |
| `02-layout-paths.md` | 数据布局/分片/放置；读写路径 | 13 | Ceph/CRUSH、Tencent Region/RG、BeeGFS、Alluxio、IBM、Meta、FoundationDB、RocksDB、VFS、blk-mq、DMA/SPDK | 本项目 partition/shard/stripe/region 映射规则、rebalance 限流和端到端时序实测缺失 |
| `03-io-queues.md` | I/O 栈与技术选型；线程/队列/backpressure | 13 | blk-mq、io_uring、NVMe passthrough、NVMe/NVMe-oF、SPDK、DPDK EAL、Alluxio、FoundationDB、RocksDB | RocksDB write stall、FoundationDB Ratekeeper、NVMe 子规范、standalone DPDK 版本化核验仍缺 |
| `04-hardware-durability.md` | CPU/NUMA/PCIe/内存路径；持久化/一致性/复制/EC | 14 | Linux DMA API、SPDK DMA/qpair、CXL/Optane、FoundationDB、Raft/TiKV、Ceph、IBM Storage Scale、Nutanix、NetApp WAFL | Tencent-specific Raft/RG 原文、CXL/Optane upstream 细文档、真实生产 NUMA/PCIe 拓扑例证仍缺 |
| `05-background-recovery.md` | 后台任务/资源治理；故障恢复/升级/演进 | 11 | RocksDB、Dropbox Magic Pocket、Ceph、IBM FlashSystem/Storage Scale、Nutanix、Meta、Discord、OneFS、BeeGFS | Ceph recovery runbook、RocksDB stall 参数、HPE PSNow 正文、故障注入矩阵和统一 SLO 仍缺 |
| `06-observability-benchmark-cost.md` | 观测/安全/多租户；Benchmark/Artifact；成本/功耗/运维/升级 | 15 | Datadog、NVM Express/SNIA、Linux DMA、SPDK、FAST、OSDI/NSDI artifact、Intel VTune、Nsight、Meta migration、IBM/Dell、CXL/Optane | fio 原始手册、Swordfish 规范正文、Dell/IBM 具体 runbook、CXL/Optane 产品级生命周期仍缺 |

总计：79 条 evidence。

## 字段说明

| 字段 | 含义 |
| --- | --- |
| `check_item` | 对应 checklist v0 的检查问题或主题标签 |
| `source` | 来源系统、组织、文档或文章 |
| `local_ref` | 本地 reference card 或 Markdown 快照路径 |
| `evidence_type` | `mechanism`、`boundary`、`claim`、`evaluation`、`gap`、`counterexample` |
| `evidence_note` | 中文证据概括，不长篇复制正文 |
| `design_pressure` | 对 checklist 形成的设计约束、问题或警告 |
| `confidence` | `A`、`B`、`C`、`D` |
| `gap` | 还缺什么才能变成可验证结论 |

## 使用方式

1. 先从 `../../domain-map.md` 选择一个检查项。
2. 在本目录中查找对应主题文件。
3. 根据 `evidence_type` 区分机制事实、边界条件、厂商/博客 claim、评估证据和缺口。
4. 需要具体来源文档时，跳到 `../source-document-evidence/README.md` 选择对应文件。
5. 对 `claim` 类型证据，不直接写成设计结论；需要补方法学、独立证据或实验。
6. 对 `gap` 和 `D` 级证据，保留为待补证项，不写进最终 checklist 事实。

## 下一步输入

这些 evidence table 可直接作为 `../../domain-map.md` 的输入，用于判断：

- 哪些 checklist 项已有 A/B 级机制证据，可以保留。
- 哪些 checklist 项只有 claim，需要降级表述或补 benchmark。
- 哪些 checklist 项重复，可以合并。
- 哪些 checklist 项缺少本地证据，应标为待补证。
