FROM tindy2013/subconverter:v0.8.1

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.2.1

WORKDIR /base
RUN apk add tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata

COPY pref.yml /base

COPY all_base.tpl /base/base

EXPOSE 25500


