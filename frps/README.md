## 介绍

不用写配置文件,通过变量快速启动一套简单的frps服务端

## 环境变量说明

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `BIND_PORT` | frps 服务端监听端口 | `7000` |
| `VHOST_HTTP_PORT` | HTTP 虚拟主机端口 | `8080` |
| `VHOST_HTTPS_PORT` | HTTPS 虚拟主机端口 | `8443` |
| `DASHBOARD_PORT` | Dashboard 访问端口 | `7500` |
| `DASHBOARD_USER` | Dashboard 用户名 | 无（不启用 Dashboard） |
| `DASHBOARD_PWD` | Dashboard 密码 | 无（不启用 Dashboard） |
| `AUTH_TOKEN` | frpc 与 frps 认证令牌 | `SUQAKTMb87` |
| `HEARTBEAT_TIMEOUT` | 心跳超时时间（秒） | `90` |
| `MAX_POOL_COUNT` | 每个代理的最大连接池数量 | `5` |
| `MAX_PORTS_PER_CLIENT` | 每个客户端最多可使用的端口数（0 表示不限制） | `0` |
| `ALLOW_PORTS` | 允许的端口范围 | 无 |

**注意：** 只有当 `DASHBOARD_USER` 和 `DASHBOARD_PWD` 都不为空时，Dashboard 才会启用。

## 使用方式

### 最简部署

frps 服务端端口 7000，HTTP 服务端口 8080

```bash
docker run -d --name frps \
  -e AUTH_TOKEN=SUQAKTMb87 \
  --network=host \
  --restart=unless-stopped \
  monlor/frps:latest
```

### 启用 Dashboard

frps 服务端端口 7000，HTTP 服务端口 8080，Dashboard 端口 7500

```bash
docker run -d --name frps \
  -e DASHBOARD_USER=admin \
  -e DASHBOARD_PWD=7RFPyAXYxc \
  -e AUTH_TOKEN=SUQAKTMb87 \
  --network=host \
  --restart=unless-stopped \
  monlor/frps:latest
```

### 自定义端口配置

```bash
docker run -d --name frps \
  -e BIND_PORT=7000 \
  -e VHOST_HTTP_PORT=8080 \
  -e VHOST_HTTPS_PORT=8443 \
  -e DASHBOARD_PORT=7500 \
  -e DASHBOARD_USER=admin \
  -e DASHBOARD_PWD=7RFPyAXYxc \
  -e AUTH_TOKEN=SUQAKTMb87 \
  --network=host \
  --restart=unless-stopped \
  monlor/frps:latest
```

### 完整配置示例

包含所有高级配置选项

```bash
docker run -d --name frps \
  -e BIND_PORT=7000 \
  -e VHOST_HTTP_PORT=8080 \
  -e VHOST_HTTPS_PORT=8443 \
  -e DASHBOARD_PORT=7500 \
  -e DASHBOARD_USER=admin \
  -e DASHBOARD_PWD=7RFPyAXYxc \
  -e AUTH_TOKEN=SUQAKTMb87 \
  -e HEARTBEAT_TIMEOUT=90 \
  -e MAX_POOL_COUNT=10 \
  -e MAX_PORTS_PER_CLIENT=5 \
  -e ALLOW_PORTS=2000-3000,3001,3003,4000-50000 \
  --network=host \
  --restart=unless-stopped \
  monlor/frps:latest
```

### 不启用 Dashboard

只需不设置 `DASHBOARD_USER` 和 `DASHBOARD_PWD` 即可

```bash
docker run -d --name frps \
  -e AUTH_TOKEN=SUQAKTMb87 \
  --network=host \
  --restart=unless-stopped \
  monlor/frps:latest
```
