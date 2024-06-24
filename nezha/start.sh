#!/bin/sh

set -eu

CONFIG_FILE=/dashboard/data/config.yaml

if [ ! -f /dashboard/data/config.yaml ]; then
    cat > ${CONFIG_FILE} <<-EOF
AvgPingCount: 2
Cover: 0
DDNS:
  AccessID: 
  AccessSecret: 
  Enable: false
  MaxRetries: 3
  Profiles: null
  Provider: cloudflare
  WebhookHeaders: ""
  WebhookMethod: POST
  WebhookRequestBody: ""
  WebhookURL: ""
Debug: false
DisableSwitchTemplateInFrontend: false
EnableIPChangeNotification: false
EnablePlainIPInNotification: false
GRPCHost: 
GRPCPort: 5555
HTTPPort: 80
IPChangeNotificationTag: default
IgnoredIPNotification: ""
IgnoredIPNotificationServerIDs: {}
Language: zh-CN
Location: Asia/Shanghai
MaxTCPPingValue: 1000
Oauth2:
  Admin: 
  ClientID: 
  ClientSecret: 
  Endpoint: ""
  Type: github
ProxyGRPCPort: 0
Site:
  Brand: "Nezha Monitor"
  CookieName: nezha-dashboard
  CustomCode: ""
  DashboardTheme: default
  Theme: hotaru
  ViewPassword: ""
TLS: false
EOF
fi

sed -i "s/^Debug:.*$/Debug: ${DEBUG:-false}/" ${CONFIG_FILE}
sed -i "s/^HTTPPort:.*$/HTTPPort: ${HTTP_PORT:-80}/" ${CONFIG_FILE}
# grpc
sed -i "s/^GRPCPort:.*$/GRPCPort: ${GRPC_PORT:-5555}/" ${CONFIG_FILE}
# oauth2
sed -i "s/^  Type:.*$/  Type: \"${OAUTH_TYPE:-github}\"/" ${CONFIG_FILE}
sed -i "s/^  Admin:.*$/  Admin: \"${OAUTH_ADMIN}\"/" ${CONFIG_FILE}
sed -i "s/^  ClientID:.*$/  ClientID: \"${OAUTH_CLIENT_ID}\"/" ${CONFIG_FILE}
sed -i "s/^  ClientSecret:.*$/  ClientSecret: \"${OAUTH_CLIENT_SECRET}\"/" ${CONFIG_FILE}
sed -i "s/^  Endpoint:.*$/  Endpoint: \"${OAUTH_ENDPOINT:-}\"/" ${CONFIG_FILE}
# ddns https://nezha.wiki/guide/servers.html#%E5%8D%95%E9%85%8D%E7%BD%AE
# cloudflare, tencentcloud
if [ "${DDNS_ENABLED:-false}" = "true" ]; then
    sed -i "s/^  Enable:.*$/  Enable: ${DDNS_ENABLED}/" ${CONFIG_FILE}
    sed -i "s/^  Provider:.*$/  Provider: \"${DDNS_PROVIDER:-cloudflare}\"/" ${CONFIG_FILE}
    sed -i "s/^  AccessID:.*$/  AccessID: \"${DDNS_ACCESS_ID:-}\"/" ${CONFIG_FILE}
    sed -i "s/^  AccessSecret:.*$/  AccessSecret: \"${DDNS_ACCESS_SECRET:-}\"/" ${CONFIG_FILE}
fi

if [ ! -d /dashboard/resource/template ]; then
  mkdir -p /dashboard/resource/template
fi

/entrypoint.sh