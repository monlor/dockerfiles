## 介绍

搭建一个用于流媒体/AI解锁的 DNS 服务器。容器内的入口程序会定期通过
FOFA 获取出口 IP，自动生成 dnsmasq 规则，并按照服务可用性与地区优先级
进行切换。

## 部署

```
docker run -d --name media-unlock \
  -e FOFA_KEY=xxxxxxxx \
  -e TARGET_REGION=US \
  -e UPDATE_DAYS=3 \
  -e CHECK_INTERVAL=60 \
  -p 53:53/udp monlor/media-unlock
```

## 环境变量

| 变量名 | 默认值 | 说明 |
| --- | --- | --- |
| `FOFA_KEY` | — | **必填**，FOFA API Key |
| `FOFA_EMAIL` | — | FOFA 账户邮箱，可选 |
| `TARGET_REGION` | `US` | 首选地区代码 |
| `FALLBACK_REGION` | 空 | 备选地区代码，当前地区无可用 IP 时启用 |
| `FOFA_LIMIT` | `10` | 每个地区获取的 IP 数量 |
| `FOFA_TIMEOUT` | `8` | 单次检测超时（秒） |
| `FOFA_WORKERS` | `8` | 并发检测线程数 |
| `UPDATE_DAYS` | `3` | FOFA 数据刷新周期（天） |
| `CHECK_INTERVAL` | `60` | IP 可用性检测间隔（秒） |
| `SERVICES` | `netflix,disney_plus,hbo_max,chatgpt,claude,gemini,meta_ai,bing` | 需要维护的服务列表 |
| `FOFA_CACHE` | `/tmp/fofa_cache.json` | FOFA 缓存文件路径 |
| `DNSMASQ_CONF` | `/etc/dnsmasq.conf` | dnsmasq 配置文件路径 |
| `DOMAINS_ROOT` | `/app/domains` | 服务域名列表目录 |
| `MEDIA_COOKIE_URL` | 远程地址 | Disney+ Cookie 数据源，支持留空启用本地 `MEDIA_COOKIE_LOCAL` |
| `MEDIA_COOKIE_LOCAL` | `/app/data/media_cookies.txt` | Disney+ Cookie 本地文件 |
