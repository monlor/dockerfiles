#!/bin/bash

# 检查必要的环境变量
if [ -z "$WEBDAV_URL" ] || [ -z "$WEBDAV_USERNAME" ] || [ -z "$WEBDAV_PASSWORD" ] || [ -z "$BACKUP_DIRS" ] || [ -z "$BACKUP_INTERVAL" ]; then
    echo "错误: 缺少必要的环境变量"
    exit 1
fi

echo "开始备份任务..."
echo "备份目录: ${BACKUP_DIRS}"
echo "备份间隔: ${BACKUP_INTERVAL} 分钟"
echo "WebDAV URL: ${WEBDAV_URL}"
echo "WebDAV 用户名: ${WEBDAV_USERNAME}"
echo "WebDAV 路径: ${WEBDAV_PATH}"

echo "--------------------------------"

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
        echo "错误: 无法上传备份文件 ${BACKUP_FILE}. HTTP 状态码: ${HTTP_CODE}"
    fi
    
    # 清理临时文件
    rm -rf "${TEMP_DIR}"

    echo "--------------------------------"
    
    # 等待下一次备份
    echo "等待 ${BACKUP_INTERVAL} 分钟后再进行备份..."
    sleep $((BACKUP_INTERVAL * 60))

done