#!/bin/bash

set -e

if [ -d /tmp/epay ]; then
    echo "更新epay文件..."
    if [ -f /var/www/html/install/install.lock ]; then
        echo "检测到历史文件，恢复中..."
        cp -rf /var/www/html/install/install.lock /tmp/epay/install
        cp -rf /var/www/html/config.php /tmp/epay/config.php
    fi
    rsync -av --delete /var/www/html/ /tmp/epay/ &> /dev/null
fi

apache2-foreground