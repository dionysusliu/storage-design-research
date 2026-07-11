# batch-08 crawl report

- Crawl time: 2026-07-11T08:04:09Z
- Shard rule: linked-only ordinal n % 10 == 7
- Processed: 45
- Fetched: 28
- Failed: 10
- Skipped: 7

## Limits

- curl was rerun with proxy variables cleared and elevated network access; remaining fetch failures are external retry results from that run.
- Public HTTP/HTTPS pages were saved as HTML and converted to Markdown with pandoc. Login, CAPTCHA, strong JavaScript shells, malformed annotated URLs, non-web binaries, and unsuitable content types were recorded rather than synthesized.

## Priority local Markdown

- text/9b3abb88ef0fa277.md - NUMA docs / 官方文档
- text/157e65d403f353f8.md - block/ docs / 官方文档+源码
- text/38233eae10332e84.md - fscrypt docs / 官方文档
- text/28601a0e6b56705e.md - linux-nvme 邮件列表 / 子系统列表
- text/db76f7d301935380.md - Advisor / 设计与分析工具
- text/017a66ee659e4e5f.md - Tech Blog/Newsroom / 技术博客与新闻
- text/b0a928a0c0749f62.md - Cloudian HyperStore / 产品+文档
- text/9ff807aedc39a0e6.md - Hitachi社区博客 / 社区+博客
- text/81639e23ef20409d.md - MinIO / 文档+开源仓库
- text/c9a1dfd536f4b50c.md - Nutanix 产品 / 产品入口+开发者门户
- text/f3517d2a2e7fed98.md - Red Hat 技术入口 / 官方文档+上游项目
- text/14d02ebf27b5adce.md - Scality blog / 技术博客+资源

## Failure summary

- failed-fetch: 8
- failed-js-login-or-access: 2
- skipped-malformed-url: 1
- skipped-non-html: 5
- skipped-non-web: 1
