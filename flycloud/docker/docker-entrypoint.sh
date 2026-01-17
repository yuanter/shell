#!/bin/bash


version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }



#移动之前需要的文件
chmod -R 777 /root/flycloud
# 定义应用程序文件路径
APP_JAR="/root/flycloud/app.jar"

cd /root/flycloud
chmod u+x /root/flycloud/app.jar

# 设置文件路径
file_path="/var/log/app.log"
# 判断文件是否存在
if [ ! -f "$file_path" ]; then
    # 文件不存在，创建文件
    touch "$file_path"
fi

echo -e "正在查询最新版本中。。。"
# 定义版本，根据版本判断
new_version=$(curl -Ls --connect-timeout 60 "http://ghb.mkjt.xyz:1888/https://raw.githubusercontent.com/yuanter/shell/main/flycloud_beta/version" 2>/dev/null)
if [ -z "$new_version" ]; then
    new_version=$(curl -Ls --connect-timeout 60 "http://git.566646.xyz:12333/https://raw.githubusercontent.com/yuanter/shell/main/flycloud_beta/version" 2>/dev/null)
fi

new_version=$(echo "$new_version" | tr -d '\r' | tr -d '\n')  # 去掉回车和换行符
echo -e "[SUCCESS] 当前最新版本为：$(date -d @$((new_version / 1000)) '+%Y-%m-%d %H:%M:%S')"

PID=""
if [ -d "/root/flycloud" ]; then
	cd /root/flycloud || exit
	if [ ! -f /root/flycloud/version ]; then
		touch /root/flycloud/version
		echo "19700101" >> /root/flycloud/version
	fi
	old_version=$(cat version)
	if version_gt "${new_version}" "${old_version}"; then
		# 检测更新
		echo "发现新版本，开始更新..." 
		# 备份旧的应用程序
		mv /root/flycloud/app.jar /root/flycloud/app.jar.bak
		# 下载新的应用程序http://ghb.mkjt.xyz:1888/
		wget -O /root/flycloud/app.jar --timeout=60 --connect-timeout=60 --tries=3 --no-check-certificate http://ghb.mkjt.xyz:1888/https://raw.githubusercontent.com/yuanter/shell/main/flycloud_beta/app.jar > /var/log/app.log 2>&1 || wget -O /root/flycloud/app.jar --timeout=60 --connect-timeout=60 --tries=3 --no-check-certificate http://git.566646.xyz:12333/https://raw.githubusercontent.com/yuanter/shell/main/flycloud_beta/app.jar > /var/log/app.log 2>&1
		# 成功后下载version文件到本地
		wget -O /root/flycloud/version --timeout=60 --connect-timeout=60 --tries=3 --no-check-certificate http://ghb.mkjt.xyz:1888/https://raw.githubusercontent.com/yuanter/shell/main/flycloud_beta/version > /var/log/app.log 2>&1 || wget -O /root/flycloud/version --timeout=60 --connect-timeout=60 --tries=3 --no-check-certificate http://git.566646.xyz:12333/https://raw.githubusercontent.com/yuanter/shell/main/flycloud_beta/version > /var/log/app.log 2>&1
		echo "更新完成，重启应用程序中，请稍候..."
		# 停止应用程序
		PID=$(pgrep -f "java") && if [ -n "$PID" ]; then kill -9 $PID && echo "停止应用程序java..."; fi
	else
		echo "没有新版本，继续运行现有应用程序..."
	fi
else
	# 成功后下载version文件到本地
	wget -O /root/flycloud/version --timeout=60 --connect-timeout=60 --tries=3  --no-check-certificate http://ghb.mkjt.xyz:1888/https://raw.githubusercontent.com/yuanter/shell/main/flycloud_beta/version > /var/log/app.log 2>&1 || wget -O /root/flycloud/version --timeout=60 --connect-timeout=60 --tries=3  --no-check-certificate http://git.566646.xyz:12333/https://raw.githubusercontent.com/yuanter/shell/main/flycloud_beta/version > /var/log/app.log 2>&1
fi



if [ -z "$(pgrep -f "java")" ]; then
	echo -e "开始执行FlyCloud启动进程"
fi
nohup java -server -Xms64m -Xmx128m -Djava.security.egd=file:/dev/./urandom -jar -Dfile.encoding=UTF-8 /root/flycloud/app.jar > /var/log/app.log 2>&1 &