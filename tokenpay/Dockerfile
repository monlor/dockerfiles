FROM debian:buster

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

ENV TZ Asia/Shanghai

ARG TARGETARCH

ENV TOKENPAY_VERSION v1.0.7.7

RUN apt update && apt install -y libicu-dev curl unzip socat

RUN if [ "${TARGETARCH}" = "amd64" ]; then TARGETARCH="x64"; fi && \
    curl -Lo /tmp/tokenpay.zip https://github.com/LightCountry/TokenPay/releases/download/${TOKENPAY_VERSION}/release-linux-${TARGETARCH}.zip && \
    unzip /tmp/tokenpay.zip -d /app && rm -rf /tmp/tokenpay.zip

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh && mkdir /data

WORKDIR /app

ENTRYPOINT ["/entrypoint.sh"]