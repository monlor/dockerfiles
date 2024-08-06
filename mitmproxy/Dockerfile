FROM mitmproxy/mitmproxy

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

RUN apt-get update && apt-get install -y curl && \
    pip install requests

COPY mitmproxy.py /mitmproxy.py

EXPOSE 8080 8081

ENTRYPOINT ["mitmweb", "--web-host", "0.0.0.0", "--web-port", "8081", "--listen-port", "8080", "-s", "/mitmproxy.py"]