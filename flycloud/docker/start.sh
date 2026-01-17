#!/bin/bash

/sbin/init
sh /docker-entrypoint.sh
echo -e "开始监控flycloud进程日志"
tail -f /var/log/app.log