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
    "USDC": 0,
    "MATIC": 0
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

[ -n "${ETH_API_KEY}" ] && ETH_ENABLED=true
[ -n "${BSC_API_KEY}" ] && BSC_ENABLED=true
[ -n "${POLYGON_API_KEY}" ] && POLYGON_ENABLED=true

cat > /app/evmchains.json <<-EOF
{
  "EVMChains": [
    {
      "Enable": ${ETH_ENABLED:-false},
      "ChainName": "以太坊",
      "ChainNameEN": "ETH",
      "BaseCoin": "ETH",
      "Decimals": 18,
      "ScanHost": "https://etherscan.io",
      "ApiHost": "https://api.etherscan.io",
      "ApiKey": "${ETH_API_KEY}", // 此处申请 https://etherscan.io/myapikey
      "ERC20Name": "ERC20",
      "ERC20": [
        {
          "Name": "USDT",
          "ContractAddress": "0xdAC17F958D2ee523a2206206994597C13D831ec7"
        },
        {
          "Name": "USDC",
          "ContractAddress": "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"
        }
      ]
    },
    {
      "Enable": ${BSC_ENABLED:-false},
      "ChainName": "币安智能链",
      "ChainNameEN": "BSC",
      "BaseCoin": "BNB",
      "Decimals": 18,
      "ScanHost": "https://www.bscscan.com",
      "ApiHost": "https://api.bscscan.com",
      "ApiKey": "${BSC_API_KEY}", // 此处申请 https://bscscan.com/myapikey
      "ERC20Name": "BEP20",
      "ERC20": [
        {
          "Name": "USDT",
          "ContractAddress": "0x55d398326f99059ff775485246999027b3197955"
        },
        {
          "Name": "USDC",
          "ContractAddress": "0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d"
        }
      ]
    },
    {
      "Enable": ${POLYGON_ENABLED:-false},
      "ChainName": "Polygon",
      "ChainNameEN": "Polygon",
      "BaseCoin": "MATIC",
      "Decimals": 18,
      "ScanHost": "https://polygonscan.com",
      "ApiHost": "https://api.polygonscan.com",
      "ApiKey": "${POLYGON_API_KEY}", // 此处申请 https://polygonscan.com/myapikey
      "ERC20Name": "ERC20",
      "ERC20": [
        {
          "Name": "USDT",
          "ContractAddress": "0xc2132D05D31c914a87C6611C10748AEb04B58e8F"
        },
        {
          "Name": "USDC",
          "ContractAddress": "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174"
        }
      ]
    }
  ]
}
EOF

nohup socat TCP-LISTEN:5001,fork TCP:127.0.0.1:5000 &

cd /app && ./TokenPay