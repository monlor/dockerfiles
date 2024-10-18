FROM alpine:latest

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.1.1

# 安装必要的工具
RUN apk add --no-cache bash curl tar gzip openssl && mkdir -p /data

# 复制脚本到容器
COPY --chmod=755 *.sh /

# 设置环境变量
ENV BACKUP_INTERVAL="60"
ENV BACKUP_DIRS="/data"
ENV BACKUP_TASK_NAME="默认备份任务"

# 运行脚本
CMD ["/entrypoint.sh"]
