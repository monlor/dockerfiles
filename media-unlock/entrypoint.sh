#!/bin/sh

set -eu

CONFIG_FILE=/etc/dnsmasq.conf

cat > ${CONFIG_FILE} <<EOF
domain-needed
bogus-priv
no-resolv
no-poll
all-servers
server=8.8.8.8
server=1.1.1.1
cache-size=2048
local-ttl=60
interface=*
EOF

if [ -n "${MEDIA_DOMAIN_URL:=}" ]; then
  echo "Downloading domain list from ${MEDIA_DOMAIN_URL}"
  curl -L "${MEDIA_DOMAIN_URL}" | grep -v '^#' | grep -v '^$' | while read -r domain; do
    echo "address=/$domain/${SNI_IP}" >> "${CONFIG_FILE}"
  done
else
  echo "Using domain list from /tmp/media.txt"
  grep -h -v '^#' /tmp/media.txt | grep -v '^$' | while read -r domain; do
    echo "address=/$domain/${SNI_IP}" >> "${CONFIG_FILE}"
  done
fi

dnsmasq -d