FROM node:18 AS build

WORKDIR /opt/node_app

ENV EXCALIDRAW_VERSION=0.17.6

RUN curl -LO https://gh.monlor.com/https://github.com/excalidraw/excalidraw/archive/refs/tags/v${EXCALIDRAW_VERSION}.zip && \
    unzip v${EXCALIDRAW_VERSION}.zip && \
    cp -a excalidraw-${EXCALIDRAW_VERSION}/* . && \
    cp -a excalidraw-${EXCALIDRAW_VERSION}/.[!.]* . && \
    rm -rf v${EXCALIDRAW_VERSION}.zip excalidraw-${EXCALIDRAW_VERSION}

# do not ignore optional dependencies:
# Error: Cannot find module @rollup/rollup-linux-x64-gnu
RUN yarn --network-timeout 600000

ARG NODE_ENV=production

RUN yarn build:app:docker

FROM nginx:1.24-alpine

COPY --from=build /opt/node_app/excalidraw-app/build /usr/share/nginx/html

HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1