## 介绍

不用写配置文件,通过变量快速启动一套简单的 frps 服务端

**版本：v0.65.0** - 配置格式已从 INI 迁移到 TOML（向后兼容，环境变量保持不变）

## 环境变量说明

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `BIND_ADDR` | frps 服务端监听地址（IPv4/IPv6） | `0.0.0.0` |
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
| `ALLOW_PORTS` | 允许的端口范围（格式：`2000-3000,3001,4000-50000`） | 无 |

**注意：** 只有当 `DASHBOARD_USER` 和 `DASHBOARD_PWD` 都不为空时，Dashboard 才会启用。

## 版本说明

### v0.65.0 更新

- ✅ 配置文件格式从 **INI** 迁移到 **TOML**（INI 格式已废弃）
- ✅ 参数命名规范更新为 camelCase（如 `bindPort`、`vhostHTTPPort`）
- ✅ Dashboard 配置更新为 `webServer.*` 格式
- ✅ 认证配置更新为 `auth.method` 和 `auth.token`
- ✅ 传输设置移至 `transport.*` 命名空间
- ℹ️ **环境变量保持不变**，向后兼容旧版配置

详细更新说明请参考：
- [frp v0.65.0 Release Notes](https://github.com/fatedier/frp/releases/tag/v0.65.0)
- [配置文件官方文档](https://gofrp.org/en/docs/features/common/configure/)

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
  -e BIND_ADDR=0.0.0.0 \
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
  -e BIND_ADDR=0.0.0.0 \
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

## 常见问题

### host 网络模式下外网无法访问

**现象**：使用 `--network=host` 时，端口显示监听但外网无法访问；使用 `-p` 端口映射则正常。

**原因**：在某些系统上，frps 可能只监听 IPv6（:::），而系统的 `net.ipv6.bindv6only=1` 导致 IPv6 socket 不接受 IPv4 连接。

**解决方案**：显式设置 `BIND_ADDR=0.0.0.0` 强制监听 IPv4：

```bash
docker run -d --name frps \
  -e BIND_ADDR=0.0.0.0 \
  -e AUTH_TOKEN=SUQAKTMb87 \
  --network=host \
  monlor/frps:latest
```

验证是否监听 IPv4：
```bash
netstat -tulnp | grep frps
# 应该看到：tcp        0      0 0.0.0.0:7000            0.0.0.0:*               LISTEN
# 而不是： tcp6       0      0 :::7000                 :::*                    LISTEN
```

## 迁移指南

如果你从旧版本（v0.49.0 或更早）升级到 v0.65.0：

1. **环境变量无需改动** - 所有环境变量名称保持不变
2. **配置文件格式已自动处理** - entrypoint.sh 会自动生成 TOML 格式配置
3. **向后兼容** - 原有的 Docker 启动命令无需修改即可使用

生成的配置文件示例（`/etc/frp/frps.toml`）：

```toml
bindAddr = "0.0.0.0"
bindPort = 7000
vhostHTTPPort = 8080
vhostHTTPSPort = 8443

auth.method = "token"
auth.token = "SUQAKTMb87"

transport.heartbeatTimeout = 90
transport.maxPoolCount = 5

maxPortsPerClient = 0

# WebServer (Dashboard) - 仅在设置用户名和密码时启用
webServer.addr = "0.0.0.0"
webServer.port = 7500
webServer.user = "admin"
webServer.password = "your-password"

# allowPorts - 端口范围限制示例
allowPorts = [
  { start = 2000, end = 3000 },
  { single = 3001 },
  { single = 3003 },
  { start = 4000, end = 50000 }
]
```
