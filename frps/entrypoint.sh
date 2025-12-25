#!/bin/sh

if [ ! -d /etc/frp ]; then
  mkdir -p /etc/frp
fi

cat > /etc/frp/frps.toml <<EOF
# frps.toml - Server configuration for frp v0.65.0+
# Configuration format migrated from INI to TOML

bindAddr = "${BIND_ADDR:-0.0.0.0}"
bindPort = ${BIND_PORT:-7000}

# vhostHTTPPort and vhostHTTPSPort are used to forward HTTP and HTTPS traffic
vhostHTTPPort = ${VHOST_HTTP_PORT:-8080}
vhostHTTPSPort = ${VHOST_HTTPS_PORT:-8443}

# Authentication
auth.method = "token"
auth.token = "${AUTH_TOKEN:-SUQAKTMb87}"

# Transport settings
transport.heartbeatTimeout = ${HEARTBEAT_TIMEOUT:-90}
transport.maxPoolCount = ${MAX_POOL_COUNT:-5}

# maxPortsPerClient limits the number of ports a client can use at most
# When set to 0, there is no restriction
maxPortsPerClient = ${MAX_PORTS_PER_CLIENT:-0}
EOF

# Only enable webServer (dashboard) when both DASHBOARD_USER and DASHBOARD_PWD are set
if [ -n "${DASHBOARD_USER}" ] && [ -n "${DASHBOARD_PWD}" ]; then
  cat >> /etc/frp/frps.toml <<EOF

# WebServer (Dashboard) configuration
webServer.addr = "0.0.0.0"
webServer.port = ${DASHBOARD_PORT:-7500}
webServer.user = "${DASHBOARD_USER}"
webServer.password = "${DASHBOARD_PWD}"
EOF
fi

if [ -n "${ALLOW_PORTS}" ]; then
  cat >> /etc/frp/frps.toml <<EOF

# allowPorts specifies the ports that are allowed to be used
# Format: "2000-3000,3001,3003,4000-50000"
allowPorts = [
EOF

  # Parse ALLOW_PORTS and convert to TOML format
  echo "${ALLOW_PORTS}" | tr ',' '\n' | while IFS= read -r port_range; do
    if echo "$port_range" | grep -q '-'; then
      # Port range: "2000-3000" -> { start = 2000, end = 3000 }
      start=$(echo "$port_range" | cut -d'-' -f1)
      end=$(echo "$port_range" | cut -d'-' -f2)
      echo "  { start = $start, end = $end }," >> /etc/frp/frps.toml
    else
      # Single port: "3001" -> { single = 3001 }
      echo "  { single = $port_range }," >> /etc/frp/frps.toml
    fi
  done

  cat >> /etc/frp/frps.toml <<EOF
]
EOF
fi

/usr/bin/frps -c /etc/frp/frps.toml
