## 介绍

web版本的scrapy，用于安卓远程控制，适配arm64/amd64

## 部署

```bash
docker run -d --name ws-scrcpy -p 8000:8000 -e ADB_ADDRESS=xx monlor/ws-scrcpy
```

## 环境变量

`ADB_ADDRESS`: adb连接地址，支持多个，格式：xxx.com:5555,aaa.com:5555

`TIMEOUT`: adb地址连接超时时间，默认60s

# 参考

https://github.com/scavin/ws-scrcpy-docker