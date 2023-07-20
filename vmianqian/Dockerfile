# 使用较新的 PHP 5.6 镜像作为基础镜像
FROM php:7.3-apache

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

# 更新包管理器索引并安装依赖库和PHP扩展
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libmcrypt-dev \
    git \
    && docker-php-ext-install gd mysqli pdo pdo_mysql bcmath

# 设置网站目录
WORKDIR /var/www/html

# 修改运行目录为public
RUN sed -i "s/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/public/; \
    /DocumentRoot/a \ \ \ \ \ \ \ \ DirectoryIndex index.html index.php" /etc/apache2/sites-available/000-default.conf 

# 下载v免签服务源代码并解压到镜像中
RUN git clone https://github.com/szvone/vmqphp.git /var/www/html

# 开启伪静态支持
RUN a2enmod rewrite

# 设置网站数据库配置
RUN sed -Ei "s/'hostname'\s*=>\s*'.*',/'hostname' => getenv('MYSQL_HOST') ?: '127.0.0.1',/g; \
    s/'database'\s*=>\s*'.*',/'database' => getenv('MYSQL_DATABASE') ?: 'vmq',/g; \
    s/'username'\s*=>\s*'.*',/'username' => getenv('MYSQL_USER') ?: 'root',/g; \
    s/'password'\s*=>\s*'.*',/'password' => getenv('MYSQL_PASSWORD') ?: 'root',/g; \
    s/'hostport'\s*=>\s*'.*',/'hostport' => getenv('MYSQL_PORT') ?: '3306',/g" /var/www/html/config/database.php
    
# Expose端口
EXPOSE 80

# 启动Apache服务
CMD ["apache2-foreground"]