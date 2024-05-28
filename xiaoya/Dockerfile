FROM xiaoyaliu/alist:latest

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

EXPOSE 80 2345 2346

VOLUME /data

COPY ./start.sh /start.sh

ENTRYPOINT [ "bash", "/start.sh" ]

CMD []