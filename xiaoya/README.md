## 小雅影视库

简化部署逻辑，来源：https://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f

## 使用

```
docker run -d -v your_media:/opt/media -v your_data:/etc/xiaoya -p 5678:80 -p 2345:2345 -p 2346:2346 --restart=unless-stopped --name=xiaoya monlor/xiaoya:latest
```

进入容器执行命令，开始安装

```
xiaoya.sh
```

## 参考

https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/all_in_one.sh