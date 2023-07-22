#!/bin/bash

cat > /app/appsettings.json <<-EOF
{
  "Serilog": {
    "MinimumLevel": {
      "Default": "Information",
      "Override": {
        "Microsoft": "Warning",
        "Microsoft.Hosting.Lifetime": "Information"
      }
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DB": "Data Source=/data/TokenPay.db; Pooling=true;"
  },
  "TRON-PRO-API-KEY": "${TRON_PRO_API_KEY}", // 避免接口请求频繁被限制，此处申请 https://www.trongrid.io/dashboard/keys
  "BaseCurrency": "${BASE_CURRENCY:-CNY}", //默认货币，支持 CNY、USD、EUR、GBP、AUD、HKD、TWD、SGD
  "Rate": { //汇率 设置0将使用自动汇率
    "USDT": 0,
    "TRX": 0,
    "ETH": 0,
    "USDC": 0
  },
  "ExpireTime": 1800, //单位秒
  "UseDynamicAddress": false, //是否使用动态地址，设为false时，与EPUSDT表现类似；设为true时，为每个下单用户分配单独的收款地址
  "Address": { // UseDynamicAddress设为false时在此配置TRON收款地址，EVM可以替代所有ETH系列的收款地址，支持单独配置某条链的收款地址
    "TRON": [ "${TRON_ADDRESS}" ],
    "EVM": [ "${EVM_ADDRESS}" ]
  },
  "OnlyConfirmed": false, //默认仅查询已确认的数据，如果想要回调更快，可以设置为false
  "NotifyTimeOut": 3, //异步通知超时时间
  "ApiToken": "${API_TOKEN}", //异步通知密钥，请务必修改此密钥为随机字符串，脸滚键盘即可
  "WebSiteUrl": "${WEB_URL:-http://localhost}", //配置服务器外网域名
  "Telegram": {
    "AdminUserId": ${TG_USER_ID:-1}, // 你的账号ID，如不知道ID，可给https://t.me/EShopFakaBot 发送 /me 获取用户ID
    "BotToken": "${TG_BOT_TOKEN}" //从https://t.me/BotFather 创建机器人时，会给你BotToken
  }
}
EOF

nohup socat TCP-LISTEN:5001,fork TCP:127.0.0.1:5000 &

cd /app && ./TokenPay