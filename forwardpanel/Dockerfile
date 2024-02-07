FROM beginner202010/forwordpanel:1.0.7-SNAPSHOT as source

FROM amazoncorretto:8u402

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.2

ENV LANG=C.UTF-8

VOLUME /data

WORKDIR /app

COPY application.properties /app/
COPY --from=source /forward_db* /data/
COPY --from=source app.jar /app/

RUN mkdir /config

Entrypoint [ "/usr/bin/java", "-jar", "/app/app.jar" ]