FROM ubuntu:latest

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

RUN apt update && apt install sniproxy -y && apt clean

COPY --chmod=0655 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]