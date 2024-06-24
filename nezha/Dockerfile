FROM registry.cn-shanghai.aliyuncs.com/naibahq/nezha-dashboard

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

EXPOSE 80 5555

VOLUME /dashboard/data

WORKDIR /dashboard

COPY --chmod=755 ./start.sh /start.sh

ENTRYPOINT ["/start.sh"]