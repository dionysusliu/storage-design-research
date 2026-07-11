# 证据策略

## 本地代码优先级

按这个顺序取证：

1. 构建入口、配置、启动脚本、部署文件。
2. 对外 API、协议定义、RPC、CLI、SDK。
3. 读写路径入口和核心调度循环。
4. metadata、manifest、WAL、journal、placement、membership、lease。
5. cache、buffer、memory pool、DMA、I/O backend。
6. recovery、replay、repair、GC、compaction、rebuild、rebalance。
7. metrics、trace、logs、profiling、benchmark、tests、failpoints。
8. README、设计文档、issue、PR、release note。

## 外部材料

需要外部材料时优先使用：
- 官方文档和源代码。
- 原始论文、作者 slide、技术报告。
- benchmark 原文和实验方法。
- 项目维护者的设计 issue 或 ADR。

不要用二手博客替代协议、语义或性能结论。二手材料只能作为线索。

## 代码阅读方法

对每条关键路径做“入口到完成点”的符号追踪：

1. 找入口函数或 RPC handler。
2. 找 request/context 对象和 request ID。
3. 找线程、队列、future、coroutine、reactor 或 callback 边界。
4. 找日志、复制、flush、fsync、commit、ack。
5. 找错误、重试、取消、超时和 cleanup。
6. 找 metrics 或 trace span 验证路径。

## 证据不足时

不要停在“需要更多信息”。给出最小探针：
- 文件探针：还应读哪个目录或符号。
- 运行探针：还应跑哪个测试、demo、benchmark 或 fault case。
- 观测探针：还应加哪个 metric、trace span、counter 或 log。
- 实验探针：还应扫描哪个 size、QD、并发、读写比、故障或稳态窗口。

