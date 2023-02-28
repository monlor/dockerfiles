FROM jenkins/jenkins:2.392-alpine

USER root

RUN apk add --no-cache tzdata bash && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo Asia/Shanghai > /etc/timezone

USER jenkins
# Skip initial setup
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false" 

COPY plugins.txt /usr/share/jenkins/ref/
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt --clean-download-directory 