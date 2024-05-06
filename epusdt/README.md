## Docker Compose 部署

环境变量中有值的是存在默认值，可不配置，没有值的必须配置

```
version: "3"
services:
  epusdt:
    image: monlor/epusdt:latest
    container_name: epusdt
    environment:
      DOMAIN: 
      MYSQL_HOST:
      MYSQL_PORT: 3306
      MYSQL_USER: 
      MYSQL_PASSWD: 
      MYSQL_DB: 
      REDIS_HOST: 
      REDIS_PORT: 6379
      REDIS_PASSWD:
      REDIS_DB: 5
      QUEUE_CONCURRENCY: 10
      TG_BOT_TOKEN: 
      TG_PROXY: 
      TG_USER_ID: 
      API_TOKEN: 
      ORDER_EXPIRATION_TIME: 10
    restart: unless-stopped
    ports:
      - 8000:8000
```