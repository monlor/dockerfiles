#!/bin/bash

set -eu

dockerd-entrypoint.sh &

# Wait for docker to start
while ! docker info &>/dev/null; do
    sleep 1
done

# Start the main process

# Generate the config file
echo "开始生成配置文件..."

DATA_DIR="/etc/xiaoya"
MEDIA_DIR="/opt/media"
RESILIO_DIR="/opt/media/resilio"

if [ ! -d "${DATA_DIR}" ]; then
    mkdir -p ${DATA_DIR}
fi

if [ ${#ALIYUN_TOKEN} -ne 32 ]; then
    echo "长度不对,阿里云盘 Token是32位长"
    echo -e "启动停止，请参考指南配置文件\nhttps://alist.nn.ci/zh/guide/drivers/aliyundrive.html \n"
    exit
else	
    echo "添加阿里云盘 Token..."
    echo "${ALIYUN_TOKEN}" > ${DATA_DIR}/mytoken.txt
fi

if [[ ${#ALIYUN_OPEN_TOKEN} -le 334 ]]; then
    echo "长度不对,阿里云盘 Open Token是335位"
    echo -e "安装停止，请参考指南配置文件\nhttps://alist.nn.ci/zh/guide/drivers/aliyundrive_open.html \n"
    exit
else
    echo "添加阿里云盘 Open Token..."
    echo "${ALIYUN_OPEN_TOKEN}" > ${DATA_DIR}/myopentoken.txt
fi

if [ ${#ALIYUN_FOLDER_ID} -ne 40 ]; then
    echo "长度不对,阿里云盘 folder id是40位长"
    echo -e "安装停止，请转存以下目录到你的网盘，并获取该文件夹的folder_id\nhttps://www.aliyundrive.com/s/rP9gP3h9asE \n"
    exit
else
    echo "添加阿里云盘 folder_id..."
    echo "${ALIYUN_FOLDER_ID}" > ${DATA_DIR}/temp_transfer_folder_id.txt
fi

# Generate DDSRem config file
if [ ! -d "/etc/DDSRem" ]; then
    mkdir -p /etc/DDSRem
fi

echo "${DATA_DIR}" > /etc/DDSRem/xiaoya_alist_config_dir.txt 
echo "${MEDIA_DIR}" > /etc/DDSRem/xiaoya_alist_media_dir.txt
echo "${RESILIO_DIR}" > /etc/DDSRem/resilio_config_dir.txt

# Install xiaoya alist
echo "开始安装 Alist..."

if ! docker ps | grep "xiaoya "; then
    echo "开始安装 xiaoya..."
    xiaoya.sh install_alist
fi

if ! docker ps | grep xiaoyakeeper; then
    echo "开始安装 Keeper..."
    xiaoya.sh install_xiaoyahelper
fi

if [ "${EMBY_ENABLE:=false}" = "true" ]; then
    echo "已启用 Emby..."
    if [ ! -f "/opt/media/temp/all.mp4" ]; then
        echo "下载并解压元数据..."
        xiaoya.sh download_unzip_xiaoya_all_emby
    fi
    if ! docker ps | grep emby; then
        echo "开始安装 Emby..."
        xiaoya.sh install_emby
    fi
fi

if [ "${JELLYFIN_ENABLE:=false}" = "true" ]; then
    echo "已启用 Jellyfin..."
    if [ ! -f "/opt/media/temp/all_jf.mp4" ]; then
        echo "下载并解压元数据..."
        xiaoya.sh download_unzip_xiaoya_all_jellyfin
    fi
    if ! docker ps | grep jellyfin; then
        echo "开始安装 Jellyfin..."
        xiaoya.sh install_jellyfin
    fi
fi