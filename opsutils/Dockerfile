FROM monlor/ubuntu-base:latest

LABEL MAINTAINER="me@monlor.com"

ENV DOCKER_VERSION="20.10.14"

ENV TIDB_TOOLKIT_VERSION=v6.1.0

RUN apt update && apt install -y build-essential vim dnsutils net-tools iputils-ping iproute2 telnet bat trash-cli mariadb-client upx openssh-server python3 python3-pip nodejs rsync tree jq zip zsh git traceroute && \
    # python 工具
    ln -sf /usr/bin/python3 /usr/bin/python && \
    pip3 install ydcv mycli yq && \
    # k8s 工具
    curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x /usr/local/bin/kubectl && \
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
    # 安装 docker 客户端
    curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz && \
    tar xzvf docker-${DOCKER_VERSION}.tgz --strip 1 -C /usr/local/bin docker/docker && \
    rm -rf docker-${DOCKER_VERSION}.tgz && \
    # 安装zsh
    echo 'y' | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    usermod -s /bin/zsh root && \
    # 安装tidb工具
    curl -Lo /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-amd64.tar.gz https://download.pingcap.org/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-amd64.tar.gz \
    && tar zxvf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-amd64.tar.gz -C /tmp \
    && tar zxvf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-amd64/br-${TIDB_TOOLKIT_VERSION}-linux-amd64.tar.gz -C /usr/bin \
    && tar zxvf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-amd64/dumpling-${TIDB_TOOLKIT_VERSION}-linux-amd64.tar.gz -C /usr/bin \
    && tar zxvf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-amd64/tidb-lightning-${TIDB_TOOLKIT_VERSION}-linux-amd64.tar.gz -C /usr/bin \
    && cp -rf /tmp/tidb-community-toolkit-${TIDB_TOOLKIT_VERSION}-linux-amd64/{tidb-lightning-ctl,mydumper,etcdctl} /usr/bin \
    && rm -rf /tmp/tidb-* && \
    # alias
    echo "alias k=kubectl" >> /etc/profile

CMD [ "tail", "-f", "/dev/null" ]