FROM curlimages/curl as source

RUN cd /tmp/ && curl -#Lo acgshop-latest.zip https://faka.wiki/download.php && \
    unzip acgshop-latest.zip

# 使用较新的 PHP 5.6 镜像作为基础镜像
FROM php:8.3.4-apache

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

ENV TZ Asia/Shanghai

# 更新包管理器索引并安装依赖库和PHP扩展
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libpng-dev \
    openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install zip gd mysqli pdo pdo_mysql 

# 设置网站目录
WORKDIR /var/www/html

COPY --from=source /tmp/acg-faka-main /tmp/acg-faka-main

# 开启伪静态支持
RUN a2enmod rewrite

# Expose端口
EXPOSE 80

COPY entrypoint.sh /entrypoint.sh

# 启动Apache服务
CMD ["/entrypoint.sh"]