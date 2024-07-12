#!/bin/sh

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

echo -e "${yellow}开始安装redis容器中...${plain}"; echo -e "\n"

#获取当前路径
path=$PWD
#当前文件路径
filePath=$PWD

# 映射文件夹
if [ ! -d "${filePath}/redis" ]; then
    mkdir -p ${filePath}/redis/data
fi

# 移除容器
id=$(docker ps | grep "redis" | awk '{print $1}')
id1=$(docker ps -a | grep "redis" | awk '{print $1}')
if [ -n "$id" ]; then
  docker rm -f $id
else if [ -n "$id1" ]; then
  docker rm -f $id1
  fi
fi


# 安装redis镜像
echo -e "${yellow}正在拉取redis容器中...${plain}\n";
docker pull redis
echo -e "${yellow}请输入redis密码(不要设置简单且带特殊字符密码)：${plain}";
read  psw
if  [ ! -n "${psw}" ] ;then
    echo -e "${yellow}叼毛，redis一定要设置密码,再给你一次机会，重新输入密码${plain}\n"
    read  psw
    if  [ ! -n "${psw}" ] ;then
        psw=$(</dev/urandom tr -dc '1234567890qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c16)
        echo -e "你个叼毛，都说让你重新输密码了。现在系统自动给你生成了一个新密码，记好了，密码是${yellow}$psw${plain}"
    fi
fi

echo -e "${yellow}请输入redis的端口(建议使用6379，回车默认6379)：${plain}";
read  port
if  [ ! -n "${port}" ] ;then
    port=6379;
    echo -e "${yellow}redis使用默认端口6379${plain}"
fi

if netstat -tuln | grep -q ":$port"; then
    echo "当前端口 ${port} 已被占用，请重新更换端口"
    read  port
fi

if  [ ! -n "${port}" ] ;then
    port=6379;
    echo -e "${yellow}redis使用默认端口6379${plain}"
fi

if netstat -tuln | grep -q ":$port"; then
    echo "当前端口 ${port} 已被占用."
    echo -e "${red}退出redis安装程序${plain}"
    exit 1
fi


if  [ "$psw" == "" ];then
    docker run --privileged=true  --restart=always --name redis -v ${filePath}/redis/data:/data -p $port:6379 -d redis redis-server --appendonly yes
else
    docker run --privileged=true --restart=always --name redis -v ${filePath}/redis/data:/data -p $port:6379 -d redis redis-server --appendonly yes --requirepass "$psw"
fi

#删除脚本
if [ -f "$filePath/redis_install.sh" ]; then
	rm -rf $filePath/redis_install.sh
	echo  -e "${green}删除当前脚本文件成功${plain}"
fi


echo -e "${yellow}redis启动成功${plain}"
echo -e "${yellow}请牢记，redis端口（记得开放防火墙端口）为：${port}\n密码：$psw${plain}"
echo -e "\n"







