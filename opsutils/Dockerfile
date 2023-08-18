FROM monlor/ubuntu-base:main

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.6

ARG TARGETARCH

ENV TIDB_TOOLKIT_VERSION=v6.5.0

RUN apt update && apt install -y vim dnsutils net-tools iputils-ping iproute2 telnet bat trash-cli mariadb-client upx openssh-server python3 python3-pip rsync tree jq zip zsh git traceroute && \
    # python 工具
    ln -sf /usr/bin/python3 /usr/bin/python && \
    pip3 install mycli && \
    # k8s 工具
    curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${TARGETARCH}/kubectl" && chmod +x /usr/local/bin/kubectl && \
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
    # 安装tidb工具
    curl -Lo /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}.tar.gz https://download.pingcap.org/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar zxvf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}.tar.gz -C /tmp \
    && tar zxvf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}/br-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/bin \
    && tar zxvf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}/dumpling-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/bin \
    && tar zxvf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}/tidb-lightning-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/bin \
    && cp -rf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}/tidb-lightning-ctl /usr/bin \
    && cp -rf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}/mydumper /usr/bin \
    && cp -rf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-${TARGETARCH}/etcdctl /usr/bin \
    && rm -rf /tmp/tidb-* && \
    # alias
    echo "alias k=kubectl" >> /etc/profile

CMD [ "tail", "-f", "/dev/null" ]