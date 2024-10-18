# frpc Docker 服务

这是一个基于环境变量配置的frpc Docker服务。通过设置环境变量，您可以轻松配置frpc进行各种网络穿透。

## 使用方法

1. 拉取Docker镜像:

```bash
docker pull monlor/frpc
```

2. 运行Docker容器，设置必要的环境变量:

```bash
docker run -d \
  -e SERVER_ADDR=your_frps_server_address \
  -e SERVER_PORT=7000 \
  -e TOKEN=your_frps_token \
  -e TCP_SSH_22=127.0.0.1:22 \
  -e HTTP_WEB_WWW=127.0.0.1:80 \
  monlor/frpc
```

## 环境变量说明

- `SERVER_ADDR`: frps服务器地址 (默认: 127.0.0.1)
- `SERVER_PORT`: frps服务器端口 (默认: 7000)
- `TOKEN`: frps认证令牌 (可选)

### 配置穿透规则

您可以通过添加环境变量来配置穿透规则。格式如下：

1. TCP/UDP/KCP:
   ```
   {PROTOCOL}_{NAME}_{REMOTE_PORT}=LOCAL_IP:LOCAL_PORT
   ```

2. HTTP/HTTPS:
   ```
   {PROTOCOL}_{NAME}_{DOMAIN}=LOCAL_IP:LOCAL_PORT
   ```

3. HTTP_PROXY:
   ```
   PROXY_{NAME}_{REMOTE_PORT}_{USER}={PASSWORD}
   ```

- `PROTOCOL`: 可以是TCP, UDP, HTTP, HTTPS, 或 KCP
- `NAME`: 配置名称
- `REMOTE_PORT`: 远程服务器上的端口
- `LOCAL_IP`: 本地IP地址
- `LOCAL_PORT`: 本地端口
- `DOMAIN`: HTTP/HTTPS服务的域名或子域名（使用下划线代替点来表示完整域名）
- `USER`: HTTP代理的用户名
- `PASSWORD`: HTTP代理的密码

例如:

- `TCP_SSH_22=127.0.0.1:22`: 将本地的22端口(SSH服务)映射到远程服务器的22端口
- `HTTP_WEB_WWW=127.0.0.1:80`: 将本地的80端口(Web服务)映射到子域名www
- `HTTP_WEB_WWW_EXAMPLE_COM=127.0.0.1:80`: 将本地的80端口映射到自定义域名www.example.com
- `PROXY_HTTP_8080_USER=password`: 在远程8080端口配置带认证的HTTP代理

您可以添加任意数量的类似环境变量来配置多个穿透规则。

## 注意事项

- 确保您的frps服务器已正确配置并运行
- 根据需要调整防火墙设置，以允许必要的端口通信
- 请勿在公共环境中暴露敏感服务
- 某些配置类型可能需要在frps服务器端进行相应的设置
- 所有域名和配置名称在最终配置中都会被转换为小写
