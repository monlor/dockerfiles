#!/bin/sh

set -eu

CONFIG_FILE=/dashboard/data/config.yaml

if [ ! -f /dashboard/data/config.yaml ]; then
    cp -rf /dashboard/config.yaml ${CONFIG_FILE}
    # language
    sed -i "s/^language:.*$/language: \"zh-CN\"/" ${CONFIG_FILE}
    # brand
    sed -i "s/^  brand:.*$/  brand: \"Nezha Monitor\"/" ${CONFIG_FILE}
fi

sed -i "s/^debug:.*$/debug: ${DEBUG:-false}/" ${CONFIG_FILE}
sed -i "s/^httpport:.*$/httpport: ${HTTP_PORT:-80}/" ${CONFIG_FILE}
# grpc
sed -i "s/^grpcport:.*$/grpcport: ${GRPC_PORT:-5555}/" ${CONFIG_FILE}
# oauth2
sed -i "s/^  type:.*$/  type: \"${OAUTH_TYPE:-github}\"/" ${CONFIG_FILE}
sed -i "s/^  admin:.*$/  admin: \"${OAUTH_ADMIN}\"/" ${CONFIG_FILE}
sed -i "s/^  clientid:.*$/  clientid: \"${OAUTH_CLIENT_ID}\"/" ${CONFIG_FILE}
sed -i "s/^  clientsecret:.*$/  clientsecret: \"${OAUTH_CLIENT_SECRET}\"/" ${CONFIG_FILE}
sed -i "s/^  endpoint:.*$/  endpoint: \"${OAUTH_ENDPOINT:-}\"/" ${CONFIG_FILE}
# cookiename
sed -i "s/^  cookiename:.*$/  cookiename: \"${SITE_COOKIE_NAME:-nezha-dashboard}\"/" ${CONFIG_FILE}
# ddns https://nezha.wiki/guide/servers.html#%E5%8D%95%E9%85%8D%E7%BD%AE
# webhook, cloudflare, tencentcloud
sed -i '/^ddns:/,$d' ${CONFIG_FILE}
cat >> ${CONFIG_FILE} <<-EOF
ddns:
  enable: ${DDNS_ENABLED:-false}
  provider: ${DDNS_PROVIDER:-cloudflare}
  accessid: ${DDNS_ACCESS_ID:-}
  accesssecret: ${DDNS_ACCESS_SECRET:-}
  webhookmethod: ${DDNS_WEBHOOK_METHOD:-POST}
  webhookurl: ${DDNS_WEBHOOK_URL:-}
  webhookrequestbody: ${DDNS_WEBHOOK_REQUEST_BODY:-}
  webhookheaders: ${DDNS_WEBHOOK_HEADERS:-}
  maxretries: ${DDNS_MAX_RETRIES:-3}
EOF


if [ ! -d /dashboard/resource/template ]; then
  mkdir -p /dashboard/resource/template
fi

/entrypoint.sh