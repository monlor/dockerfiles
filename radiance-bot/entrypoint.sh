#!/bin/sh

set -eu

cat > /app/client_config <<-EOF
#在oci=begin和oci=end之间放入你的API配置信息 支持多个配置文件 机器人操作profile管理里可更换操作账户
oci=begin
$(cat /app/oracle_config 2> /dev/null)
oci=end

#用户信息 从 https://t.me/radiance_helper_bot 配置(bot可使用/raninfo命令随机生成)
#必传
username=${TG_BOT_USERNME}
#必传
password=${TG_BOT_PASSWORD}


#cloudflare 功能参数 非必传
#非必传 cloudflare邮箱
cf_email=
#非必传 cloudflare key 在我的个人资料->API令牌处->API密钥->Global API Key	获取
cf_account_key=


#非必填 本机ip和端口号 (进阶玩家选项 可填写域名) 不写将自动获取本机ip 并使用默认端口号9527 (小白用户建议不填) 如填写 格式为:https://xxx.xx:9527
local_address=
#非必填 url名称(默认为address 可在bot上修改)
local_url_name=

#非必填 启动模式 填写local为启动本地无公网IP模式(只要能联网即可) 不填或填其他 则启动端口模式
model=local



#在azure=begin和azure=end之间放入你的azure的API配置信息 支持多个配置文件 机器人切换profile可更换操作配置 上传配置支持使用原格式({"appId":"xxx","password":"xxx"...})上传 
azure=begin
$(cat /app/azure_config 2> /dev/null)
azure=end
EOF

cd /app && bash sh_client_bot.sh &

if [ ! -f /app/log_r_client.log ]; then
    touch /app/log_r_client.log
fi

tail -f /app/log_r_client.log