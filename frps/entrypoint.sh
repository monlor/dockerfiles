#!/bin/sh

if [ ! -d /etc/frp ]; then
  mkdir -p /etc/frp
fi

cat > /etc/frp/frps.ini <<EOF
[common]
bind_port = 7000

# 只有 bind_addr，vhost_http_port，vhost_https_port，dashboard_addr，dashboard_port 支持 bind_unix_domain_socket 参数
# bind_unix_domain_socket = true

# vhost_http_port 和 vhost_https_port 用于设置 http 和 https 的转发端口
vhost_http_port = ${HTTP_PORT:-8080}
vhost_https_port = ${HTTPS_PORT:-8443}

# 设置 dashboard 的账号和密码
dashboard_addr = 0.0.0.0
dashboard_port = 7500
dashboard_user = ${DASHBOARD_USER:-admin}
dashboard_pwd = ${DASHBOARD_PWD:-7RFPyAXYxc}

# auth_token is used to authenticate frpc and frps. If auth_token is not set, no verification is done during operation.
auth_token = ${AUTH_TOKEN:-SUQAKTMb87}

# heartbeat_timeout is used to set the timeout for the heartbeat between frpc and frps. If the heartbeat is not received within the timeout, the proxy will be removed.
# heartbeat_timeout = 90

# max_pool_count is used to set the maximum connection pool for each proxy. It can be adjusted according to actual needs.
# max_pool_count = 50

# max_ports_per_client can limit the number of ports a client can use at most. When it is 0, there is no restriction.
# max_ports_per_client = 0

# TLS only support for frpc and frps. All proxy traffic is encrypted with TLS. 
# tls_only = false
EOF

if [ -n "${ALLOW_PORTS}" ]; then
  cat >> /etc/frp/frps.ini <<EOF
allow_ports = ${ALLOW_PORTS}
EOF
fi

/usr/bin/frps -c /etc/frp/frps.ini