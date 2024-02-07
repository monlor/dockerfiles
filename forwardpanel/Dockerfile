FROM beginner202010/forwordpanel:1.0.7-SNAPSHOT

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

VOLUME /data

COPY application.properties /

RUN mkdir /data /config && mv /forward_db* /data 