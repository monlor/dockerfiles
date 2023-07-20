#!/bin/bash

if [ -d /tmp/epay ]; then
    echo "更新epay文件..."
    if [ -f /var/www/html/install/install.lock ]; then
        echo "检测到历史文件，恢复中..."
        cp -rf /var/www/html/install/install.lock /tmp/epay/install
        cp -rf /var/www/html/config.php /tmp/epay/config.php
    fi
    rm -rf /var/www/html/{*,.*} &> /dev/null
    mv /tmp/epay/{*,.*} /var/www/html &> /dev/null
    chmod 777 -R /var/www/html
fi


apache2-foreground