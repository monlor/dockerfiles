## 介绍

搭建一个sniproxy服务

## 部署

```
docker run -d --name sniproxy -p 80:80 -p 443:443 monlor/sniproxy
```