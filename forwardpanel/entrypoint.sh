#!/bin/sh

if [ ! -f /data/forward_db.mv.db ]; then
  mv -f /app/forward_db.mv.db /data/forward_db.mv.db
fi

if [ ! -f /data/forward_db.trace.db ]; then
  mv -f /app/forward_db.trace.db /data/forward_db.trace.db
fi

echo "默认账号：admin，默认密码：XIAOLIzz123"

/usr/bin/java -jar /app/app.jar