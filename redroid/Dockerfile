# 编译容器
FROM ubuntu:20.04 AS builder

# 安装必要的工具
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    tar \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# 下载和准备 Magisk
RUN wget "https://cdn.jsdelivr.net/gh/topjohnwu/magisk-files@1cea72840fbf690f9a95512d03721f6a710fe02e/app-debug.apk" \
    && mkdir -p MagiskOnRedroid/magisk \
    && unzip -j app-debug.apk "lib/x86_64/libmagisk64.so" -d MagiskOnRedroid/magisk \
    && unzip -j app-debug.apk "lib/x86_64/libbusybox.so" -d MagiskOnRedroid/magisk \
    && mv MagiskOnRedroid/magisk/libmagisk64.so MagiskOnRedroid/magisk/magisk \
    && mv MagiskOnRedroid/magisk/libbusybox.so MagiskOnRedroid/magisk/busybox

# 创建 magisk.tar
RUN tar --transform 's/.*\///g' -cf magisk.tar --absolute-names $(find MagiskOnRedroid | grep -E "magisk/|app-debug.apk$")

# 创建 remove.rc 和 setup.sh
COPY remove.rc /build/remove.rc
COPY setup.sh /build/setup.sh

# redroid 运行容器
FROM redroid/redroid:13.0.0-latest

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

# 从编译容器复制文件并设置权限和所有者
COPY --from=builder --chmod=755 /build/remove.rc /vendor/etc/init/remove.rc
COPY --from=builder --chmod=755 /build/setup.sh /setup.sh
COPY --from=builder --chmod=755 /build/magisk.tar /magisk.tar