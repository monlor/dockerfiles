#!/bin/sh

RCLONE_CONFIG_PATH=${RCLONE_CONFIG_PATH:-/etc/rclone/rclone.conf}
RCLONE_CONFIG=${RCLONE_CONFIG:-AllDrives}

if [ -f "${RCLONE_CONFIG_PATH}" ]; then

  echo ${RCLONE_CONFIG} | tr ',' '\n' | while read config; do
    rclone --config "${RCLONE_CONFIG_PATH}" mount "${config}:" "/mnt/${config}" \
      --umask 0000 \
      --default-permissions \
      --allow-other \
      --allow-non-empty \
      --buffer-size 32M \
      --dir-cache-time 12h \
      --vfs-read-chunk-size 64M \
      --vfs-read-chunk-size-limit 1G &
  done

fi

/init