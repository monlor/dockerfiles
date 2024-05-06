#!/bin/sh

set -eu

cat > /usdt/.env <<-EOF
app_name=epusdt
#下面配置你的域名，收银台会需要
app_uri=${DOMAIN}
#是否开启debug，默认false
app_debug=${DEBUG:-false}
#http服务监听端口
http_listen=:8000

#静态资源文件目录
static_path=/static
#缓存路径
runtime_root_path=/runtime

#日志配置
log_save_path=/logs
log_max_size=32
log_max_age=7
max_backups=3

# mysql配置
mysql_host=${MYSQL_HOST}
mysql_port=${MYSQL_PORT:-3306}
mysql_user=${MYSQL_USER}
mysql_passwd=${MYSQL_PASSWD}
mysql_database=${MYSQL_DB}
mysql_table_prefix=
mysql_max_idle_conns=10
mysql_max_open_conns=100
mysql_max_life_time=6

# redis配置
redis_host=${REDIS_HOST}
redis_port=${REDIS_PORT:-6379}
redis_passwd=${REDIS_PASSWD:-}
redis_db=${REDIS_DB:-5}
redis_pool_size=5
redis_max_retries=3
redis_idle_timeout=1000

# 消息队列配置
queue_concurrency=${QUEUE_CONCURRENCY:-10}
queue_level_critical=6
queue_level_default=3
queue_level_low=1

#机器人Apitoken
tg_bot_token=${TG_BOT_TOKEN}
#telegram代理url(大陆地区服务器可使用一台国外服务器做反代tg的url)，如果运行的本来就是境外服务器，则无需填写
tg_proxy=${TG_PROXY:-}
#管理员userid
tg_manage=${TG_USER_ID}

#api接口认证token
api_auth_token=${API_TOKEN}

#订单过期时间(单位分钟)
order_expiration_time=${ORDER_EXPIRATION_TIME:-10}

#强制汇率(设置此参数后每笔交易将按照此汇率计算，例如:6.4)
forced_usdt_rate=
EOF

/usdt/epusdt http start