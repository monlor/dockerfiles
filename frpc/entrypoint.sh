#!/bin/sh

# 生成frpc.toml配置文件
cat > /frpc.toml <<EOF
serverAddr = "${SERVER_ADDR:-127.0.0.1}"
serverPort = ${SERVER_PORT:-7000}

[auth]
token = "${TOKEN:-}"

EOF

# 处理环境变量,生成frpc配置
env | grep -E "^(TCP|UDP|HTTP|HTTPS|PROXY|KCP)_" | while read -r line; do
    name=$(echo "$line" | cut -d'=' -f1)
    value=$(echo "$line" | cut -d'=' -f2-)
    
    protocol=$(echo "$name" | cut -d'_' -f1 | tr '[:upper:]' '[:lower:]')
    
    if [ "$protocol" = "http" ] || [ "$protocol" = "https" ]; then
        config_name=$(echo "$name" | cut -d'_' -f2 | tr '[:upper:]' '[:lower:]')
        domain=$(echo "$name" | cut -d'_' -f3- | tr '_' '.' | tr '[:upper:]' '[:lower:]')
        port=$(echo $value | cut -d':' -f2)
        config_name="${config_name}_${port}"
    elif [ "$protocol" = "proxy" ]; then
        config_name=$(echo "$name" | cut -d'_' -f2 | tr '[:upper:]' '[:lower:]')
        remote_port=$(echo "$name" | cut -d'_' -f3)
        user=$(echo "$name" | cut -d'_' -f4)
        config_name="${config_name}_${remote_port}"
    else
        config_name=$(echo "$name" | cut -d'_' -f2- | tr '[:upper:]' '[:lower:]')
    fi
    
    echo "[[proxies]]" >> /frpc.toml
    echo "name = \"$config_name\"" >> /frpc.toml
    
    case $protocol in
        http|https)
            echo "type = \"$protocol\"" >> /frpc.toml
            echo "localIP = \"$(echo $value | cut -d':' -f1)\"" >> /frpc.toml
            echo "localPort = $port" >> /frpc.toml
            if echo "$domain" | grep -q "\\."; then
                echo "customDomains = [\"$domain\"]" >> /frpc.toml
            else
                echo "subdomain = \"$domain\"" >> /frpc.toml
            fi
            ;;
        tcp|udp|kcp)
            echo "type = \"$protocol\"" >> /frpc.toml
            echo "localIP = \"$(echo $value | cut -d':' -f1)\"" >> /frpc.toml
            echo "localPort = $(echo $value | cut -d':' -f2)" >> /frpc.toml
            echo "remotePort = $(echo $name | cut -d'_' -f3)" >> /frpc.toml
            ;;
        proxy)
            echo "type = \"tcp\"" >> /frpc.toml
            echo "remotePort = $remote_port" >> /frpc.toml
            echo "[proxies.plugin]" >> /frpc.toml
            echo "type = \"http_proxy\"" >> /frpc.toml
            echo "httpUser = \"$user\"" >> /frpc.toml
            echo "httpPassword = \"$value\"" >> /frpc.toml
            ;;
    esac
    
    echo "" >> /frpc.toml
done

# 启动frpc
exec frpc -c /frpc.toml
