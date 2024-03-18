#!/bin/bash

set -e

# 如果文件数量小于2，则安装，可能存在lost+found这个文件
if [ "$(ls -A /var/www/html | wc -l)" -lt 2 ]; then
    echo "安装acg-faka程序..."
    cp -rf /tmp/acg-faka-main/. /var/www/html
fi

apache2-foreground
