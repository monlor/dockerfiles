#!/bin/bash

# 设置环境变量
export MITMPROXY_USER=${MITMPROXY_USER:-""}
export MITMPROXY_PASS=${MITMPROXY_PASS:-""}

# 构建 mitmweb 命令
MITMWEB_CMD="mitmweb --web-host 0.0.0.0 --set console_eventlog_verbosity=${LOG_LEVEL:-error} --web-port 8081 --listen-port 8080 -s /mitmproxy.py $@"

# 如果设置了用户名和密码，添加代理认证
if [ -n "$MITMPROXY_USER" ] && [ -n "$MITMPROXY_PASS" ]; then
    MITMWEB_CMD="$MITMWEB_CMD --proxyauth $MITMPROXY_USER:$MITMPROXY_PASS"
fi

nginx -g 'daemon off;' &

# 执行 mitmweb 命令
exec $MITMWEB_CMD