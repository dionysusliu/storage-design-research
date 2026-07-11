# 3FS Entry Deep-Dive Example: management and service lifecycle boundary

这个文件示范一个 `entries/architecture/<entry-slug>.md` 应该怎样从组件分析回填 checklist entry。它不是完整 3FS 结论，只展示写法。

## Entry

- Section: Architecture Checklist
- Entry: management plane / service lifecycle / operability boundary
- Question: 系统的服务进程如何启动、初始化、停止、暴露配置和错误边界？这些生命周期逻辑是否跨 metadata 与 storage 服务共享？

## Verdict

当前裁决：`需补 ADR`

原因：入口代码已经显示 metadata service 和 storage service 都通过 `TwoPhaseApplication` 启动，说明有共享生命周期框架；但尚未追 `TwoPhaseApplication` 和服务类接口，不能判断初始化顺序、失败回滚、signal、配置校验、可观测性和 shutdown 语义是否完整。

## Component Context

- `components/meta/overview.md`：应覆盖 `src/meta/meta.cpp`、`meta::server::MetaServer`、metadata store 依赖。
- `components/storage/overview.md`：应覆盖 `src/storage/storage.cpp`、`storage::StorageServer`、worker/chunk/AIO 依赖。
- `components/common-app/two-phase-application.md`：应覆盖 `common/app/TwoPhaseApplication.h` 的 lifecycle contract。
- `components/memory/override-new-delete.md`：应覆盖 `memory/common/OverrideCppNewDelete.h` 的全局影响。
- `04-cross-component-interactions.md`：应画出服务入口、生命周期框架、内存层、RPC/service 初始化之间的关系。

## Detailed Code Analysis

### Code facts already established

`src/meta/meta.cpp`:

```cpp
return TwoPhaseApplication<meta::server::MetaServer>().run(argc, argv);
```

`src/storage/storage.cpp`:

```cpp
return TwoPhaseApplication<storage::StorageServer>().run(argc, argv);
```

这两个入口共同证明：

- `MetaServer` 和 `StorageServer` 是进程生命周期的模板参数，不是普通工具类。
- `TwoPhaseApplication` 是至少两个服务共享的启动框架，可能决定配置解析、日志、初始化 phase、退出码和错误传播。
- management/operability 分析必须先读 shared app framework，再读各服务的实现差异；不能只看单个服务的 README 或部署脚本。

### Required next code traversal

| Target | Why it matters | Questions |
| --- | --- | --- |
| `common/app/TwoPhaseApplication.h` | 共享生命周期合同 | 两个 phase 是什么？失败时如何停止已经启动的组件？是否统一 signal/exit code？ |
| `src/meta/service/MetaServer.h` and implementation | metadata service lifecycle | init/start/stop 注册哪些 RPC、后台任务、store 连接？ |
| `src/storage/service/StorageServer.h` and implementation | storage service lifecycle | worker、store、chunk engine、AIO 如何初始化和停止？ |
| `configs/` and deploy files | 配置与部署合同 | 哪些配置是必填？默认值是否安全？是否区分 meta/storage？ |
| tests for service startup/shutdown | 验证生命周期边界 | 是否有失败注入、重启、配置错误测试？ |

## Project Document Analysis

项目文档可以帮助解释为什么 metadata 和 storage 是独立服务、如何部署、如何配置。但文档不能证明生命周期正确性。若文档声称“服务可平滑重启”或“配置热更新”，必须回到上述代码路径验证。

## Network / External Evaluation

外部评价或 benchmark 只可用于判断这个 lifecycle 设计在实际部署中是否暴露问题。例如 issue、blog、release note 可以提示常见故障模式，但不能替代代码层的 init/stop/error-path 分析。

## Source Locator

| kind | location | why_relevant | limitation |
| --- | --- | --- | --- |
| code | `src/meta/meta.cpp` | metadata service process entry | 只显示入口，不显示生命周期细节 |
| code | `src/storage/storage.cpp` | storage service process entry | 只显示入口，不显示 worker/store/AIO 初始化 |
| code | `common/app/TwoPhaseApplication.h` | shared lifecycle framework | 尚未读取 |
| code | `memory/common/OverrideCppNewDelete.h` | global allocator side effect | 尚未读取 |

## Cannot Claim

- 不能宣称 lifecycle 是 crash-safe 或 restart-safe。
- 不能宣称配置校验完整。
- 不能宣称 shutdown 会 drain request 或 durable flush。
- 不能宣称 metadata/storage 两个服务有同等可观测性。

## Gaps

- 缺 `TwoPhaseApplication` 源码分析。
- 缺 `MetaServer` 和 `StorageServer` 的 lifecycle method 分析。
- 缺 signal、config、logging、metrics、shutdown、failure injection 的代码路径。
- 缺项目文档与部署脚本对生命周期的承诺对照。

## Next Probes

1. 读取 `common/app/TwoPhaseApplication.h`，提取 service interface、phase 顺序和错误处理。
2. 读取 `src/meta/service/MetaServer.*`，写出 init/start/stop 调用链。
3. 读取 `src/storage/service/StorageServer.*`，写出 worker/store/AIO 初始化和停止顺序。
4. 搜索 `configs/`、`deploy/`、`tests/` 中 meta/storage 服务启动相关项，补项目文档和测试定位。
5. 如果代码分析形成 shutdown/drain 假设，再设计 restart/failure-injection 验证；不要先用测试结果替代源码分析。

