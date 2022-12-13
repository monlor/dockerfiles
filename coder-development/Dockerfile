FROM codercom/enterprise-base:ubuntu

ENV LANG='C.UTF-8' LC_ALL='C.UTF-8'

USER root

RUN curl -fsSL https://code-server.dev/install.sh | sh

RUN curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash - && \
    apt update && apt install -y zsh openjdk-8-jdk openjdk-11-jdk build-essential cron vim dnsutils net-tools iputils-ping iproute2 telnet bat trash-cli openconnect oathtool mariadb-client upx-ucl python3 python3-pip rsync tree jq zip fzf golang maven nodejs

RUN npm install --global yarn tyarn && \
    # python 工具
    ln -sf /usr/bin/python3 /usr/bin/python && \
    pip3 install ydcv mycli 

RUN brew tap monlor/taps && \
    brew install monlor/taps/spug-cli

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' > /etc/timezone && \
    # 修改用户shell
    usermod -s /bin/zsh coder 

USER coder
