FROM mitmproxy/mitmproxy

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

RUN apt-get update && apt-get install -y curl nginx && \
    pip install requests

COPY mitmproxy.py /mitmproxy.py

COPY nginx.conf /etc/nginx/nginx.conf

COPY --chmod=755 entrypoint.sh /

EXPOSE 80 8080 8081

ENTRYPOINT [ "/entrypoint.sh" ]