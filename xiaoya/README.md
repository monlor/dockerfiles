## 小雅影视库

简化部署逻辑，来源：https://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f

## 启动命令

```
docker run -d -p 5678:80 -p 2345:2345 -p 2346:2346 --restart=unless-stopped --name=xiaoya monlor/xiaoya:latest
```

## 环境变量

`ALIYUN_TOKEN`: 阿里云token https://alist.nn.ci/zh/guide/drivers/aliyundrive.html 

`ALIYUN_OPEN_TOKEN`: 阿里云 open-token https://alist.nn.ci/zh/guide/drivers/aliyundrive_open.html

`ALIYUN_FOLDER_ID`: 阿里云小雅文件夹id，转存以下文件到你的云盘，获取文件夹id，共享链接：https://www.aliyundrive.com/s/rP9gP3h9asE

`CRONTAB_ENABLE`: 是否开启定时更新数据的任务，true/false
