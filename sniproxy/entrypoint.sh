#!/bin/sh

set -eu

echo "生成 sniproxy 配置文件..."
cat > /etc/sniproxy.conf << EOF
user daemon
pidfile /var/tmp/sniproxy.pid

error_log {
    syslog daemon
    priority ${LOG_LEVEL:-notice}
}

access_log {
    filename /dev/stdout
}

resolver {
    nameserver 8.8.8.8
    nameserver 8.8.4.4 # local dns should be better
    mode ipv4_only
}

listener 0.0.0.0:80 {
    proto http
    reuseport yes
    table http_hosts
}

listener 0.0.0.0:443 {
    proto tls
    reuseport yes
    table https_hosts
}

table http_hosts {
    .* *:80
}

table https_hosts {
    .* *:443
}
EOF

echo "启动 sniproxy ..."
/usr/sbin/sniproxy -f