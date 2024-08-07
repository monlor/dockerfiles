# 使用较新的 PHP 5.6 镜像作为基础镜像
FROM php:7.3-apache

LABEL MAINTAINER me@monlor.com
LABEL VERSION 2.0.1

ENV TZ Asia/Shanghai

# 更新包管理器索引并安装依赖库和PHP扩展
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libmcrypt-dev \
    libgdiplus \
    openssl \
    rsync \
    git && \
    printf '\n' | pecl install mcrypt && \
    docker-php-ext-enable mcrypt && \
    docker-php-ext-configure gd \
     --with-freetype-dir=/usr/include/freetype2 \
     --with-png-dir=/usr/include \
     --with-jpeg-dir=/usr/include && \
    docker-php-ext-install gd mysqli pdo pdo_mysql 

# 设置网站目录
WORKDIR /var/www/html

# 下载v免签服务源代码并解压到镜像中
RUN git clone https://github.com/monlor/Epay-master /var/www/html && \
    chmod -R 777 /var/www/html && \
    rm -rf /var/www/html/.git

# 开启伪静态支持
RUN a2enmod rewrite

# 添加 tokenpay 插件
RUN git clone https://github.com/LightCountry/TokenPay && \
    cat TokenPay/Plugs/epay/*.sql > /var/www/html/epay.sql && \
    rm -rf TokenPay/Plugs/epay/*.sql TokenPay/Plugs/epay/{.git,README.md} && \
    cp -a TokenPay/Plugs/epay/* /var/www/html && \
    rm -rf TokenPay

# Expose端口
EXPOSE 80

ADD plugins /var/www/html/plugins

ADD assets /var/www/html/assets

COPY start.sh /opt/start.sh

RUN chmod +x /opt/start.sh

# 启动Apache服务
CMD ["/opt/start.sh"]