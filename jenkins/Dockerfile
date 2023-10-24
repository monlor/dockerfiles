FROM jenkins/jenkins:2.375.3-lts

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.6

USER root

RUN apt install -y --no-install-recommends tzdata curl && apt clean && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo Asia/Shanghai > /etc/timezone 

USER jenkins

COPY plugins.txt /usr/share/jenkins/ref/
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt --clean-download-directory 