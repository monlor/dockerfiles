#!/bin/bash

set -e

if [ -z "$(ls -A /var/www/html)" ]; then
    echo "安装acg-faka程序..."
    cp -rf /tmp/acg-faka-main/. /var/www/html
fi

apache2-foreground
