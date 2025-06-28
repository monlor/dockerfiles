FROM jc21/nginx-proxy-manager:2.12.3

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.2.0

COPY --chmod=755 *.conf /snippets/

COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]