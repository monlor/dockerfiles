FROM ghcr.io/apocalypsor/dujiaoka:usdt

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.2

EXPOSE 8000

RUN apk add mysql-client --no-cache

COPY ./entrypoint.sh /entrypoint.sh

Entrypoint [ "/bin/sh", "/entrypoint.sh" ]

CMD []