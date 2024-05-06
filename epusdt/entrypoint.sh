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
mysql_port=${MYSQL_PORT:=3306}
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


# 自动创建表
exec_sql() {
    mysql -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" -u "${MYSQL_USER}" -p"${MYSQL_PASSWD}" -e "USE ${MYSQL_DB}; $1"
}

table_exists() {
    table_name="$1"

    exec_sql "SHOW TABLES LIKE '$table_name';" | grep "$table_name" >/dev/null
}



# 创建orders表
if ! table_exists "orders"; then
    exec_sql "
        CREATE TABLE orders (
            id                   INT AUTO_INCREMENT PRIMARY KEY,
            trade_id             VARCHAR(32) NOT NULL COMMENT 'epusdt订单号',
            order_id             VARCHAR(32) NOT NULL COMMENT '客户交易id',
            block_transaction_id VARCHAR(128) NULL COMMENT '区块唯一编号',
            actual_amount        DECIMAL(19, 4) NOT NULL COMMENT '订单实际需要支付的金额，保留4位小数',
            amount               DECIMAL(19, 4) NOT NULL COMMENT '订单金额，保留4位小数',
            token                VARCHAR(50) NOT NULL COMMENT '所属钱包地址',
            status               INT DEFAULT 1 NOT NULL COMMENT '1：等待支付，2：支付成功，3：已过期',
            notify_url           VARCHAR(128) NOT NULL COMMENT '异步回调地址',
            redirect_url         VARCHAR(128) NULL COMMENT '同步回调地址',
            callback_num         INT DEFAULT 0 NULL COMMENT '回调次数',
            callback_confirm     INT DEFAULT 2 NULL COMMENT '回调是否已确认？ 1是 2否',
            created_at           TIMESTAMP NULL,
            updated_at           TIMESTAMP NULL,
            deleted_at           TIMESTAMP NULL,
            CONSTRAINT orders_order_id_uindex UNIQUE (order_id),
            CONSTRAINT orders_trade_id_uindex UNIQUE (trade_id)
        );"

    echo "Table 'orders' created."
else
    echo "Table 'orders' already exists."
fi

# 创建wallet_address表
if ! table_exists "wallet_address"; then
    exec_sql "
        CREATE TABLE wallet_address (
            id         INT AUTO_INCREMENT PRIMARY KEY,
            token      VARCHAR(50) NOT NULL COMMENT '钱包token',
            status     INT DEFAULT 1 NOT NULL COMMENT '1:启用 2:禁用',
            created_at TIMESTAMP NULL,
            updated_at TIMESTAMP NULL,
            deleted_at TIMESTAMP NULL
        ) COMMENT '钱包表';"

    echo "Table 'wallet_address' created."
else
    echo "Table 'wallet_address' already exists."
fi

/usdt/epusdt http start