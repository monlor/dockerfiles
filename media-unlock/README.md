## 介绍

搭建一个用于流媒体解锁的dns服务器，指定sni服务器即可快速部署

## 部署

```
docker run -d --name media-unlock -e SNI_IP=x.x.x.x -p 53:53 monlor/media-unlock
```

## 环境变量

`MEDIA_DOMAIN_URL`: 支持指定远程的流媒体域名列表地址

`SNI_IPS`: SNI IP列表，用逗号分隔

`TEST_INTERVAL`: IP可用性测试间隔，默认60