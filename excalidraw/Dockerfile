FROM node:18 AS build

WORKDIR /opt/node_app

RUN curl -LO https://github.com/excalidraw/excalidraw/archive/refs/heads/master.zip && \
    unzip master.zip && \
    cp -rf excalidraw-master/* . && \
    cp -rf excalidraw-master/.[!.]* . && \
    rm -rf excalidraw-master master.zip

# do not ignore optional dependencies:
# Error: Cannot find module @rollup/rollup-linux-x64-gnu
RUN yarn --network-timeout 600000

ARG NODE_ENV=production

RUN yarn build:app:docker

FROM nginx:1.24-alpine

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.1

COPY --from=build /opt/node_app/excalidraw-app/build /usr/share/nginx/html

COPY Mengshen.woff /usr/share/nginx/html/Virgil.woff2

HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1