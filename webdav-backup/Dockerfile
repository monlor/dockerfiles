FROM alpine:latest

# 安装必要的工具
RUN apk add --no-cache bash curl tar pv

# 复制脚本到容器
COPY entrypoint.sh /entrypoint.sh

# 设置执行权限
RUN chmod +x /entrypoint.sh

# 设置环境变量
ENV WEBDAV_URL=""
ENV WEBDAV_USERNAME=""
ENV WEBDAV_PASSWORD=""
ENV WEBDAV_PATH=""
ENV BACKUP_DIRS=""
ENV BACKUP_INTERVAL="60"

# 运行脚本
CMD ["/entrypoint.sh"]
