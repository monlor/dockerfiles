FROM docker.n8n.io/n8nio/n8n

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

USER root

RUN cd /usr/local/lib/node_modules && npm i iconv-lite

USER node