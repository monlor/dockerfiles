#!/bin/bash

set -e

# 使用环境变量设置 WebDAV 相关信息
WEBDAV_URL="${WEBDAV_URL}"
WEBDAV_USERNAME="${WEBDAV_USERNAME}"
WEBDAV_PASSWORD="${WEBDAV_PASSWORD}"
WEBDAV_PATH="${WEBDAV_PATH:-/backup}"
BACKUP_DIRS="${BACKUP_DIRS}"

# 临时目录用于下载备份文件
TEMP_DIR=$(mktemp -d)

# 函数：从用户输入获取备份文件名
get_backup_filename() {
    read -p "请输入要恢复的备份文件名（格式：backup_YYYYMMDD_HHMMSS.tar.gz）: " BACKUP_FILE
    if [[ ! $BACKUP_FILE =~ ^backup_[0-9]{8}_[0-9]{6}\.tar\.gz$ ]]; then
        echo "错误：无效的文件名格式。"
        exit 1
    fi
}

# 函数：从备份文件名解析日期并构造完整路径
construct_backup_path() {
    local filename="$1"
    local date_part=$(echo $filename | sed -E 's/^backup_([0-9]{8})_.*/\1/')
    local year=${date_part:0:4}
    local month=${date_part:4:2}
    local day=${date_part:6:2}
    BACKUP_PATH="${WEBDAV_URL}${WEBDAV_PATH}/${year}/${month}/${day}/${filename}"
}

# 函数：从 WebDAV 下载备份文件
download_backup() {
    local backup_path="$1"
    echo "正在从 WebDAV 下载备份文件..."
    HTTP_CODE=$(curl -#L -w "%{http_code}" -o "${TEMP_DIR}/${BACKUP_FILE}" \
                    -u "${WEBDAV_USERNAME}:${WEBDAV_PASSWORD}" \
                    "${backup_path}")

    if [ "$HTTP_CODE" = "200" ]; then
        echo "备份文件下载成功。"
    else
        echo "错误：备份文件下载失败。HTTP 状态码: ${HTTP_CODE}"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
}

# 函数：删除原有文件
remove_existing_files() {
    echo "正在删除原有文件..."
    IFS=' ' read -ra DIRS <<< "$BACKUP_DIRS"
    for dir in "${DIRS[@]}"; do
        if [ -d "$dir" ]; then
            find "$dir" -mindepth 1 -delete
            echo "已清空目录: $dir"
        else
            echo "警告: 目录不存在: $dir"
        fi
    done
}

# 主程序开始
if [ -z "$1" ]; then
    get_backup_filename
else
    BACKUP_FILE="$1"
    if [[ ! $BACKUP_FILE =~ ^backup_[0-9]{8}_[0-9]{6}\.tar\.gz$ ]]; then
        echo "错误：无效的文件名格式。"
        exit 1
    fi
fi

construct_backup_path "$BACKUP_FILE"
download_backup "$BACKUP_PATH"

# 警告用户
echo "警告：此操作将删除以下目录中的所有现有数据，并用备份数据替换："
echo "$BACKUP_DIRS"
read -p "是否继续？(y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "操作已取消。"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 删除原有文件
remove_existing_files

# 开始恢复
echo "开始恢复数据..."
tar -xzf "${TEMP_DIR}/${BACKUP_FILE}" -C / --absolute-names

if [ $? -eq 0 ]; then
    echo "数据恢复成功完成。"
else
    echo "错误：数据恢复失败。"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 清理临时文件
rm -rf "$TEMP_DIR"
