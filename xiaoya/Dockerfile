FROM xiaoyaliu/alist:latest

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

EXPOSE 80 2345 2346

VOLUME /data

ADD https://github.com/xiaoyaliu00/data/raw/main/tvbox.zip /data/data
ADD https://github.com/xiaoyaliu00/data/raw/main/update.zip /data/data
ADD https://github.com/xiaoyaliu00/data/raw/main/index.zip /data/data
ADD https://github.com/xiaoyaliu00/data/raw/main/version.txt /data/data

COPY ./start.sh /start.sh
COPY ./update_data.sh /update_data.sh

ENTRYPOINT [ "bash", "/start.sh" ]

CMD []