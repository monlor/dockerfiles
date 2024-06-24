## 介绍

修改nezha的docker镜像

## 部署

```bash
docker run -d --name nezha monlor/nezha
```

## 环境变量

* `GRPC_PORT`: grpc端口，默认5555
* `OAUTH_TYPE`: oauth类型，默认github，github/gitee/gitea
* `OAUTH_ADMIN`: 管理员列表，逗号分隔
* `OAUTH_CLIENT_ID`: oauth客户端id
* `OAUTH_CLIENT_SECRET`: oauth客户端密钥
* `OAUTH_ENDPOINT`: gitea自建需要
* `SITE_BRAND`: 网站标题
* `SITE_THEME`: 网站主题

## 创建github认证

https://github.com/settings/developers

* `Application name`: Nezha Monitor
* `Homepage URL`: 填写面板的访问域名，如："http://cdn.example.com"
* `Authorization callback URL`: 填写回调地址，如："http://cdn.example.com/oauth2/callback"

## 部署agent

https://nezha.wiki/guide/agent.html

**在Linux中部署**

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh)"
```

## 来源

https://github.com/naiba/nezha