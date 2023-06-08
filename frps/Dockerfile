FROM fatedier/frps:v0.49.0

LABEL MAINTAINER me@monlor.com
LABEL VERSION v0.49.0

EXPOSE 7000 7500 8080

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]