#!/bin/sh

set -eu

cat > /dashboard/data/config.yaml <<-EOF
debug: ${DEBUG:-false}
httpport: ${HTTP_PORT:-80}
language: ${LANGUAGE:-zh-CN}
grpcport: ${GRPC_PORT:-5555}
oauth2:
  type: "${OAUTH_TYPE:-github}" #Oauth2 登录接入类型，github/gitlab/jihulab/gitee/gitea
  admin: "${OAUTH_ADMIN}" #管理员列表，半角逗号隔开
  clientid: "${OAUTH_CLIENT_ID}" # 在 https://github.com/settings/developers 创建，无需审核 Callback 填 http(s)://域名或IP/oauth2/callback
  clientsecret: "${OAUTH_CLIENT_SECRET}"
  endpoint: "${OAUTH_ENDPOINT:-}" # 如gitea自建需要设置
site:
  brand: "${SITE_BRAND:-Nezha}"
  cookiename: "${SITE_COOKIE_NAME:-nezha-dashboard}" #浏览器 Cookie 字段名，可不改
  theme: "${SITE_THEME:-default}" 
ddns:
  enable: false
  provider: "webhook" # 如需使用多配置功能，请把此项留空
  accessid: ""
  accesssecret: ""
  webhookmethod: ""
  webhookurl: ""
  webhookrequestbody: ""
  webhookheaders: ""
  maxretries: 3
  profiles:
    example:
      provider: ""
      accessid: ""
      accesssecret: ""
      webhookmethod: ""
      webhookurl: ""
      webhookrequestbody: ""
      webhookheaders: ""    
EOF

if [ ! -d /dashboard/resource/template ]; then
  mkdir -p /dashboard/resource/template
fi

/entrypoint.sh