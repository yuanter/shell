#!/bin/sh

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

echo -e "${yellow}开始安装jd_cookie${plain}"; echo -e "\n"


#获取当前路径
path=$PWD
#当前文件路径
filePath=$PWD
mkdir -p  jd_cookie

#代理地址
proxyURL='http://ghb.jdmk.xyz:1888/'
proxyURL2=''
# 是否使用自定义加速镜像
echo -e "\n   ${yellow}是否使用自定义加速镜像用于全局加速（已内置http://ghb.jdmk.xyz:1888/）？${plain}"
echo "   1) 国内主机，需要使用"
echo "   2) 国外主机或使用内置加速镜像，不需要"
echo -ne "\n你的选择："
read  is_speed
case $is_speed in
   1) echo "加速模式启用中。。。"
        echo -e "\n   ${yellow}请输入您的自定义加速镜像，格式如：http://ghb.jdmk.xyz:1888/，请注意后面的斜杆/${plain}"
        read  proxyURLTemp
        if  [ ! -n "${proxyURLTemp}" ] ;then
            echo -e "${yellow}使用默认加速镜像${proxyURL}${plain}"
        else
            proxyURL=$is_speed
            echo -e "${yellow}使用自定义加速镜像${proxyURL}${plain}"
        fi
   ;;
   2) echo "你选择了国外主机或使用内置加速镜像,不需要设置"
   ;;
esac

#判断是否已安装redis镜像
id=$(docker ps | grep "redis" | awk '{print $1}')
id1=$(docker ps -a | grep "redis" | awk '{print $1}')
if [ -n "$id" ]; then
  #docker rm -f $id
  echo -e "${yellow}检测到已安装redis镜像，跳过安装redis镜像过程${plain}"
elif [ -n "$id1" ]; then
  #docker rm -f $id1
  echo -e "${yellow}检测到已安装redis镜像，跳过安装redis镜像过程${plain}"
else
  echo -e "${yellow}检测到还未安装redis镜像，本项目依赖redis数据库，是否安装redis镜像${plain}";
  echo "   1) 安装redis"
  echo "   0) 退出整个脚本安装程序"
  read input
  case $input in
        0)	echo -e "${yellow}退出脚本程序${plain}";exit 1 ;;
        1)	echo -e "${yellow}正在拉取安装redis脚本${plain}";
            echo -e "${yellow}下载脚本模式${plain}";
            echo "   1) 国内模式，启用加速"
            echo "   2) 国外模式，不加速"
            echo -ne "\n你的选择："
            read  is_speed_two
            case $is_speed_two in
                1) 	echo "国内模式下载安装脚本中。。。"
                    wget -O redis_install.sh  --no-check-certificate ${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/redis_install.sh
                    chmod +x *sh
                    bash redis_install.sh
                ;;
                2) 	echo "国外模式下载安装脚本中。。。"
                    wget -O redis_install.sh  --no-check-certificate https://raw.githubusercontent.com/yuanter/shell/main/redis_install.sh;
                    chmod +x *sh
                    bash redis_install.sh
                ;;
            esac
        ;;
  esac
fi



# 先自行判断路径是否有配置文件跳
echo -e "${yellow}检测application.yml配置文件中...${plain}\n"
if [ ! -f "/root/jd_cookie/application.yml" ]; then
	if [ ! -f "$path/application.yml" ]; then
		if [ ! -f "$path/jd_cookie/application.yml" ]; then
			echo -e "${yellow}检测到application.yml配置文件不存在，开始下载一份示例文件用于初始化...${plain}\n"
			echo -e "${yellow}下载配置文件application.yml模式${plain}";
            echo "   1) 国内模式，启用加速下载"
            echo "   2) 国外模式，不加速"
            echo -ne "\n你的选择："
            read  is_speed_yml_file
            case $is_speed_yml_file in
                1) 	echo "国内模式下载配置文件application.yml中。。。"
                    wget -O $path/jd_cookie/application.yml  --no-check-certificate ${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/application.yml
                    echo -e "${yellow}当前新下载的application.yml文件所在路径为：$path/jd_cookie${plain}"
                    path=$path/jd_cookie
                ;;
                2) 	echo "国外模式下载配置文件application.yml中。。。"
                    wget -O $path/jd_cookie/application.yml  --no-check-certificate https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/application.yml
                    echo -e "${yellow}当前新下载的application.yml文件所在路径为：$path/jd_cookie${plain}"
                    path=$path/jd_cookie
                ;;
            esac

		else
			path=$path/jd_cookie
		fi
	fi
else
	path="/root/jd_cookie";
fi

#跳转至application.yml文件夹下
cd $path
echo -e "application.yml文件所在路径为：$path"


# 替换脚本内容
echo -e "\n   ${yellow}开始配置启动文件：${plain}"
# 配置host
echo -e "   ${yellow}设置redis的连接地址host: ${plain}"
echo "   1) host使用默认redis"
echo "   2) host使用ip或者域名（当使用公网时，请放行redis使用的公网端口）"
echo "   0) 退出"
echo -ne "\n你的选择: "
read host
case $host in
    0)	echo -e "${yellow}退出脚本程序${plain}";exit 1 ;;
    1)	echo -e "${yellow}host使用默认redis${plain}"; 
		grep -rnl 'host:'  $path/application.yml | xargs sed -i -r "s/host:.*$/host: redis/g" >/dev/null 2>&1
		echo -e "\n";;
    2)	echo -e "${yellow}host使用ip或者域名（当使用公网时，请放行redis使用的公网端口）${plain}"; echo -e "\n"
		read -r -p "请输入ip或者域名：" url
		if  [ ! -n "${url}" ] ;then
			#url=$(curl -Ls ifconfig.me)
			echo -e "${red}未输入ip地址，退出程序${plain}"
			exit 1 
		fi
		grep -rnl 'host:'  $path/application.yml | xargs sed -i -r "s/host:.*$/host: $url/g" >/dev/null 2>&1
	;;
esac
# 配置密码
echo -e "\n${yellow}设置redis的密码(默认为空): ${plain}"
read -r -p "请输入启动redis时设置的密码，不带特殊字符：" password
grep -rnl 'password:'  $path/application.yml | xargs sed -i -r "s/password:.*$/password: $password/g" >/dev/null 2>&1
# 配置端口
echo -e "\n${yellow}设置redis的端口(回车默认6379，当使用--link模式启动时，请使用6379端口)${plain}"
echo -e "${yellow}请输入端口(建议使用6379)：${plain}"
read port
if  [ ! -n "${port}" ] ;then
	port=6379;
	echo -e "${yellow}未输入端口，使用默认端口6379${plain}"
fi
grep -rnl 'port: '  $path/application.yml | xargs sed -i -r "s/port: [^port: 1170].*$/port: $port/g" >/dev/null 2>&1



# 移除容器
id=$(docker ps | grep "jd_cookie" | awk '{print $1}')
id1=$(docker ps -a | grep "jd_cookie" | awk '{print $1}')
if [ -n "$id" ]; then
  docker rm -f $id
else if [ -n "$id1" ]; then
  docker rm -f $id1
  fi
fi


# 更新镜像
echo -e "\n${yellow}更新最新镜像中...${plain}"
docker pull yuanter/jd_cookie:latest



#使用模式
num=""

echo -e "\n${yellow}请输入数字选择启动脚本模式：${plain}"
echo "   1) 使用--link模式(redis容器和jd_cookie容器在同一主机，符合条件推荐使用该模式)启动"
echo "   2) 以普通模式启动"
echo "   0) 退出"
echo -ne "\n你的选择："
read param
num=$param
case $param in
    0) echo -e "${yellow}退出脚本程序${plain}";exit 1 ;;
    1) echo -e "${yellow}使用--link模式启动脚本${plain}"; echo -e "\n"
       read -r -p "请确定使用该脚本的前提是redis是使用本脚本安装的容器且redis端口为6379，同时和jd_cookie容器在同一个主机? [y/n]: " link_input
       case $link_input in
         [yY][eE][sS]|[yY]) ;;
		 [nN][oO]|[nN]) exit 1 ;;
		 esac
		;; 
    2) echo -e "${yellow}以普通模式启动脚本${plain}"; echo -e "\n";;
esac

#启动容器
if  [ $num -eq 1 ];then
	docker run -d --privileged=true --restart=always  --name jd_cookie -p 1170:1170  -v $path/application.yml:/application.yml --link redis:redis yuanter/jd_cookie
    echo -e "${yellow}使用--link模式启动成功${plain}"
else if [ $num -eq 2 ];then
	docker run -d --privileged=true --restart=always  --name jd_cookie -p 1170:1170  -v $path/application.yml:/application.yml yuanter/jd_cookie
    echo -e "${yellow}以普通模式启动成功${plain}"
	fi
fi

#删除脚本
if [ -f "$filePath/start_jd_cookie.sh" ]; then
	rm -rf $filePath/start_jd_cookie.sh
	echo  -e "${yellow}删除当前脚本文件成功${plain}"
fi

echo  -e "${green}jd_cookie启动成功${plain}"
ip_url=$(curl -Ls ifconfig.me)
echo  -e "${yellow}请网页打开本项目地址：http://$ip_url:1170${plain}"


