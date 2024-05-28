#!/bin/bash

set -eu

echo "开始生成配置文件..."

if [ ! -d "/data" ]; then
    mkdir /data
fi

# 生成配置，阿里云token
if [ ${#ALIYUN_TOKEN} -ne 32 ]; then
    echo "长度不对,阿里云盘 Token是32位长"
    echo -e "启动停止，请参考指南配置文件\nhttps://alist.nn.ci/zh/guide/drivers/aliyundrive.html \n"
    exit
else	
    echo "添加阿里云盘 Token..."
    echo "${ALIYUN_TOKEN}" > /data/mytoken.txt
fi

# 生成配置，阿里云open token
if [[ ${#ALIYUN_OPEN_TOKEN} -le 334 ]]; then
    echo "长度不对,阿里云盘 Open Token是335位"
    echo -e "安装停止，请参考指南配置文件\nhttps://alist.nn.ci/zh/guide/drivers/aliyundrive_open.html \n"
    exit
else
    echo "添加阿里云盘 Open Token..."
    echo "${ALIYUN_OPEN_TOKEN}" > /data/myopentoken.txt
fi

# 生成配置，阿里云转存目录folder_id
if [ ${#ALIYUN_FOLDER_ID} -ne 40 ]; then
    echo "长度不对,阿里云盘 folder id是40位长"
    echo -e "安装停止，请转存以下目录到你的网盘，并获取该文件夹的folder_id\nhttps://www.aliyundrive.com/s/rP9gP3h9asE \n"
    exit
else
    echo "添加阿里云盘 folder_id..."
    echo "${ALIYUN_FOLDER_ID}" > /data/temp_transfer_folder_id.txt
fi

if [ "${CRONTAB_ENABLE:=false}" = "true" ]; then
    echo "启动定时任务..."
    echo "0 3 * * * /updateall " | crontab -
    crond
fi

exec /entrypoint.sh /opt/alist/alist server --no-prefix