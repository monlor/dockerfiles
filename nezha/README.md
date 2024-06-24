## 介绍

修改nezha的docker镜像

## 部署

```bash
docker run -d --name nezha -v your_data:/dashboard/data -p 8080:80 -p 5555:5555 monlor/nezha
```

## 环境变量

* `DEBUG`: 是否开启debug
* `HTTP_PORT`: http端口，默认80
* `GRPC_PORT`: grpc端口，默认5555
* `OAUTH_TYPE`: oauth类型，默认github，github/gitee/gitea
* `OAUTH_ADMIN`: 管理员列表，逗号分隔
* `OAUTH_CLIENT_ID`: oauth客户端id
* `OAUTH_CLIENT_SECRET`: oauth客户端密钥
* `OAUTH_ENDPOINT`: gitea自建需要

## 创建github认证

https://github.com/settings/developers

* `Application name`: Nezha Monitor
* `Homepage URL`: 填写面板的访问域名，如："http://cdn.example.com"
* `Authorization callback URL`: 填写回调地址，如："http://cdn.example.com/oauth2/callback"

## 部署agent

https://nezha.wiki/guide/agent.html

1. 进入后台管理，配置服务器IP
2. 后台管理添加服务器，复制agent一键部署命令
3. 在目标服务器上执行

## 来源

https://github.com/naiba/nezha