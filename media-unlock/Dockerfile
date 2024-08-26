FROM ubuntu:latest

LABEL MAINTAINER me@monlor.com
LABEL VERSION 2.0.0

RUN apt update && apt install dnsmasq bash curl -y && apt clean

COPY *.txt /tmp

COPY --chmod=0655 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]