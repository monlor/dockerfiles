FROM codercom/enterprise-base:ubuntu

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.0.5

ARG DEBIAN_FRONTEND=noninteractive

ENV LANG='C.UTF-8' LC_ALL='C.UTF-8'
ENV TZ=Asia/Shanghai

USER root

RUN apt update && apt install -y tzdata openssh-server && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
    sed -i 's@#HostKey /etc/ssh/ssh_host_rsa_key@HostKey /home/coder/.ssh/ssh_host_rsa_key@g' /etc/ssh/sshd_config && \
    sed -i 's@#HostKey /etc/ssh/ssh_host_ecdsa_key@HostKey /home/coder/.ssh/ssh_host_ecdsa_key@g' /etc/ssh/sshd_config && \
    sed -i 's@#HostKey /etc/ssh/ssh_host_ed25519_key@HostKey /home/coder/.ssh/ssh_host_ed25519_key@g' /etc/ssh/sshd_config && \
    rm -rf /var/lib/apt/lists/* && \
    # 修改用户shell
    usermod -s /bin/zsh coder 

USER coder

RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/tmp/code-server

RUN git clone https://github.com/monlor/dotfiles /tmp/dotfiles && \
    cd /tmp/dotfiles && ./install.sh && rm -rf /tmp/dotfiles

RUN export PATH=/tmp/code-server/bin:$PATH && \
    code-server --install-extension eamodio.gitlens && \
    code-server --install-extension formulahendry.auto-close-tag && \
    code-server --install-extension GitHub.github-vscode-theme && \
    code-server --install-extension github.vscode-github-actions && \
    code-server --install-extension GitHub.vscode-pull-request-github 

COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]