FROM ubuntu:latest

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

RUN apt update && apt install dnsmasq -y && apt clean

COPY media.txt /tmp

COPY --chmod=0655 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]