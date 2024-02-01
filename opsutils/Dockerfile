FROM monlor/ubuntu-base:main

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.7

ARG TARGETARCH

RUN apt update && apt install -y vim dnsutils net-tools iputils-ping iproute2 telnet bat trash-cli mariadb-client upx openssh-server rsync tree jq zip zsh git traceroute mtr && \
    # k8s 工具
    curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${TARGETARCH}/kubectl" && chmod +x /usr/local/bin/kubectl && \
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
    # alias
    echo "alias k=kubectl" >> /etc/profile

CMD [ "tail", "-f", "/dev/null" ]