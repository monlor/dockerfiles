#!/bin/bash

if [ ! -d ~/.dotfiles ]; then
  git clone https://github.com/monlor/dotfiles ~/.dotfiles
  cd ~/.dotfiles || exit
  make install
fi

/tmp/code-server/bin/code-server --port 8080 --host 0.0.0.0