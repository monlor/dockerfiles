FROM monlor/ubuntu-base:latest

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.3

ARG TIDB_TOOLKIT_VERSION=v6.5.0

RUN curl -Lo /tmp/tidb-toolkit.tar.gz https://download.pingcap.org/tidb-toolkit-${TIDB_TOOLKIT_VERSION}-linux-amd64.tar.gz \
  && tar zxvf /tmp/tidb-toolkit.tar.gz -C /tmp \
  && cp /tmp/tidb-toolkit-${TIDB_TOOLKIT_VERSION}-linux-amd64/bin/* /usr/bin \
  && rm -rf /tmp/tidb-* 
  
ENTRYPOINT ["/bin/bash"]