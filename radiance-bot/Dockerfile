FROM amazoncorretto:17-alpine

WORKDIR /app

RUN apk add --no-cache curl bash

RUN curl -LO https://gh.monlor.com/https://github.com/semicons/java_oci_manage/releases/latest/download/gz_client_bot.tar.gz && \
    tar -xvf gz_client_bot.tar.gz && \
    chmod +x sh_client_bot.sh && \
    rm gz_client_bot.tar.gz

COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]