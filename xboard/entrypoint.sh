#!/bin/bash

DATA_DIR=/www/.docker/.data/

if [ ! -f "${DATA_DIR}/.env" ]; then
  touch "${DATA_DIR}/.env"
fi

ln -sf "${DATA_DIR}/.env" /www/.env

/usr/bin/supervisord --nodaemon -c /etc/supervisor/supervisord.conf