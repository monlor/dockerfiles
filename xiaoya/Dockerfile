FROM docker:dind

LABEL MAINTAINER me@monlor.com
LABEL VERSION 2.0.2

EXPOSE 5678 2345 2346

VOLUME /etc/xiaoya /opt/media

RUN apk add --no-cache curl bash tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata && \
    rm -rf /var/cache/apk/*

ADD https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/all_in_one.sh /usr/local/bin/xiaoya.sh

COPY ./start.sh /start.sh

RUN chmod +x /usr/local/bin/xiaoya.sh /start.sh