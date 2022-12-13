FROM codercom/enterprise-base:ubuntu

ENV LANG='C.UTF-8' LC_ALL='C.UTF-8'

USER root

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' > /etc/timezone && \
    # 修改用户shell
    usermod -s /bin/zsh coder 

RUN curl -fsSL https://code-server.dev/install.sh | sh

RUN curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash - && \
    apt update && apt install -y zsh openjdk-8-jdk openjdk-11-jdk build-essential cron vim dnsutils net-tools iputils-ping iproute2 telnet bat trash-cli openconnect oathtool mariadb-client upx-ucl python3 python3-pip rsync tree jq zip fzf golang maven nodejs

RUN npm install --global yarn tyarn && \
    # python 工具
    ln -sf /usr/bin/python3 /usr/bin/python && \
    pip3 install ydcv mycli 

ENV SPUG_CLI_VERSION="v0.0.3"

RUN curl -#Lo /usr/local/bin/spug-cli https://github.com/monlor/spug-cli/releases/download/${SPUG_CLI_VERSION}/spug-cli_linux_amd64 && \
    chmod +x /usr/local/bin/*

USER coder