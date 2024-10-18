FROM ghcr.io/fatedier/frpc:v0.61.0

LABEL MAINTAINER me@monlor.com
LABEL VERSION v0.61.0

RUN apk add --no-cache dumb-init

# 复制入口脚本
COPY --chmod=755 entrypoint.sh /entrypoint.sh

# 设置入口点
ENTRYPOINT [ "dumb-init", "--", "/entrypoint.sh" ]

