FROM jenkins/jenkins:2.375.3-lts

LABEL MAINTAINER="me@monlor.com"

USER root

RUN apt install -y --no-install-recommends locales tzdata curl && apt clean && \
    echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen zh_CN.UTF-8 && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo Asia/Shanghai > /etc/timezone 

USER jenkins
# Skip initial setup
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false" 

COPY plugins.txt /usr/share/jenkins/ref/
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt --clean-download-directory 