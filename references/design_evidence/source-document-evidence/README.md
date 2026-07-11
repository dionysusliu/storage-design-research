# Source Document Evidence

生成时间：2026-07-11

本目录把可以直接追溯到具体系统、规范、源码或厂商文档的补证材料放在一起。旧的优先级批次只表示当时补证优先级；当前目录按“具体文档内容”暴露材料，便于从 `../checklist-topic-evidence/` 或 `../../domain-map.md` 反查到原始机制证据。

## 文件索引

| 文件 | 具体文档/系统内容 | 来源类型 | 主要覆盖 | 影响 gate |
| --- | --- | --- | --- | --- |
| `rocksdb-write-stall.md` | RocksDB write flow、write stall、slowdown、WriteBufferManager 和源码中的 stall 统计 | 官方文档 + 官方源码 | 写入背压、compaction pressure、stall 可观测性 | 4, 6, 7 |
| `foundationdb-ratekeeper.md` | FoundationDB Ratekeeper、storage queue、log queue、事务系统限流 | 官方文档 + 官方源码/配置线索 | 集群级 backpressure、队列治理、角色化限流 | 4, 7 |
| `fio-methodology.md` | fio HOWTO、job file、I/O engine、latency/throughput 统计方法 | 官方手册 | benchmark 方法学、可复现实验 artifact | 7 |
| `ceph-recovery-backfill.md` | Ceph recovery/backfill、degraded behavior、recovery throttling | 官方文档 | 恢复路径、后台任务、degraded mode | 3, 6, 8 |
| `tencent-raft-rg.md` | Tencent TDSQL Boundless / TDStore 的 Region、Replication Group、Raft、路由缓存和事务恢复 | 官方产品文档 | metadata 语义、layout/placement、复制与恢复 | 2, 3, 6, 8 |
| `cxl-optane-lifecycle.md` | CXL memory device、RAS、安全、Optane/PMem 生命周期 | 标准/厂商生命周期资料 | 硬件内存路径、生命周期风险、不可持续依赖 | 5, 8 |
| `snia-swordfish.md` | SNIA Swordfish、Redfish 关系、storage management API、安全和 conformance | 标准组织资料 | 管理面、观测面、安全/合规、运维接口 | 7, 8 |
| `hpe-psnow.md` | HPE PSNow / Alletra / Nimble 的产品页、迁移和 controller failover 可得证据 | 厂商资料 | 运维和生命周期入口；主要是负证据/弱证据边界 | 8 |
| `dpdk-standalone.md` | DPDK EAL、hugepage、lcore、polling、内存模型 | 官方文档 | 用户态 I/O 栈、CPU/内存绑定、polling 与 backpressure | 4, 5 |

## 字段约定

每份文档证据至少包含：

- `Source Inventory`：来源 URL 或本地路径、来源类型、证据等级、抓取状态。
- `Mechanism Notes` / `Methodology Notes`：机制或方法学摘要，不能只列链接。
- `Checklist Impact`：明确影响 `../../domain-map.md` 中哪些架构 gate 或指标项。
- `Open Gaps`：仍不能写成强结论的地方。
- `Evidence Table`：字段与 `../checklist-topic-evidence/` 保持一致。

## 使用规则

- A/B 级机制证据可以回写到 checklist 条目或 mandatory artifacts。
- C 级 claim 只能进入设计压力或红旗信号，不能写成事实。
- D 级或抓取失败只进入补证队列。
- 对 `latest`、动态首页、support hub 和历史文档必须标注生命周期状态。
- 不长篇复制网页正文；以中文摘要、具体 URL、本地快照和可复查 line/source 为主。
