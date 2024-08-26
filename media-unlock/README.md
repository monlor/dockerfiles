## 介绍

搭建一个用于流媒体解锁的dns服务器，指定sni服务器即可快速部署

## 部署

```
docker run -d --name media-unlock -e SNI_IP=x.x.x.x -p 53:53 monlor/media-unlock
```

## 环境变量

`MEDIA_IPS`: 流媒体SNI IP列表，用逗号分隔

`OPENAI_IPS`: 可选，OPENAI IP列表

`ANTHROPIC_IPS`: 可选，Claude IP列表

`TEST_INTERVAL`: IP可用性测试间隔，默认60