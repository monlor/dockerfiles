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

RUN code-server --install-extension eamodio.gitlens && \
    code-server --install-extension formulahendry.auto-close-tag && \
    code-server --install-extension GitHub.copilot && \
    code-server --install-extension GitHub.github-vscode-theme && \
    code-server --install-extension github.vscode-github-actions && \
    code-server --install-extension GitHub.vscode-pull-request-github && \
    code-server --install-extension lizebang.bash-extension-pack && \
    code-server --install-extension yzhang.markdown-all-in-one

RUN git clone https://github.com/monlor/dotfiles /home/coder/.config/coderv2/dotfiles && \
    cd /home/coder/.config/coderv2/dotfiles && ./install.sh 
