#!/bin/bash


function logo() {
clear
echo -e "\033[31m************************************************************************************\033[0m"
echo -e "\033[31m  欢迎使用 Docker x-ui 一键脚本（仅为了应用中国大陆内网络环境而制作）         \033[0m"
echo -e "\033[31m  最后更新时间："$lajitime"                     \033[0m"
echo -e "\033[31m  本脚本仅适用于学习与研究请勿用于任何违法国家法律的活动   \033[0m"
echo -e "\033[31m************************************************************************************\033[0m"
echo
read -p "同意请按回车继续："
menu
}

function menu() {
	clear
	echo
	echo -e "           欢迎使用          "
	k=1

	if [[ $k == 1 ]];then
	clear
	printf "\n[\033[34m 1/4 \033[0m]   正在关闭并卸载firewalld防火墙\n";
	N01
	printf "\n[\033[34m 2/4 \033[0m]   正在拉取Docker x-ui 镜像\n";
	N02
	printf "\n[\033[34m 3/4 \033[0m]   正在添加并启动容器\n";
	N03
	printf "\n[\033[34m 4/4 \033[0m]   准备完成！\n";
    done1
	exit;0
	fi
}

function N01() {
systemctl stop firewalld.service >/dev/null 2>&1
systemctl disable firewalld.service >/dev/null 2>&1
}

function N02() {
docker pull yuanter/x-ui:latest
}

function N03() {
docker rm -f x-ui
#docker run -d --name=x-ui  --log-opt max-size=10m --log-opt max-file=5 --network=host --restart=always yuanter/x-ui:latest
#docker run --restart=always --name x-ui -d -p 54321:54321 -p 8000-8010:8000-8010/tcp -p 8000-8010:8000-8010/udp --tmpfs /tmp --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v $PWD/x-ui-data:/etc/x-ui yuanter/x-ui:latest
docker run --restart=always --name x-ui -d  --network=host --tmpfs /tmp --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v $PWD/x-ui-data:/etc/x-ui yuanter/x-ui:latest
}

function done1() {
clear
echo "==================================================================="
echo "安装完成"
echo "容器名为：x-ui"
echo "X-UI菜单命令：docker exec -it x-ui x-ui"
echo "默认已经关闭firewalld防火墙，如是为了安全，请自行重新安装防火墙。"
echo "本系统基于Docker，如需更改啥啥啥的，自己玩 不懂Docker，玩坏就重装"
echo "重装一次不行就两次，两次不行就装三次。。。。。" 
echo "===================================================================="
rm -rf docker-x-ui.sh
exit;0
}


function main() {
clear 
echo
echo "脚本开始运行"
sleep 2 
lajitime=2022.7.15
logo
}
main
exit;0
