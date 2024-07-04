## 介绍

xboard，基于v2board二次开发

## 部署

```bash
# sqlite
docker run -d --name xboard -p 7001:7001 -e DB_TYPE=sqlite -v your_data:/www/.docker/.data/ monlor/xboard

# mysql
docker run -d --name xboard \
  -p 7001:7001 \
  -e DB_TYPE=mysql \
  -e DB_HOST=mysql \
  -e DB_PORT=3306 \
  -e DB_DATABASE=xboard \
  -e DB_USERNAME=xboard \
  -e DB_PASSWORD=xboard \
  -e REDIS_HOST=redis \
  -e REDIS_PASSWORD=xx \
  -e REDIS_PORT=6379 \
  monlor/xboard
```

初始化配置

```bash
docker exec -it xboard php artisan xboard:install
```

重启

```bash
docker restart xboard
```

## 参考

https://github.com/cedar2025/Xboard/blob/dev/docs/docker-compose%E5%AE%89%E8%A3%85%E6%8C%87%E5%8D%97.md