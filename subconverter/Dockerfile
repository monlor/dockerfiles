FROM tindy2013/subconverter:latest

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.2.3

WORKDIR /base
RUN apk add tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata

COPY pref.yml /base

COPY all_base.tpl /base/base

EXPOSE 25500


