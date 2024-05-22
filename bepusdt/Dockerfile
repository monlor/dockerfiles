FROM golang:1.22.2 AS builder

ENV BEPUSDT_VERSION=v1.9.22

ENV GO111MODULE=on
WORKDIR /go/release
ADD https://github.com/v03413/bepusdt/archive/refs/tags/${BEPUSDT_VERSION}.tar.gz .
RUN set -x \
    && tar zxvf ${BEPUSDT_VERSION}.tar.gz --strip-components=1 \
    && CGO_ENABLED=1 go build -trimpath -ldflags="-linkmode external -extldflags -static -s -w -buildid=" -o bepusdt ./main

FROM debian:latest

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.1

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NOWARNINGS="yes"
ENV TZ=Asia/Shanghai

COPY --from=builder /go/release/bepusdt /runtime/bepusdt

COPY --from=builder /go/release/templates /runtime/templates
COPY --from=builder /go/release/static /runtime/static

RUN apt-get update && apt-get install -y --no-install-recommends tzdata ca-certificates libc6 libgcc1 libstdc++6 \
    && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 8080
CMD ["/runtime/bepusdt"]