#!/bin/bash

if [ ! -d ~/.dotfiles ]; then
  git clone https://github.com/monlor/dotfiles ~/.dotfiles
  cd ~/.dotfiles || exit
  make install
fi

# fix ownership of /home/coder
sudo chown coder:coder /home/coder
sudo chmod 755 /home/coder

# setup ssh
if [ ! -d ~/.ssh ]; then
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
fi
if [ ! -f ~/.ssh/ssh_host_rsa_key ]; then
  ssh-keygen -t rsa -f ~/.ssh/ssh_host_rsa_key -N ''
fi
if [ ! -f ~/.ssh/ssh_host_ecdsa_key ]; then
  ssh-keygen -t ecdsa -f ~/.ssh/ssh_host_ecdsa_key -N ''
fi
if [ ! -f ~/.ssh/ssh_host_ed25519_key ]; then
  ssh-keygen -t ed25519 -f ~/.ssh/ssh_host_ed25519_key -N ''
fi
chmod 600 ~/.ssh/ssh_host_*
sudo /usr/sbin/sshd

if [ -n "${SSH_PUBLIC_KEY}" ]; then
  echo "${SSH_PUBLIC_KEY}" > ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
fi

/tmp/code-server/bin/code-server --port 8080 --host 0.0.0.0