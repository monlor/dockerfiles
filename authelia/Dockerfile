# 使用官方的 Authelia 基础镜像
FROM authelia/authelia:latest

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

# 创建配置目录
RUN mkdir -p /config /logs

# 复制启动脚本到容器中
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 设置工作目录
WORKDIR /config

# 运行启动脚本
ENTRYPOINT ["/entrypoint.sh"]