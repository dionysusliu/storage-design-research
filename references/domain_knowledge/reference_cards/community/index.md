# Community 主题参考卡

分析范围：本文件仅基于 2026-07-11 访问时可见的官方网页或原始索引页做分析卡片，不下载 raw 文件，不展开附件，不修改主 checklist 或其他文件。

证据等级说明：
- `A`：官方来源，页面内容直读且信息足够具体，可直接复核。
- `B`：官方来源，但页面偏动态首页、活动页或目录页，适合快照引用。
- `C`：官方索引页或信息粒度有限，适合辅助定位，不宜单独承担关键结论。
- `D`：URL 抓取失败或无法确认页面内容。

## 1. FAST '25 Call for Papers

- 标题：FAST '25 Call for Papers
- 组织/团队：USENIX，in cooperation with ACM SIGOPS
- 资料类型：会议征稿页，包含投稿范围、投稿规则、时间表、页面限制与双盲政策
- URL：https://www.usenix.org/conference/fast25/call-for-papers
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：FAST '25 会议页面，会议时间为 2025-02-25 到 2025-02-27；投稿截止为 2024-09-17，属于已归档历史页面
- 关键机制或文档内容：论文最长 12 页、短文最长 6 页，不含参考文献；补充材料单独 PDF 且作者不保证审阅；必须双盲；允许短文与 deployed-system paper 两类提交，且需要前缀标注；通过 HotCRP 提交，不接受邮件投稿；作者回复期 1000 词；主题覆盖存储设备、分布式存储、文件系统、数据库存储、缓存、复制、可靠性、AI for storage 等
- 对现有 storage checklist 的关联：可直接补进“投稿范围”“artifact/补充材料”“双盲与冲突”“部署经验”“页数限制”这些社区与论文入口条目；对实现细节本身是外围证据，但对筛选研究主题和投稿要求很有用
- 证据等级：A
- 事实：页面明确列出会议时间、截止日期、页数限制、投稿方式和主题范围；页面还明确写了短文、deployed-system paper、作者回复和冲突识别规则
- 推断：这页适合作为 checklist 的“会议入口与投稿约束”总引文档，而不是实现或 benchmark 证据
- 未知/待核验：当前年份之后 FAST 是否继续保留完全相同的页数、短文和 deployed-system 规则，需查看后续年份 call for papers
- 是否适合下载 raw 副本，以及建议文件名：适合，建议 `usenix-fast25-call-for-papers-20260711.html`

## 2. FAST '25 Technical Sessions

- 标题：FAST '25 Technical Sessions
- 组织/团队：USENIX FAST '25 会议组委会
- 资料类型：会议程序页，包含论文分会场、poster、WiP、test-of-time award、proceedings 下载入口
- URL：https://www.usenix.org/conference/fast25/technical-sessions
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：FAST '25 会议程序归档页；页面列出 Wednesday, February 26 和 Thursday, February 27 的议程，属于已完成会议的历史快照
- 关键机制或文档内容：页面说明所有 session 默认在 Santa Clara Ballroom 举行；提供完整 proceedings PDF 和 mobile-friendly interior PDF；单篇论文可以从各自 presentation page 下载；议程按天、时间段和 session 组织，并带有 “Available Media” 链接
- 对现有 storage checklist 的关联：适合补“已发表论文定位”“演讲/幻灯片/媒体资源”“会议现场议程”“同主题论文聚类”条目，可用于追踪 storage 方向的代表作与同场比较论文
- 证据等级：A
- 事实：页面直观显示 proceedings 下载入口、单篇论文入口和按天的会场安排；页面包含 poster session、WiPs 和 award presentation 等模块
- 推断：如果 checklist 需要“从会议程序反查代表性论文”，这页比 CFP 更适合作为入口，因为它直接把论文标题和议程绑定起来
- 未知/待核验：`Available Media` 链接具体包含视频还是幻灯片，页面未在当前抓取片段中完全展开；如需精确媒体类型，需要继续点开各论文 presentation page
- 是否适合下载 raw 副本，以及建议文件名：适合，建议 `usenix-fast25-technical-sessions-20260711.html`

## 3. OSDI '26 Call for Artifacts

- 标题：OSDI '26 Call for Artifacts
- 组织/团队：USENIX OSDI '26 Artifact Evaluation Committee
- 资料类型：artifact evaluation 说明页，包含提交流程、badging、README 结构、匿名与安全要求
- URL：https://www.usenix.org/conference/osdi26/call-for-artifacts
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：OSDI '26 过程说明页；页面给出 2026-03-26、2026-05-08、2026-06-01、2026-06-09 等关键日期，整体上属于已过时点的年度流程页
- 关键机制或文档内容：artifact evaluation 是 optional 且 single-blind；提交需要 accepted paper、artifact 本体、README；README 必须分为 Getting Started Instructions 和 Detailed Instructions；建议单页稳定 URL 承载整个 artifact package；若 artifact 具有恶意或破坏性行为，必须在 README 里显著标明；不允许物理对象，支持软件、数据集、test suites、mechanized proofs 等数字 artifacts
- 对现有 storage checklist 的关联：非常适合补“复现包规范”“artifact 可用性”“README 最小结构”“单盲/匿名”“稳定 URL”“危险 artifact 标记”条目，是 storage 论文和系统原型进入社区时最直接的流程证据
- 证据等级：A
- 事实：页面明确给出 single-blind、badges、README 两段式、稳定 URL、ready for review、analytics/tracking 禁止等规则
- 推断：这页更偏向“如何把 storage 系统研究成果包装成可审查 artifact”，而不是 artifact 评估结果本身
- 未知/待核验：OSDI '26 的最终 badge 细则和 artifact appendix 模板虽有链接，但本次未展开模板正文
- 是否适合下载 raw 副本，以及建议文件名：适合，建议 `usenix-osdi26-call-for-artifacts-20260711.html`

## 4. NSDI '26 Call for Artifacts

- 标题：NSDI '26 Call for Artifacts
- 组织/团队：USENIX NSDI '26 Artifact Evaluation Committee
- 资料类型：artifact evaluation 说明页，包含双周期提交、badging、review flow、README 与包装格式
- URL：https://www.usenix.org/conference/nsdi26/call-for-artifacts
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：NSDI '26 过程说明页；页面同时包含 Spring 和 Fall 两个 deadline 组，且时间线跨 2025-07 到 2026-03，属于已过期流程页
- 关键机制或文档内容：artifact evaluation 仅在论文条件接受后开放；badges 分为 Artifacts Available、Artifacts Functional、Results Reproduced；提交是两步制，先 registration 再 submission；提交方式允许 stable URL 或 archive，并可用受保护访问；review 分 kick-the-tires 与 full evaluation；README 要包含 Getting Started 和 Detailed Instructions；支持 source code、VM/container、binary installer、web live instance、internet-accessible hardware 等包装方式；禁止 analytics/tracking
- 对现有 storage checklist 的关联：对 storage 原型、benchmarks、验证脚本、复现实验和硬件依赖包装最相关，可补“artifact 分级目标”“复现深度”“提交打包格式”“提交窗口”条目
- 证据等级：A
- 事实：页面清楚写出了三类 badge、两阶段 review、两步提交、README 要求和可接受 artifact 形态
- 推断：NSDI 的流程比 OSDI 更强调“结果可复现”和“可下载可运行”的可操作性，适合作为 storage project 的交付模板
- 未知/待核验：Artifacts Available / Functional / Results Reproduced 三类 badge 的实际授予比例与历史通过率，本页没有给出
- 是否适合下载 raw 副本，以及建议文件名：适合，建议 `usenix-nsdi26-call-for-artifacts-20260711.html`

## 5. SOSP 目录页

- 标题：Index of /s/conferences/sosp/
- 组织/团队：SIGOPS / SOSP 目录索引
- 资料类型：原始目录索引页，不是叙述性文档页
- URL：https://www.sigops.org/s/conferences/sosp/
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：目录包含 1999 到 2026 的年份子目录；当前可见的最新子目录是 2026，last modified 为 2026-06-15；页面本身没有正文型发布日期
- 关键机制或文档内容：页面只提供按年份组织的目录列表，属于 proceedings / conference materials 的索引入口；没有 API、投稿规则或技术细节正文
- 对现有 storage checklist 的关联：适合补“顶级系统会议档案入口”“按年份追溯 SOSP 资料”“与 FAST/NSDI/OSDI 并列的社区参照”条目；对实现细节没有直接帮助，但对会议信息定位有用
- 证据等级：C
- 事实：页面是纯目录索引，并列出多个年份目录及其最后修改时间
- 推断：这页更像“历史档案门牌号”，适合做社区入口，不适合作为规则或机制引用
- 未知/待核验：每个年份目录内部具体包含什么材料，本次未点开核验
- 是否适合下载 raw 副本，以及建议文件名：适合，建议 `sigops-sosp-index-20260711.html`

## 6. SNIA 首页

- 标题：SNIA | Experts on Data
- 组织/团队：SNIA
- 资料类型：组织主页，包含使命、技术工作、标准、教育资源、成员、群组、活动和新闻入口
- URL：https://www.snia.org/
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：动态主页快照，页面可见 July 2026 newsletter、July 2026 webinars 和 2026 活动信息；页面页脚显示 Copyright © 2024 SNIA
- 关键机制或文档内容：SNIA 声称其成员协作开发 vendor-neutral architectures、standards 和 education；导航里可见 Technical Specifications、Open for Public Review、Standards and Software、Cloud Data Management Interface (CDMI)、SNIA Emerald、I/O Traces Tools & Analysis Repository、RWSW、SDXI、SSS PTS、Swordfish 等；教育资源包括 Educational Library、Videos、Podcasts、Blogs、SNIA Dictionary；Groups 区域列出 Cloud Storage Technologies、Compute, Memory, and Storage、Computational Storage、Persistent Memory、Solid State Storage、Storage Management、Swordfish 等主题
- 对现有 storage checklist 的关联：适合补“标准组织”“社区/工作组”“教育/白皮书”“事件日历”“术语与资源库”条目；如果 checklist 需要判定某项技术是否属于行业标准生态，这页是上游入口
- 证据等级：B
- 事实：主页明确把 SNIA 定位为数据技术的标准与教育组织，并列出多个技术工作组、标准和教育资源入口
- 推断：SNIA 更适合当“标准与社区图谱”的锚点，而不是单篇技术结论来源
- 未知/待核验：主页上的各标准条目当前状态、是否公开征求意见、以及各工作组的最新交付物，需要进一步点开对应页面
- 是否适合下载 raw 副本，以及建议文件名：适合，建议 `snia-home-20260711.html`

## 7. CNCF Events

- 标题：Events | CNCF
- 组织/团队：Cloud Native Computing Foundation
- 资料类型：活动总览页，包含活动类型说明和活动列表
- URL：https://www.cncf.io/events/
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：动态活动页快照，页面显示 2026 年 7 月到 9 月的 upcoming events，并列出 42 个 upcoming events；内容会随日期频繁变化
- 关键机制或文档内容：页面把活动分成 Co-located Events、Project Events、Virtual Project Events 和 KCD Events；KubeCon + CloudNativeCon 是旗舰会议；Co-located events 聚焦某个 CNCF project、landscape layer 或行业垂直；Project events 强调项目深度和社区参与；Virtual Project Events 强调线上社区增长；KCD 强调本地 cloud native 社区与首次讲者机会；列表区支持按国家和 host 过滤
- 对现有 storage checklist 的关联：适合补“云原生社区活动”“项目生态跟踪”“会议/活动日历”“与存储相关的 CNCF 邻域项目观察”条目；对存储系统本身是外围信号，但对产业生态跟踪很有价值
- 证据等级：B
- 事实：页面直白列出四类活动类型、过滤条件和未来活动条目
- 推断：如果 checklist 追踪存储项目在云原生生态中的活动，这页可以用来补活动日程和社区曝光度
- 未知/待核验：具体每场活动的议程、CFP、赞助与报名细则需要点进各活动子页面或外部活动站
- 是否适合下载 raw 副本，以及建议文件名：适合，建议 `cncf-events-20260711.html`

## 8. linux-block 邮件列表归档

- 标题：linux-block 邮件列表归档目录
- 组织/团队：Linux kernel / lore.kernel.org
- 资料类型：邮件列表归档入口，预期对应 block 子系统讨论与补丁流
- URL：https://lore.kernel.org/linux-block/
- 访问日期：2026-07-11
- 版本/发布日期/时间状态：抓取失败；web.open 返回 `Internal Error`，本次无法确认页面内容、目录结构或当前可访问状态
- 关键机制或文档内容：无法从当前访问结果确认
- 对现有 storage checklist 的关联：如果 checklist 包含 Linux block layer、block I/O、补丁讨论或社区追踪，这个入口理论上很关键，但本次无法核验其具体内容
- 证据等级：D
- 事实：仅能确认目标 URL 存在于请求中，不能确认页面正文
- 推断：失败原因更像是抓取层或站点访问限制问题，而不是页面内容不存在
- 未知/待核验：需要重新抓取或改用其他工具确认是否存在 index、镜像或 archive redirect
- 是否适合下载 raw 副本，以及建议文件名：当前不适合，因为页面内容未成功获取；若后续可访问，可用 `lore-linux-block-archive-20260711.html`

## 共同模式、冲突和缺口

- 共同模式：这批来源里，USENIX 页面最强调投稿与 artifact 流程的可操作性，SNIA 和 CNCF 最强调社区、标准、活动和教育资源，SIGOPS 目录页则偏历史档案索引，lore.kernel.org 理论上应是社区讨论源但本次抓取失败。
- 冲突：动态主页和活动页会快速变化，适合做时间点快照，不适合作为长期稳定规则；归档型会议页和 artifact call 页更适合长期引用；目录索引页信息密度低，适合定位，不适合承担机制结论。
- 缺口：这组来源几乎都不直接提供 storage checklist 常见的硬核内容，比如故障注入方法、性能评测协议、持久化不变量、恢复语义或基准数据集；它们更适合补“社区/投稿/复现/标准/日历”层，而不是 core 技术证明层。

