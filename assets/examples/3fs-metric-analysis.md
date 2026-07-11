# 3FS Metric Deep-Dive Example: service startup and lifecycle observability

这个文件示范 `entries/metrics/<entry-slug>.md` 或 `entries/universal-metrics/<entry-slug>.md` 的写法。它不是完整 3FS 结论；真实调研必须在本地目标仓库补齐行号、服务类实现、配置和测试文档。

## Metric

- Metric: service startup readiness / lifecycle observability
- Architecture link: management plane / service lifecycle boundary
- Status: `gray`
- Reason: 入口代码能确认 meta/storage 服务通过共享 lifecycle framework 启动，但尚未读到 readiness signal、metrics export、shutdown drain 和 failure reporting 的完整实现。

## Code Logic Under Analysis

已确认代码锚点：

`src/meta/meta.cpp`:

```cpp
return TwoPhaseApplication<meta::server::MetaServer>().run(argc, argv);
```

`src/storage/storage.cpp`:

```cpp
return TwoPhaseApplication<storage::StorageServer>().run(argc, argv);
```

代码分析：

- startup readiness 不能从 `main()` 本身得出；必须追 `TwoPhaseApplication<T>::run()` 是否区分 parse config、init dependency、register service、start background workers、become ready 等阶段。
- meta 与 storage 使用同一个 app framework，说明 lifecycle metric 需要拆成共享部分和服务特有部分。共享部分可能包括配置解析、日志、signal、退出码；服务特有部分可能包括 metadata store 连接、storage worker/chunk/AIO 初始化。
- 如果 `run()` 在服务真正可接收请求前就返回 ready 或注册 RPC，readiness metric 会高估可用性；如果 shutdown 不 drain 队列，availability/recovery metric 会低估失败风险。

## Worked Example

场景：storage service 进程启动。

1. `src/storage/storage.cpp::main()` 调用 `TwoPhaseApplication<storage::StorageServer>().run(argc, argv)`。
2. `TwoPhaseApplication` 可能解析配置、构造 `StorageServer`、执行 first phase init、执行 second phase start。
3. `StorageServer` 可能初始化 worker、store、chunk engine、AIO 或 RPC service。
4. readiness metric 应该只在依赖全部完成、错误路径可报告、服务可接收请求后变为 ready。

当前例子是“待验证例子”：第 2-4 步必须通过 `common/app/TwoPhaseApplication.h` 和 `src/storage/service/StorageServer.*` 确认，不能把它写成已验证事实。

## Related Documents

需要寻找并分析：

- `README.md` 或 docs 中的 deployment / service startup 描述。
- `configs/` 中 meta/storage 服务配置和默认值。
- `deploy/`、container、systemd、Kubernetes 或脚本中的 readiness/liveness 配置。
- benchmark 文档是否说明服务预热、启动顺序、失败重试。
- tests 中是否覆盖配置错误、依赖失败、restart、shutdown drain。

如果这些材料不存在，metric 文档必须写成项目文档缺口，而不是沉默跳过。

## Methodology

验证方法应在代码分析之后设计：

- 静态确认 lifecycle 阶段和 ready 条件。
- 添加 trace/log 观察 config parse、dependency init、RPC registration、worker start 的时间点。
- 故障注入：metadata store unavailable、device path unavailable、配置错误、worker start failure。
- 度量：time-to-ready、failed-start exit code correctness、shutdown drain time、restart success rate。

## Network / External Context

外部材料只用于方法学对照，例如 Kubernetes readiness/liveness、systemd watchdog、分布式存储服务启动顺序经验、厂商 runbook。它们不能证明 3FS 的实现正确，只能帮助判断本项目缺哪些 lifecycle artifact。

## Cannot Claim

- 不能宣称 startup readiness 正确，除非追到 ready signal 的代码边界。
- 不能宣称 shutdown 安全，除非追到 queue drain、RPC reject、flush/commit 和退出路径。
- 不能宣称 benchmark 可复现，除非文档说明服务预热、配置、数据集和失败重试。

## Next Probes

1. 读取 `common/app/TwoPhaseApplication.h`，列出 lifecycle phases 和错误传播。
2. 读取 `src/meta/service/MetaServer.*` 与 `src/storage/service/StorageServer.*`，确认服务特有 readiness 条件。
3. 搜索 `configs/`、`deploy/`、`tests/` 中 readiness、startup、shutdown、restart 相关材料。
4. 形成代码假设后，再设计 failure injection 和 trace 验证。

