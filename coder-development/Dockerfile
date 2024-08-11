FROM codercom/enterprise-base:ubuntu

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.2

ARG DEBIAN_FRONTEND=noninteractive

ENV LANG='C.UTF-8' LC_ALL='C.UTF-8'
ENV TZ=Asia/Shanghai

USER root

RUN apt update && apt install -y tzdata && \
    rm -rf /var/lib/apt/lists/* && \
    # 修改用户shell
    usermod -s /bin/zsh coder 

USER coder

RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/tmp/code-server --version 4.90.3

RUN git clone https://github.com/monlor/dotfiles /home/coder/.config/coderv2/dotfiles && \
    cd /home/coder/.config/coderv2/dotfiles && ./install.sh 

RUN export PATH=/tmp/code-server/bin:$PATH && \
    code-server --install-extension eamodio.gitlens && \
    code-server --install-extension formulahendry.auto-close-tag && \
    code-server --install-extension GitHub.github-vscode-theme && \
    code-server --install-extension github.vscode-github-actions && \
    code-server --install-extension GitHub.vscode-pull-request-github && \
    code-server --install-extension lizebang.bash-extension-pack && \
    code-server --install-extension yzhang.markdown-all-in-one
