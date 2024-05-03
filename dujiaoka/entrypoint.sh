#!/bin/bash

export INSTALL=false

sed -i "s/^DB_HOST=.*/DB_HOST=${DB_HOST}/g" /dujiaoka/.env
sed -i "s/^DB_PORT=.*/DB_PORT=${DB_PORT:-3306}/g" /dujiaoka/.env
sed -i "s/^DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE}/g" /dujiaoka/.env
sed -i "s/^DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME}/g" /dujiaoka/.env
sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/g" /dujiaoka/.env

sed -i "s/^REDIS_HOST=.*/REDIS_HOST=${REDIS_HOST}/g" /dujiaoka/.env
sed -i "s/^REDIS_PASSWORD=.*/REDIS_PASSWORD=${REDIS_PASSWORD}/g" /dujiaoka/.env
sed -i "s/^REDIS_PORT=.*/REDIS_PORT=${REDIS_PORT:-6379}/g" /dujiaoka/.env

sed -i "s/^CACHE_DRIVER=.*/CACHE_DRIVER=${CACHE_DRIVER:-redis}/g" /dujiaoka/.env

if [ ! -f /dujiaoka/.install.lock ]; then
    echo "启用初始化安装模式..."
    export INSTALL=true
    touch /dujiaoka/.install.lock
fi

/opt/start.sh