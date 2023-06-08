## 介绍

不用写配置文件，通过变量快速启动一套简单的frps服务端

## 使用方式

### 最简

frps服务端端口7000
http服务端口8080

```
docker run -d --name frps \
  -e AUTH_TOKEN=SUQAKTMb87 \
  -p 7000:7000 \
  -p 8080:8080 \
  --restart=unless-stopped \
  monlor/frps:latest
```

### 部署dashboard

frps服务端端口7000
http服务端口8080
dashboard默认用户admin，访问端口7500

```
docker run -d --name frps \
  -e DASHBOARD_PWD=7RFPyAXYxc \
  -e AUTH_TOKEN=SUQAKTMb87 \
  -p 7000:7000 \
  -p 7500:7500 \
  -p 8080:8080 \
  --restart=unless-stopped \
  monlor/frps:latest
```

### 完整配置

frps服务端端口7000
http服务端口8080
dashboard默认用户admin，访问端口7500

```
docker run -d --name frps \
  -e HTTP_PORT=8080 \
  -e DASHBOARD_PWD=7RFPyAXYxc \
  -e DASHBOARD_USER=admin \
  -e AUTH_TOKEN=SUQAKTMb87 \
  -e ALLOW_PORTS=2000-3000,3001,3003,4000-50000 \
  -p 7000:7000 \
  -p 7500:7500 \
  -p 8080:8080 \
  --restart=unless-stopped \
  monlor/frps:latest
```