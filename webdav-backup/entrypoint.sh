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
    
    # 使用 pv 显示压缩进度
    if command -v pv &> /dev/null; then
        tar -cf - --absolute-names ${BACKUP_DIRS} | pv -s $(du -sb ${BACKUP_DIRS} | awk '{sum+=$1} END {print sum}') | gzip > "${TEMP_DIR}/${BACKUP_FILE}"
    else
        echo "警告: pv 未安装，将不显示进度"
        tar -czf "${TEMP_DIR}/${BACKUP_FILE}" --absolute-names ${BACKUP_DIRS}
    fi
    
    echo "压缩完成，开始上传..."
    
    # 直接上传到WebDAV服务器的年月日文件夹中
    HTTP_CODE=$(curl -u "${WEBDAV_USERNAME}:${WEBDAV_PASSWORD}" \
            -T "${TEMP_DIR}/${BACKUP_FILE}" \
            "${WEBDAV_URL}${WEBDAV_PATH}/${CURRENT_DATE}/${BACKUP_FILE}" \
            --connect-timeout 30 \
            --max-time 3600 \
            --progress-bar \
            -w "%{http_code}" \
            -o /dev/null)

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        echo "备份完成: ${CURRENT_DATE}/${BACKUP_FILE}"
    else
        error_message="错误: 无法上传备份文件 ${BACKUP_FILE}. HTTP 状态码: ${HTTP_CODE}"
        echo "$error_message"
        send_telegram_message "<b>WebDAV 备份失败</b>%0A任务名称: ${BACKUP_TASK_NAME}%0A${error_message}"
    fi
    
    # 清理临时文件
    rm -rf "${TEMP_DIR}"

    echo "--------------------------------"
    
    # 等待下一次备份
    echo "等待 ${BACKUP_INTERVAL} 分钟后再进行备份..."
    sleep $((BACKUP_INTERVAL * 60))

done
