FROM stilleshan/dujiaoka:2.0.6

LABEL MAINTAINER me@monlor.com
LABEL VERSION 2.0.6

RUN git clone https://github.com/LightCountry/TokenPay && \
    chown application:application -R TokenPay && \
    cp -a TokenPay/Plugs/dujiaoka/* /dujiaoka/ && \
    rm -rf TokenPay