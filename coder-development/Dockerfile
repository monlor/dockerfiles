FROM monlor/enterprise-base:latest

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.0

ENV LANG='C.UTF-8' LC_ALL='C.UTF-8'

USER root

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' > /etc/timezone && \
    # 修改用户shell
    usermod -s /bin/zsh coder 

RUN curl -fsSL https://code-server.dev/install.sh | sh

USER coder

RUN code-server --install-extension eamodio.gitlens formulahendry.auto-close-tag GitHub.copilot GitHub.github-vscode-theme github.vscode-github-actions GitHub.vscode-pull-request-github lizebang.bash-extension-pack yzhang.markdown-all-in-one

RUN git clone https://github.com/monlor/dotfiles /home/coder/.config/coderv2/dotfiles && \
    cd /home/coder/.config/coderv2/dotfiles && ./install.sh 
