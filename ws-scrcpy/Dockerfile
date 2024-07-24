FROM node:16

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.1

LABEL ORIGINAL_AUTHOR="Scavin <scavin@appinn.com>"

ENV LANG C.UTF-8
WORKDIR /ws-scrcpy

RUN apt update;apt install android-tools-adb netcat -y && \
    npm install -g node-gyp

RUN git clone https://github.com/NetrisTV/ws-scrcpy.git . && \
    npm install && npm run dist

EXPOSE 8000

COPY --chmod=755 entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]