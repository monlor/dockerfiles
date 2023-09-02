FROM docker.n8n.io/n8nio/n8n

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

ENV NODE_FUNCTION_ALLOW_EXTERNAL=*

USER root

RUN npm i -g pnpm && \
    cd /usr/local/lib/node_modules && pnpm install iconv-lite jschardet fast-csv

USER node