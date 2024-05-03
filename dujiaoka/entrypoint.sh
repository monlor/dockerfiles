#!/bin/bash

set -e

export INSTALL=false

if [ ! -f /dujiaoka/storage/.env ]; then
    cp -a /dujiaoka/.env /dujiaoka/storage/.env
fi

sed -i "s/^DB_HOST=.*/DB_HOST=${DB_HOST}/g" /dujiaoka/storage/.env
sed -i "s/^DB_PORT=.*/DB_PORT=${DB_PORT:-3306}/g" /dujiaoka/storage/.env
sed -i "s/^DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE}/g" /dujiaoka/storage/.env
sed -i "s/^DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME}/g" /dujiaoka/storage/.env
sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/g" /dujiaoka/storage/.env

sed -i "s/^REDIS_HOST=.*/REDIS_HOST=${REDIS_HOST}/g" /dujiaoka/storage/.env
sed -i "s/^REDIS_PASSWORD=.*/REDIS_PASSWORD=${REDIS_PASSWORD}/g" /dujiaoka/storage/.env
sed -i "s/^REDIS_PORT=.*/REDIS_PORT=${REDIS_PORT:-6379}/g" /dujiaoka/storage/.env

sed -i "s/^CACHE_DRIVER=.*/CACHE_DRIVER=${CACHE_DRIVER:-redis}/g" /dujiaoka/storage/.env

if [ ! -f /dujiaoka/storage/.install.lock ]; then
    echo "启用初始化安装模式..."
    export INSTALL=true
    touch /dujiaoka/storage/.install.lock
fi

ln -sf /dujiaoka/storage/.env /dujiaoka/.env

echo "如果安装失败，请执行以下命令重新安装：rm /dujiaoka/storage/.install.lock"

/start.sh