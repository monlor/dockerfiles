#!/bin/sh

if [ ! -d /data ]; then
  mkdir -p /data
fi

if [ ! -f /data/.env ]; then
  echo "初始化文件..."
  mkdir -p /data/database /data/assets/linkstack/images /data/assets /data/config
  cp -R /htdocs/.env /data
  cp -R /htdocs/database/database.sqlite /data/database
  cp -R /htdocs/assets/linkstack/images /data/assets/linkstack
  cp -R /htdocs/themes /data
  cp -R /htdocs/assets/img /data/assets
  cp -R /tmp/advanced-config.php /data/config/advanced-config.php
  chown apache:apache -R /data
fi  

echo "添加软链接..."
rm -rf /htdocs/.env /htdocs/database/database.sqlite /htdocs/assets/linkstack/images /htdocs/themes /htdocs/assets/img /htdocs/config/advanced-config.php
ln -sf /data/.env /htdocs/.env
ln -sf /data/database/database.sqlite /htdocs/database/database.sqlite
ln -sf /data/assets/linkstack/images /htdocs/assets/linkstack/images
ln -sf /data/themes /htdocs/themes
ln -sf /data/assets/img /htdocs/assets/img
ln -sf /data/config/advanced-config.php /htdocs/config/advanced-config.php
chown apache:apache -R /htdocs/.env /htdocs/database /htdocs/assets/linkstack/images /htdocs/themes /htdocs/assets/img /htdocs/config/advanced-config.php

/usr/local/bin/docker-entrypoint.sh