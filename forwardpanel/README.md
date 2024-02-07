## 介绍

基于`beginner202010/forwordpanel:1.0.7-SNAPSHOT`做出以下修改

1. 修改数据目录到`/data`，方便持久化
2. 修改`ssh-key`的目录为：`/config/id_rsa`
3. 默认账号：admin/XIAOLIzz123

## docker compose

```
version: '3'

services:
  forwardpanel:
    image: monlor/forwardpanel:latest
    container_name: forwardpanel
    volumes:
      - forwardpanel:/data
      - ~/.ssh/id_rsa:/config/id_rsa
    ports:
      - "8080:8080"
    restart: unless-stopped

volumes:
  forwardpanel:
```