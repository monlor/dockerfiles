FROM jc21/nginx-proxy-manager:latest

ENV OPENRESTY_VERSION ${OPENRESTY_VERSION}
  
RUN apt update && apt install -y uuid-dev libssl-dev zlib1g-dev libpcre3 libpcre3-dev build-essential

#Download openresty & pagespeed
RUN cd /tmp && curl "https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz" | tar zx
RUN cd /tmp/openresty-${OPENRESTY_VERSION} && curl -O https://codeload.github.com/apache/incubator-pagespeed-ngx/zip/v1.14.33.1-RC1 && unzip v1.14.33.1-RC1 && rm v1.14.33.1-RC1
RUN cd /tmp/openresty-${OPENRESTY_VERSION}/incubator-pagespeed-ngx-1.14.33.1-RC1 && curl https://dist.apache.org/repos/dist/release/incubator/pagespeed/1.14.36.1/x64/psol-1.14.36.1-apache-incubating-x64.tar.gz |tar zx

#Config and make
RUN cd /tmp/openresty-${OPENRESTY_VERSION} && \
    ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-compat \
        --with-threads \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_mp4_module \
        --with-http_random_index_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_v2_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-stream \
        --with-stream_realip_module \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --add-module=incubator-pagespeed-ngx-1.14.33.1-RC1 && \
    make -j2 && \
    make install