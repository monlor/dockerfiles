FROM ghcr.io/apocalypsor/dujiaoka:usdt

LABEL MAINTAINER me@monlor.com
LABEL VERSION 2.1.0

RUN git clone https://github.com/LightCountry/TokenPay && \
    chown application:application -R TokenPay && \
    cp -a TokenPay/Plugs/dujiaoka/* /dujiaoka/ && \
    rm -rf TokenPay