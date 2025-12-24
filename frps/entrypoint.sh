#!/bin/sh

if [ ! -d /etc/frp ]; then
  mkdir -p /etc/frp
fi

cat > /etc/frp/frps.ini <<EOF
[common]
bind_port = ${BIND_PORT:-7000}

# 只有 bind_addr，vhost_http_port，vhost_https_port，dashboard_addr，dashboard_port 支持 bind_unix_domain_socket 参数
# bind_unix_domain_socket = true

# vhost_http_port 和 vhost_https_port 用于设置 http 和 https 的转发端口
vhost_http_port = ${VHOST_HTTP_PORT:-8080}
vhost_https_port = ${VHOST_HTTPS_PORT:-8443}

# auth_token is used to authenticate frpc and frps. If auth_token is not set, no verification is done during operation.
token = ${AUTH_TOKEN:-SUQAKTMb87}

# heartbeat_timeout is used to set the timeout for the heartbeat between frpc and frps. If the heartbeat is not received within the timeout, the proxy will be removed.
heartbeat_timeout = ${HEARTBEAT_TIMEOUT:-90}

# max_pool_count is used to set the maximum connection pool for each proxy. It can be adjusted according to actual needs.
max_pool_count = ${MAX_POOL_COUNT:-5}

# max_ports_per_client can limit the number of ports a client can use at most. When it is 0, there is no restriction.
max_ports_per_client = ${MAX_PORTS_PER_CLIENT:-0}

# TLS only support for frpc and frps. All proxy traffic is encrypted with TLS.
# tls_only = false
EOF

# 只有当 DASHBOARD_USER 和 DASHBOARD_PWD 都不为空时才启用 dashboard
if [ -n "${DASHBOARD_USER}" ] && [ -n "${DASHBOARD_PWD}" ]; then
  cat >> /etc/frp/frps.ini <<EOF

# 设置 dashboard 的账号和密码
dashboard_addr = 0.0.0.0
dashboard_port = ${DASHBOARD_PORT:-7500}
dashboard_user = ${DASHBOARD_USER}
dashboard_pwd = ${DASHBOARD_PWD}
EOF
fi

if [ -n "${ALLOW_PORTS}" ]; then
  cat >> /etc/frp/frps.ini <<EOF

allow_ports = ${ALLOW_PORTS}
EOF
fi

/usr/bin/frps -c /etc/frp/frps.ini
