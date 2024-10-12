# WebDAV备份工具

这个工具可以定期将指定的多个目录备份到WebDAV服务器。

## 功能

- 定时备份指定的多个目录
- 将备份文件上传到WebDAV服务器
- 可配置的备份间隔时间

## 使用方法

```bash
docker run -d \
  -e WEBDAV_URL="https://your-webdav-server.com/backup" \
  -e WEBDAV_USERNAME="your_username" \
  -e WEBDAV_PASSWORD="your_password" \
  -e WEBDAV_PATH="/backup" \
  -e BACKUP_DIRS="/path/to/dir1 /path/to/dir2" \
  -e BACKUP_INTERVAL="60" \
  -v /path/to/dir1:/path/to/dir1 \
  -v /path/to/dir2:/path/to/dir2 \
  monlor/webdav-backup
```

## 环境变量

- `WEBDAV_URL`: WebDAV服务器的URL
- `WEBDAV_USERNAME`: WebDAV服务器的用户名
- `WEBDAV_PASSWORD`: WebDAV服务器的密码
- `BACKUP_DIRS`: 要备份的目录,用空格分隔多个目录
- `BACKUP_INTERVAL`: 备份间隔时间(分钟),默认为60分钟

## 注意事项

- 确保WebDAV服务器有足够的存储空间
- 定期检查备份是否成功
- 考虑实现备份文件的轮换或清理机制,以防止WebDAV服务器存储空间耗尽

## 贡献

欢迎提交问题和拉取请求。

## 许可证

本项目采用MIT许可证。详情请参阅 [LICENSE](LICENSE) 文件。
