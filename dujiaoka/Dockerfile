FROM ghcr.io/apocalypsor/dujiaoka:latest

LABEL MAINTAINER=me@monlor.com
LABEL VERSION=2.1.4

RUN curl -#LO https://gh.monlor.com/https://github.com/LightCountry/TokenPay/archive/refs/heads/master.zip && \
    unzip master.zip && \
    chown application:application -R TokenPay-master && \
    cp -a TokenPay-master/Plugs/dujiaoka/* /dujiaoka/ && \
    rm -rf master.zip TokenPay-master

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "bash", "/entrypoint.sh" ]