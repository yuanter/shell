#!/bin/bash
function N01() {
yum install -y yum-utils device-mapper-persistent-data lvm2 >/dev/null 2>&1
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo >/dev/null 2>&1
yum makecache fast >/dev/null 2>&1
}
function N02() {
systemctl stop firewalld.service >/dev/null 2>&1
systemctl disable firewalld.service >/dev/null 2>&1
#yum -y install docker-ce >/dev/null 2>&1
curl -fsSL https://get.docker.com | bash -s docker  --mirror Aliyun
}
function N03() {
systemctl start docker.service >/dev/null 2>&1
systemctl enable docker.service >/dev/null 2>&1
cat>/etc/docker/daemon.json<<EOF
{
  "registry-mirrors": ["http://f1361db2.m.daocloud.io"]
}
EOF
systemctl daemon-reload >/dev/null 2>&1
systemctl restart docker.service >/dev/null 2>&1
}
function N04() {
curl -L "http://hub.jasas.eu.org/https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >/dev/null 2>&1
#curl -L "https://al.jiyunidc.com/file/6013c8f87c144d0044203e2c" -o /usr/local/bin/docker-compose >/dev/null 2>&1
chmod +x /usr/local/bin/docker-compose
}
function done1() {
clear
echo "==================================================================="
echo "Docker CE and Docker-compose 安装完成"
echo "===================================================================="
rm -rf docker-install.sh
exit;0
}
function menu() {
	clear
	echo
	echo -e "           欢迎使用          "
	k=1

	if [[ $k == 1 ]];then
	clear
	printf "\n[\033[34m 1/5 \033[0m]   正在处理环境\n";
	#N01
	printf "\n[\033[34m 2/5 \033[0m]   正在安装Docker CE\n";
	N02
	printf "\n[\033[34m 3/5 \033[0m]   正在启动Docker CE并且写入阿里云docker镜像源\n";
	N03
	printf "\n[\033[34m 4/5 \033[0m]   正在安装Docker-compose\n";
	N04
	printf "\n[\033[34m 5/5 \033[0m]   准备完成！\n";
    done1
	exit;0
	fi
}
function logo() {
clear
echo -e "\033[31m************************************************************************************************\033[0m"
echo -e "\033[31m  欢迎使用 Docker CE and Docker-compose 一键安装脚本（仅仅适用于中国大陆内网络环境）         \033[0m"
echo -e "\033[31m  最后更新时间："$lajitime"                     \033[0m"
echo -e "\033[31m  本脚本仅适用于学习与研究请勿用于任何违法国家法律的活动   \033[0m"
echo -e "\033[31m************************************************************************************************\033[0m"
echo
read -p "同意请按回车继续："
menu
}
function safe() {
if [ ! -e "/dev/net/tun" ]; then
    echo
    echo -e "\033[1;32m安装出错\033[0m \033[5;31m[原因：系统存在异常！]\033[0m 
	\033[1;32m错误码：\033[31mVFVOL1RBUOiZmuaLn+e9keWNoeS4jeWtmOWcqA== \033[0m\033[0m"
	exit 0;
fi
if [ ! -f /bin/mv ]; then
	echo
	echo "\033[1;31m\033[05m 警告！检测到非法系统环境，请管理员检查服务器或者重装系统后重试！错误码：bXbkuI3lrZjlnKg= \033[0m"
	exit;0
fi
if [ ! -f /bin/cp ]; then
	echo
	echo "\033[1;31m\033[05m 警告！检测到非法系统环境，请管理员检查服务器或者重装系统后重试！错误码：Y3DkuI3lrZjlnKg= \033[0m"
	exit;0
fi
if [ ! -f /bin/rm ]; then
	echo
	echo "\033[1;31m\033[05m 警告！检测到非法系统环境，请管理员检查服务器或者重装系统后重试！错误码：cm3kuI3lrZjlnKg= \033[0m"
	exit;0
fi
if [ ! -f /bin/ps ]; then
	echo
	echo "\033[1;31m\033[05m 警告！检测到非法系统环境，请管理员检查服务器或者重装系统后重试！错误码：cHPkuI3lrZjlnKg= \033[0m"
	exit;0
fi
if [ -f /etc/os-release ];then
centos_v=`cat /etc/os-release |awk -F'[="]+' '/^VERSION_ID=/ {print $2}'`
if [ $centos_v != "7" ];then
echo
echo "-bash: "$0": 对不起，系统环境异常，当前系统为：CentOS "$centos_v" ，请更换系统为 CentOS 7.0 - 7.9 后重试！"
exit 0;
fi
elif [ -f /etc/redhat-release ];then
centos_v=`cat /etc/redhat-release |grep -Eos '\b[0-9]+\S*\b' |cut -d'.' -f1`
if [ $centos_v != "7" ];then
echo
echo "-bash: "$0": 对不起，系统环境异常，当前系统为：CentOS "$centos_v" ，请更换系统为 CentOS 7.0 - 7.9后重试！"
exit 0;
fi
else
echo
echo "-bash: "$0": 对不起，系统环境异常，当前系统为：CentOS 未知 ，请更换系统为 CentOS 7.0 - 7.4 后重试！"
exit 0;
fi
}
function main() {
clear 
echo
echo "脚本开始运行"
sleep 2 
echo
echo "检查安装环境"
#safe
yum -y install curl >/dev/null 2>&1
lajitime=2023.12.16
logo
}
main
exit;0
