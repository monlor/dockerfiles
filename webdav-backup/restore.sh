#!/bin/bash

set -e

# 使用环境变量设置 WebDAV 相关信息
WEBDAV_URL="${WEBDAV_URL}"
WEBDAV_USERNAME="${WEBDAV_USERNAME}"
WEBDAV_PASSWORD="${WEBDAV_PASSWORD}"
WEBDAV_PATH="${WEBDAV_PATH:-}"
BACKUP_DIRS="${BACKUP_DIRS}"

# 临时目录用于下载备份文件
TEMP_DIR=$(mktemp -d)

# 检查加密密码
if [ -n "$ENCRYPTION_PASSWORD" ]; then
    ENCRYPTION_ENABLED=true
    echo "备份解密已启用"
else
    ENCRYPTION_ENABLED=false
    echo "备份解密未启用"
fi

# 函数：从用户输入获取备份文件名
get_backup_filename() {
    read -p "请输入要恢复的备份文件名（格式：backup_YYYYMMDD_HHMMSS.tar.gz 或 backup_YYYYMMDD_HHMMSS.tar.gz.txt）: " BACKUP_FILE
    if [[ ! $BACKUP_FILE =~ ^backup_[0-9]{8}_[0-9]{6}\.tar\.gz(\.txt)?$ ]]; then
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

# 函数：从 WebDAV 下载并解密备份文件
download_and_decrypt_backup() {
    local backup_path="$1"
    local output_file="$2"
    echo "正在从 WebDAV 下载文件: $backup_path"
    HTTP_CODE=$(curl -#L -w "%{http_code}" -o "$output_file" \
                    -u "${WEBDAV_USERNAME}:${WEBDAV_PASSWORD}" \
                    "${backup_path}")

    if [ "$HTTP_CODE" = "200" ]; then
        echo "文件下载成功。"
        if [ "$ENCRYPTION_ENABLED" = true ]; then
            echo "正在解密文件..."
            openssl enc -d -aes-256-cbc -in "$output_file" -out "${output_file}.tmp" -k "$ENCRYPTION_PASSWORD"
            mv "${output_file}.tmp" "$output_file"
        fi
    else
        echo "错误：文件下载失败。HTTP 状态码: ${HTTP_CODE}"
        return 1
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
    if [[ ! $BACKUP_FILE =~ ^backup_[0-9]{8}_[0-9]{6}\.tar\.gz(\.txt)?$ ]]; then
        echo "错误：无效的文件名格式。"
        exit 1
    fi
fi

construct_backup_path "$BACKUP_FILE"

if [[ $BACKUP_FILE == *.txt ]]; then
    # 下载备份列表文件
    BACKUP_LIST_FILE="${TEMP_DIR}/${BACKUP_FILE}"
    if ! download_and_decrypt_backup "$BACKUP_PATH" "$BACKUP_LIST_FILE"; then
        echo "错误：无法下载备份列表文件。"
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # 读取备份列表并下载文件
    while IFS= read -r file_name; do
        file_url="${BACKUP_PATH%/*}/${file_name}"
        output_file="${TEMP_DIR}/${file_name}"
        
        if ! download_and_decrypt_backup "$file_url" "$output_file"; then
            echo "错误：无法下载文件 $file_name"
            rm -rf "$TEMP_DIR"
            exit 1
        fi
    done < "$BACKUP_LIST_FILE"

    # 如果有多个文件，先合并
    if ls "${TEMP_DIR}/${BACKUP_FILE%.txt}.part-"* 1> /dev/null 2>&1; then
        echo "正在合并拆分的备份文件..."
        cat "${TEMP_DIR}/${BACKUP_FILE%.txt}.part-"* > "${TEMP_DIR}/${BACKUP_FILE%.txt}"
    fi

    BACKUP_FILE="${BACKUP_FILE%.txt}"
else
    # 直接下载单个备份文件
    if ! download_and_decrypt_backup "$BACKUP_PATH" "${TEMP_DIR}/${BACKUP_FILE}"; then
        echo "错误：无法下载备份文件。"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
fi

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
