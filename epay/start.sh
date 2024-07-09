#!/bin/bash

set -e

# 先更新安装文件
cp -rf /var/www/html/install/ /data/install/

# 软连接安装文件，保存install.lock
ln -sf /data/install /var/www/html/install

cat > /var/www/html/config.php <<-EOF
<?php
    /*数据库配置*/
    \$dbconfig=array(
        'host' => '${DB_HOST}', //数据库服务器
        'port' => ${DB_PORT}, //数据库端口
        'user' => '${DB_USERNAME}', //数据库用户名
        'pwd' => '${DB_PASSWORD}', //数据库密码
        'dbname' => '${DB_DATABASE}', //数据库名
        'dbqz' => 'pay' //数据表前缀
    );
EOF

apache2-foreground
