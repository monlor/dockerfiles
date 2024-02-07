FROM beginner202010/forwordpanel:1.0.7-SNAPSHOT as source

FROM amazoncorretto:8u402

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.3

ENV LANG=C.UTF-8

VOLUME /data

WORKDIR /app

COPY --from=source /forward_db* /app/
COPY --from=source app.jar /app/

COPY application.properties /app/

COPY entrypoint.sh /

RUN mkdir /config && chmod +x /entrypoint.sh

Entrypoint [ "/entrypoint.sh" ]