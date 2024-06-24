FROM ghcr.io/naiba/nezha-dashboard:v0.17.3

ARG TARGETARCH

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

ENV TZ=Asia/Shanghai
ENV NEZHA_VERSION=v0.17.3

EXPOSE 80 5555

VOLUME /dashboard/data

WORKDIR /dashboard

COPY --chmod=755 ./start.sh /start.sh

ENTRYPOINT ["/start.sh"]