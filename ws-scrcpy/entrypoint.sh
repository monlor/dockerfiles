#!/bin/sh

TIMEOUT=${TIMEOUT:-300}

if [ -n "${ADB_ADDRESS:-}" ]; then
  echo ${ADB_ADDRESS} | tr ',' '\n' | while read address; do
    echo "Connect to ${address} ..."
    host=$(echo ${address} | cut -d':' -f1)
    port=$(echo ${address} | cut -d':' -f2)
    start=0
    while ! nc -w 1 -z "${host}" "${port}"; do
      echo "Failed to connect to ${address}, retry after 1s ..."
      sleep 1
      start=$((start+1))
      if [ "${start}" -ge "${TIMEOUT}" ]; then
        echo "Timeout to connect to ${address}, break ..."
        break
      fi
    done
    if [ "${start}" -ge "${TIMEOUT}" ]; then
        echo "Skipping to next address ..."
        continue
    fi
    adb connect "${address}"
  done
fi

node dist/index.js