FROM monlor/ubuntu-base:latest

LABEL MAINTAINER me@monlor.com
LABEL VERSION 7.1.0

ARG TARGETARCH

ENV TIDB_TOOLKIT_VERSION=v7.1.0

RUN curl -Lo /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}.tar.gz https://download.pingcap.org/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar zxvf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}.tar.gz -C /tmp \
    && tar zxvf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}/br-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/bin \
    && tar zxvf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}/dumpling-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/bin \
    && tar zxvf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}/tidb-lightning-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/bin \
    && cp -rf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}/tidb-lightning-ctl /usr/bin \
    && cp -rf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}/mydumper /usr/bin \
    && cp -rf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}/etcdctl /usr/bin \
    && rm -rf /tmp/tidb-*
  
ENTRYPOINT ["/bin/cat"]