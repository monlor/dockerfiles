# WebDAV备份工具

这个工具可以定期将指定的目录备份到WebDAV服务器，并提供恢复功能。

## 功能

- 定时备份指定的目录
- 将备份文件上传到WebDAV服务器
- 可配置的备份间隔时间
- 支持大文件拆分
- 从WebDAV服务器恢复指定的备份文件
- 支持 Telegram 通知（启动时和备份失败时）
- 可自定义备份任务名称

## 使用方法

### 备份

```bash
docker run -d \
  -e WEBDAV_URL="https://your-webdav-server.com/backup" \
  -e WEBDAV_USERNAME="your_username" \
  -e WEBDAV_PASSWORD="your_password" \
  -v /path/to/data:/data \
  monlor/webdav-backup
```

### 恢复

要恢复备份，请按照以下步骤操作：

1. 确保备份容器正在运行。如果没有运行，请使用上面的命令启动它。

2. 进入运行中的容器：

```bash
docker exec -it <container_id_or_name> /bin/bash
```

3. 在容器内执行恢复脚本：

```bash
/restore.sh
```

4. 按提示输入要恢复的备份文件名。格式可以是：
   - `backup_YYYYMMDD_HHMMSS.tar.gz`（未拆分的备份文件）
   - `backup_YYYYMMDD_HHMMSS.tar.gz.txt`（拆分备份文件的列表）

5. 确认恢复操作，等待恢复完成。

## 环境变量

- `WEBDAV_URL`: WebDAV服务器的URL（必需）, 格式为 https://your-webdav-server.com/dav
- `WEBDAV_USERNAME`: WebDAV服务器的用户名（必需）
- `WEBDAV_PASSWORD`: WebDAV服务器的密码（必需）
- `WEBDAV_PATH`: WebDAV服务器上的备份路径，默认为空，格式为 /backup
- `BACKUP_DIRS`: 要备份的目录，用空格分隔多个目录，默认为 "/data"
- `BACKUP_INTERVAL`: 备份间隔时间(分钟)，默认为60分钟
- `BACKUP_TASK_NAME`: 备份任务的名称，默认为 "默认备份任务"
- `BACKUP_SPLIT_SIZE`: 备份文件拆分大小（可选）。格式为数字后跟可选的单位后缀（b, k, m, g, t）。例如：100M, 1G, 500K。如果不设置，备份文件将不会被拆分。
- `TELEGRAM_BOT_TOKEN`: Telegram Bot 的 token（可选）
- `TELEGRAM_CHAT_ID`: 接收 Telegram 通知的聊天 ID（可选）

## 注意事项

- 确保WebDAV服务器有足够的存储空间
- 定期检查备份是否成功
- 考虑实现备份文件的轮换或清理机制，以防止WebDAV服务器存储空间耗尽
- 恢复操作会覆盖目标目录中的现有数据，请谨慎操作
- 在执行恢复操作之前，请确保您有足够的权限访问和修改目标目录
- 如果配置了 Telegram 通知，程序会在启动时发送一条包含所有重要参数的通知消息
- 如果配置了 Telegram 通知，只有在备份失败时才会发送额外的通知
- 当使用 `BACKUP_SPLIT_SIZE` 时，备份文件会被拆分成多个部分，并创建一个同名的 .txt 文件列表
- 恢复时，可以使用 .tar.gz 文件名（未拆分）或 .tar.gz.txt 文件名（拆分文件列表）

## 贡献

欢迎提交问题和拉取请求。

## 许可证

本项目采用MIT许可证。详情请参阅 [LICENSE](LICENSE) 文件。
