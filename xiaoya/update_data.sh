#!/bin/bash

data_dir=/data/data

echo "开始更新数据..."

if [ ! -d "${data_dir}" ]; then
    mkdir -p ${data_dir}
fi

old_version=$(cat ${data_dir}/version.txt 2> /dev/null)
new_version=$(curl -Ls https://github.com/xiaoyaliu00/data/raw/main/version.txt)

if [ "${old_version}" = "${new_version}" ]; then
    echo "数据已是最新版本"
    exit 0
fi

curl -#fsSLo ${data_dir}/tvbox.zip https://github.com/xiaoyaliu00/data/raw/main/tvbox.zip
curl -#fsSLo ${data_dir}/update.zip https://github.com/xiaoyaliu00/data/raw/main/update.zip
curl -#fsSLo ${data_dir}/index.zip https://github.com/xiaoyaliu00/data/raw/main/index.zip
curl -#fsSLo ${data_dir}/version.txt https://github.com/xiaoyaliu00/data/raw/main/version.txt