# Reference 下载缺口

本文件记录没有保存为原始本地文件、但仍保留 URL 和分析的来源。

| 来源 | 原因 | 保留位置 | 后续动作 |
| --- | --- | --- | --- |
| 动态官方文档/博客 | 页面内容由脚本或站点 API 生成，直接下载不稳定 | 对应主题 Markdown 和 manifest | 记录访问日期，必要时保存 PDF/打印版 |
| 邮件列表/社区讨论 | 内容是线程集合，不适合无边界打包 | 社区 reference + 原始线程 URL | 按具体线程继续核验 |
| GitHub/GitLab 仓库 | 仓库过大，不能整库复制 | 源码入口、commit/tree URL、分析 Markdown | 对关键文件保存 commit 固定链接 |
| 需要登录或厂商门户 | 公开入口存在但正文受权限限制 | manifest + 缺口记录 | 寻找公开 PDF、博客或会议版本 |
| 重复首页/导航页 | 与更具体的 canonical 文档重复 | 保留 raw URL，归并到 canonical group | 不重复下载 |

## 本轮具体失败

| 来源 | 状态 | 说明 |
| --- | --- | --- |
| HPE Nimble/Alletra controller failover PDF | `linked-only` | 只拿到 landing page/标题级信息，正文下载连接无响应 |
| HPE Nimble/Alletra transition PDF | `failed` | 远端连接无响应，未生成可信 PDF |
| HPE Nimble/Alletra architecture PDF | `failed` | 远端连接无响应，未生成可信 PDF |
| Flash Memory Summit proceedings | `failed` | Web 访问返回 cache miss，保留官方 URL 和分析卡片 |
| Linux block mailing list | `failed` | 当前抓取返回 `Internal Error`，保留 lore URL |
| OpenEBS Mayastor page | `linked-only` | 分析 agent 访问失败，保留 URL 和版本线索 |

SeaweedFS architecture PDF 已通过 GitHub raw 镜像成功下载，故不再作为失败项。
