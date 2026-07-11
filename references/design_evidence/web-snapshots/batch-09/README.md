# Batch 09 Web Crawl

抓取时间：2026-07-11 16:02:25 CST

## Scope

- Source: `reference/source-inventory.md`
- Filter: `status=linked-only`
- Shard rule: linked-only ordinal `n % 10 == 8`
- Output owner: `reference/web/batch-09/`
- Network retry: reran with elevated network access and cleared proxy environment variables before `curl`.

## Results

- Processed: 44
- Success: 36
- Failed: 8
- Skipped: 0

Artifacts:

- `results.tsv`: per-URL crawl status, HTTP metadata, local paths, and failure reason.
- `raw/*.html`: raw HTML snapshots for successful HTML responses.
- `raw/*.headers`, `raw/*.meta`, `raw/*.curl.stderr`: request metadata and diagnostics.
- `text/*.md`: Pandoc-converted GitHub Flavored Markdown.
- `crawl-batch-09.sh`: exact local crawler used for this shard.

## Extraction Limits

- HTML pages are converted with `pandoc -f html -t gfm --wrap=none`; navigation chrome, cookie banners, and generated boilerplate may remain.
- Strong JavaScript applications are not browser-rendered; only server-returned HTML is captured.
- Non-HTML downloadable resources are skipped by policy, though this shard did not encounter a skip after filtering.
- Failed entries reflect the elevated, proxy-cleared retry, not the earlier sandbox proxy failure.

Observed failure classes:

- TLS/SSL failure: `https://docs.cloudian.com/`
- Connect timeout: `https://www.purestorage.com/solutions.html`, several `github.com` repository pages, and Discord redirect target.
- DNS resolution failure: `https://docs.vastdata.com/`
- HTTP/2 stream error: `https://www.hpe.com/psnow/doc/`

## Priority Local Markdown

These are the largest or most content-rich local Markdown captures in this shard:

| Entity | Title | URL | Local Markdown |
| --- | --- | --- | --- |
| DDN入口 | 产品+文档 | https://www.ddn.com/ | `reference/web/batch-09/text/88eed097d776a532.md` |
| Red Hat 技术入口 | 官方文档+上游项目 | https://github.com/ceph/ceph | `reference/web/batch-09/text/1d5d1605af265c21.md` |
| block/ docs | 官方文档+源码 | https://github.com/torvalds/linux/tree/master/block | `reference/web/batch-09/text/b82a4eb26a2eef1a.md` |
| Yugabyte 官网 | 分布式 PostgreSQL 兼容数据库 | https://www.yugabyte.com/ | `reference/web/batch-09/text/70f94a8b7d1c3a31.md` |
| Micron Blog | 官方博客 | https://www.micron.com/about/blog | `reference/web/batch-09/text/bdf2ab6a9100dcf7.md` |
| Nutanix 产品 | 产品入口+开发者门户 | https://www.nutanix.com/products/files | `reference/web/batch-09/text/ba6d3ac9a153375a.md` |
| MinIO | 文档+开源仓库 | https://min.io/docs/minio/linux/index.html | `reference/web/batch-09/text/f14a9a68111ae2fa.md` |
| Tech Blog/Newsroom | 技术博客与新闻 | https://semiconductor.samsung.com/news-events/tech-blog/ | `reference/web/batch-09/text/2a2173234bc71ff0.md` |
| NVMe docs/tree | 官方文档+源码 | https://github.com/torvalds/linux/tree/master/drivers/nvme | `reference/web/batch-09/text/4ee1046f73fd41e5.md` |
| Intel persistent memory developer overview | Intel 开发者入口 | https://www.intel.com/content/www/us/en/developer/topic-technology/persistent-memory/ | `reference/web/batch-09/text/1a3e000d4116db01.md` |
| ScyllaDB 官网 | 分布式 NoSQL | https://www.scylladb.com/blog/ | `reference/web/batch-09/text/8d5b2821774f7420.md` |
| Alluxio architecture | 架构文档（深链） | https://docs.alluxio.io/os/user/stable/en/overview/ | `reference/web/batch-09/text/04a23e4a9e5e7ff2.md` |
