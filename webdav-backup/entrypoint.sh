#!/bin/bash

# 检查必要的环境变量
if [ -z "$WEBDAV_URL" ] || [ -z "$WEBDAV_USERNAME" ] || [ -z "$WEBDAV_PASSWORD" ] || [ -z "$BACKUP_DIRS" ] || [ -z "$BACKUP_INTERVAL" ]; then
    echo "错误: 缺少必要的环境变量"
    exit 1
fi

# 检查 Telegram 相关环境变量
if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
    TELEGRAM_ENABLED=true
    echo "Telegram 通知已启用"
else
    TELEGRAM_ENABLED=false
    echo "Telegram 通知未启用"
fi

# 检查加密相关环境变量
if [ -n "$ENCRYPTION_PASSWORD" ]; then
    ENCRYPTION_ENABLED=true
    echo "备份加密已启用"
else
    ENCRYPTION_ENABLED=false
    echo "备份加密未启用"
fi

# 添加发送 Telegram 消息的函数
send_telegram_message() {
    if [ "$TELEGRAM_ENABLED" = true ]; then
        response=$(curl -s -w "\n%{http_code}" -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -d chat_id="${TELEGRAM_CHAT_ID}" \
            -d text="$1" \
            -d parse_mode="HTML")
        
        body=$(echo "$response" | sed '$d')
        status_code=$(echo "$response" | tail -n1)
        
        if [ "$status_code" != "200" ]; then
            echo "Telegram 消息发送成功"
        else
            echo "Telegram 消息发送失败. 状态码: $status_code, 响应: $body"
        fi
    fi
}

echo "开始备份任务..."
echo "备份任务名称: ${BACKUP_TASK_NAME}"
echo "备份目录: ${BACKUP_DIRS}"
echo "备份间隔: ${BACKUP_INTERVAL} 分钟"
echo "WebDAV URL: ${WEBDAV_URL}"
echo "WebDAV 用户名: ${WEBDAV_USERNAME}"
echo "WebDAV 路径: ${WEBDAV_PATH}"

# 发送启动通知
startup_message="<b>WebDAV 备份任务已启动</b>%0A"
startup_message+="任务名称: ${BACKUP_TASK_NAME}%0A"
startup_message+="备份目录: ${BACKUP_DIRS}%0A"
startup_message+="备份间隔: ${BACKUP_INTERVAL} 分钟%0A"
startup_message+="WebDAV URL: ${WEBDAV_URL}%0A"
startup_message+="WebDAV 路径: ${WEBDAV_PATH}"

send_telegram_message "$startup_message"

# 验证 BACKUP_SPLIT_SIZE 格式
validate_split_size() {
    if [[ ! $BACKUP_SPLIT_SIZE =~ ^[0-9]+[bkmgtBKMGT]?$ ]]; then
        echo "错误: BACKUP_SPLIT_SIZE 格式无效。请使用数字后跟可选的单位后缀 (b, k, m, g, t)。例如: 100M, 1G, 500K"
        exit 1
    fi
}

# 设置文件拆分大小，如果不设置则不拆分
BACKUP_SPLIT_SIZE=${BACKUP_SPLIT_SIZE:-}

if [ -n "$BACKUP_SPLIT_SIZE" ]; then
    validate_split_size
    echo "文件拆分大小: ${BACKUP_SPLIT_SIZE}"
else
    echo "文件不拆分"
fi

# 修改加密文件的函数
encrypt_file() {
    local input_file="$1"
    local output_file="$1"  # 保持输出文件名与输入文件名相同

    if [ "$ENCRYPTION_ENABLED" = true ]; then
        echo "正在加密文件: ${input_file}"
        openssl enc -aes-256-cbc -salt -in "$input_file" -out "${input_file}.tmp" -k "$ENCRYPTION_PASSWORD"
        mv "${input_file}.tmp" "$output_file"
    fi
}

# 修改上传文件的函数
upload_file() {
    local file="$1"
    local remote_path="$2"

    if [ "$ENCRYPTION_ENABLED" = true ]; then
        encrypt_file "$file"
    fi

    HTTP_CODE=$(curl -#L -u "${WEBDAV_USERNAME}:${WEBDAV_PASSWORD}" \
            -T "$file" \
            "${WEBDAV_URL}${WEBDAV_PATH}/${remote_path}" \
            --connect-timeout 30 \
            --max-time 3600 \
            -w "%{http_code}" \
            -o /dev/null)

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        echo "上传完成: ${remote_path}"
    else
        error_message="错误: 无法上传文件 ${remote_path}. HTTP 状态码: ${HTTP_CODE}"
        echo "$error_message"
        send_telegram_message "<b>WebDAV 备份失败</b>%0A任务名称: ${BACKUP_TASK_NAME}%0A${error_message}"
    fi
}

# 无限循环执行备份
while true; do
    # 获取当前日期
    CURRENT_DATE=$(date +"%Y/%m/%d")
    
    # 创建备份文件名
    BACKUP_FILE="backup_$(date +"%Y%m%d_%H%M%S").tar.gz"
    
    # 创建临时目录
    TEMP_DIR=$(mktemp -d)

    # 打印时间
    echo "---------- $CURRENT_DATE ----------"
        
    echo "压缩备份目录..."
    
    # 创建备份文件列表
    BACKUP_LIST_FILE="${TEMP_DIR}/${BACKUP_FILE}.txt"
    
    if [ -n "$BACKUP_SPLIT_SIZE" ]; then
        tar -czf - --absolute-names ${BACKUP_DIRS} | split -b ${BACKUP_SPLIT_SIZE} - "${TEMP_DIR}/${BACKUP_FILE}.part-"
        for part in "${TEMP_DIR}/${BACKUP_FILE}.part-"*; do
            echo "$(basename "$part")" >> "$BACKUP_LIST_FILE"
        done
    else
        tar -czf "${TEMP_DIR}/${BACKUP_FILE}" --absolute-names ${BACKUP_DIRS}
    fi
    
    echo "压缩完成，开始上传..."
    
    # 上传文件（可能是拆分后的多个文件）
    if [ -n "$BACKUP_SPLIT_SIZE" ]; then
        for part in "${TEMP_DIR}/${BACKUP_FILE}.part-"*; do
            upload_file "$part" "${CURRENT_DATE}/$(basename "$part")"
        done
        # 上传备份文件列表
        upload_file "$BACKUP_LIST_FILE" "${CURRENT_DATE}/${BACKUP_FILE}.txt"
    else
        upload_file "${TEMP_DIR}/${BACKUP_FILE}" "${CURRENT_DATE}/${BACKUP_FILE}"
    fi
    
    # 清理临时文件
    rm -rf "${TEMP_DIR}"

    echo "--------------------------------"
    
    # 等待下一次备份
    echo "等待 ${BACKUP_INTERVAL} 分钟后再进行备份..."
    sleep $((BACKUP_INTERVAL * 60))
done
