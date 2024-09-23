#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

#获取当前路径
path=$PWD
#当前文件路径
filePath=$PWD
#代理地址
proxyURL='http://ghb.jdmk.xyz:1888/'
proxyURL2='https://mirror.ghproxy.com/'
# 是否使用自定义加速镜像
echo -e "\n   ${yellow}是否使用自定义加速镜像用于全局加速？(已内置${proxyURL})${plain}"
echo "   1) 国内主机，需要使用"
echo "   2) 国外主机或使用内置加速镜像，不需要"
echo -ne "\n你的选择："
read  is_speed
case $is_speed in
   1) echo "加速模式启用中。。。"
        echo -e "\n   ${yellow}请输入您的自定义加速镜像，格式如：${proxyURL}，请注意后面的斜杆/${plain}"
        read  proxyURLTemp
        if  [ ! -n "${proxyURLTemp}" ] ;then
            echo -e "${yellow}使用默认加速镜像：${proxyURL}${plain}"
        else
            proxyURL=${proxyURLTemp}
            echo -e "${yellow}使用自定义加速镜像：${proxyURL}${plain}"
        fi
   ;;
   2) echo "你选择了国外主机或使用内置加速镜像,不需要设置"
      proxyURL=""
   ;;
esac

#检测是否需要重启jd_cookie容器
check_restart_jd_cookie(){
    # 移除容器
    jd_cookie_id=$(docker ps | grep "jd_cookie" | awk '{print $1}')
    jd_cookie_id1=$(docker ps -a | grep "jd_cookie" | awk '{print $1}')
    if [ -n "$jd_cookie_id" ]; then
      docker rm -f $jd_cookie_id
    else if [ -n "$jd_cookie_id1" ]; then
      docker rm -f $jd_cookie_id1
      fi
    fi
    #未启动时，需要启动
    start_jd_cookie
}

#检测是否已下载静态文件statics
check_statics(){
    if [ ! -d "${filePath}/jd_cookie/statics" ]; then
      cd ${filePath}
      mkdir -p jd_cookie && cd jd_cookie || exit
      echo -e "[INFO] 检测到当前不存在静态文件夹statics，即将下载文件"
      echo -e "${yellow}开始下载文件，下载地址：${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/statics.tar.gz${plain}";
      wget -O ${filePath}/jd_cookie/statics.tar.gz  --no-check-certificate ${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/statics.tar.gz

      if [ $? -ne 0 ]; then
        echo -e "[Error] 下载静态文件失败，请检查网络或重新执行本脚本" && exit 2
      fi
      tar -zxvf statics.tar.gz  >/dev/null 2>&1 && rm -rf statics.tar.gz
      echo -e "[SUCCESS] statics下载静态成功"
    fi
}

#检测是否安装redis
check_redis(){
    #判断是否已安装redis镜像
    redis_id=$(docker ps | grep "redis" | awk '{print $1}')
    redis_id1=$(docker ps -a | grep "redis" | awk '{print $1}')
    if [ -n "$redis_id" ]; then
      #docker rm -f $redis_id
      echo -e "${yellow}检测到已安装redis镜像，跳过安装redis镜像过程${plain}"
      docker restart $redis_id
    elif [ -n "$redis_id1" ]; then
      #docker rm -f $redis_id1
      echo -e "${green}检测到已安装redis镜像，跳过安装redis镜像过程${plain}"
      docker restart $redis_id1
    else
      if netstat -tuln | grep -q ":6379"; then
        echo -e "${yellow}当前端口 6379 已被占用.可能已安装了redis${plain}"
      else
        echo -e "${yellow}检测到还未安装redis镜像，本项目依赖redis数据库，是否安装redis镜像${plain}";
      fi
      echo "   1) 安装redis"
      echo "   0) 退出整个脚本安装程序"
      read input
      case $input in
            0)	echo -e "${yellow}退出脚本程序${plain}";exit 1 ;;
            1)	echo -e "${yellow}正在拉取安装redis脚本${plain}";
                wget -O redis_install.sh  --no-check-certificate ${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/redis_install.sh >/dev/null 2>&1
                chmod +x *sh
                bash redis_install.sh
            ;;
      esac
    fi
}

start_jd_cookie(){
        cd "${filePath}/jd_cookie" || exit
        # 更新镜像
        echo -e "\n${yellow}更新最新镜像中...${plain}"
        docker pull yuanter/jd_cookie:latest

        #使用模式
        num=""
        echo -e "\n${yellow}请输入数字选择启动容器模式（选择对应配置文件时选的模式）：${plain}"
        echo "   1) 使用关联redis模式启动，请保证redis端口为6379(云服务器一般推荐使用该模式，其他如群晖系统等少部分用户不可用)"
        echo "   2) 以通用模式启动"
        echo "   0) 退出"
        echo -ne "\n你的选择："
        read param
        num=$param
        case $param in
            0) echo -e "${yellow}退出脚本程序${plain}";exit 1 ;;
            1) echo -e "${yellow}使用关联redis模式启动容器，请保证redis端口为6379${plain}"; echo -e "\n"
               read -r -p "请确定启动容器的前提是redis是使用本脚本安装的容器且redis端口为6379，同时和jd_cookie容器在同一个主机? [y/n]: " link_input
               case $link_input in
                 [yY][eE][sS]|[yY]) ;;
        		 [nN][oO]|[nN]) exit 1 ;;
        		 esac
        		;;
            2) echo -e "${yellow}以通用模式启动容器${plain}"; echo -e "\n";;
        esac

        #启动容器
        if  [ $num -eq 1 ];then
        	docker run -d --privileged=true --restart=always  --name jd_cookie --ulimit core=0 -p 1170:1170  -v ${filePath}/jd_cookie:/root/jd_cookie --link redis:redis yuanter/jd_cookie
            echo -e "${yellow}使用关联redis模式启动成功${plain}"
        else if [ $num -eq 2 ];then
        	docker run -d --privileged=true --restart=always  --name jd_cookie --ulimit core=0 -p 1170:1170  -v ${filePath}/jd_cookie:/root/jd_cookie yuanter/jd_cookie
            echo -e "${yellow}以通用模式启动成功${plain}"
        	fi
        fi
}



#判断是否已经下载application.yml
check_yml(){
    echo -e "${yellow}检测application.yml配置文件中...${plain}\n"
    if [ ! -f "${filePath}/jd_cookie/application.yml" ]; then
        echo -e "${yellow}检测到application.yml配置文件不存在，开始下载一份示例文件用于初始化...${plain}\n"
        echo -e "${yellow}开始下载application.yml配置文件，下载地址：${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/application.yml${plain}";
        wget -O ${filePath}/jd_cookie/application.yml  --no-check-certificate ${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/application.yml >/dev/null 2>&1
        echo -e "${yellow}当前新下载的application.yml文件所在路径为：${filePath}/jd_cookie${plain}"

        #跳转至application.yml文件夹下
        cd ${filePath}/jd_cookie
        echo -e "application.yml文件所在路径为：${filePath}/jd_cookie"

        # 替换脚本内容
        echo -e "\n   ${yellow}开始配置启动文件：${plain}"
        # 配置host
        echo -e "   ${yellow}设置redis的连接地址host: ${plain}"
        echo "   1) host默认关联redis启动，请保证redis端口为6379（建议云服务器之类的主机选择此项,如Centos、Debian、Ubuntu系统）"
        echo "   2) 通用模式（host使用内网或者公网ip亦或者域名，建议N1或者群晖等系统选择此项,当使用公网时，请放行redis使用的公网端口）"
        echo "   0) 退出"
        echo -ne "\n你的选择: "
        read host
        case $host in
            0)	echo -e "${yellow}退出脚本程序${plain}";exit 1 ;;
            1)	echo -e "${yellow}host默认关联redis启动，请保证redis端口为6379${plain}";
                grep -rnl 'host:'  ${filePath}/jd_cookie/application.yml | xargs sed -i -r "s/host:.*$/host: redis/g" >/dev/null 2>&1
                echo -e "\n";;
            2)	echo -e "${yellow}通用模式（host使用内网或者公网ip亦或者域名。当使用公网ip时，请放行redis使用的公网端口）${plain}"; echo -e "\n"
                read -r -p "请输入ip或者域名：" url
                if  [ ! -n "${url}" ] ;then
                    #url=$(curl -Ls ifconfig.me)
                    echo -e "${red}未输入ip地址，退出程序${plain}"
                    #删掉配置文件
                    rm -rf ${filePath}/jd_cookie/application.yml
                    exit 1
                fi
                grep -rnl 'host:'  ${filePath}/jd_cookie/application.yml | xargs sed -i -r "s/host:.*$/host: $url/g" >/dev/null 2>&1
            ;;
        esac
        # 配置密码
        echo -e "${yellow}配置本程序连接redis的密码: ${plain}"
        read -r -p "请输入你之前设置的redis密码（必填）：" password
        grep -rnl 'password:'  ${filePath}/jd_cookie/application.yml | xargs sed -i -r "s/password:.*$/password: $password/g" >/dev/null 2>&1
        # 配置端口
        echo -e "${yellow}配置连接redis的端口（当使用关联redis模式启动时，请使用6379端口）${plain}"
        echo -e "${yellow}请输入你之前设置的redis端口(建议使用6379，回车默认6379)：${plain}"
        read port
        if  [ ! -n "${port}" ] ;then
            port=6379;
            echo -e "${yellow}未输入端口，使用默认端口6379${plain}"
        fi
        grep -rnl 'port: '  ${filePath}/jd_cookie/application.yml | xargs sed -i -r "s/port: [^port: 1170].*$/port: $port/g" >/dev/null 2>&1

    fi
}


#检测是否已经有app.jar文件
check_jar(){
    #检测app.jar
    if [ ! -f "${filePath}/jd_cookie/app.jar" ]; then
       echo -e "[INFO] 检测到当前不存在jar文件，即将下载文件"
       cd ${filePath}/jd_cookie || exit
       echo -e "${yellow}开始下载文件，下载地址：${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/app.jar${plain}";
       wget -O ${filePath}/jd_cookie/app.jar --timeout=30 --tries=5 --no-check-certificate ${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/app.jar || wget -O ${filePath}/jd_cookie/app.jar --timeout=30 --tries=5 --no-check-certificate ${proxyURL2}https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/app.jar

       if [ $? -ne 0 ]; then
         echo -e "[Error] 下载app.jar文件失败，请检查网络或重新执行本脚本" && exit 2
       fi
    fi
}

#升级app.jar文件
update_jar(){
    echo -e "[INFO] 当前已安装jd_cookie，检测到有新版本，即将下载更新文件"
    echo -e "${yellow}开始下载文件，下载地址：${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/app.jar${plain}";
    wget -O ${filePath}/jd_cookie/app.jar --timeout=30 --tries=5 --no-check-certificate ${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/app.jar || wget -O ${filePath}/jd_cookie/app.jar --timeout=30 --tries=5 --no-check-certificate ${proxyURL2}https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/app.jar

    if [ $? -ne 0 ]; then
      echo -e "[Error] 下载文件失败，请检查网络或重新执行本脚本"  && exit 2
    fi
}


check_install() {
    #检测静态文件
    check_statics
    #检测app.jar
    check_jar
    #检测是否安装redis
    check_redis
    #检测application.yml文件
    check_yml
    #启动容器
    check_restart_jd_cookie
}

update_soft() {
  if [ -d "${filePath}/jd_cookie" ]; then
    cd "${filePath}/jd_cookie" || exit
    #升级app.jar文件
    update_jar
    #检测是否有静态文件
    check_statics
    #检测是否安装启动了redis
    check_redis
    #检测是否已经有配置文件
    check_yml
    #启动jd_cookie
    check_restart_jd_cookie
    echo -e "[SUCCESS] 更新jd_cookie文件成功，程序正在启动中。。。"
  fi
}

check_update() {
  new_version=$(curl -Ls "${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/version")
  echo -e "[SUCCESS] 当前最新版本为：$(date -d @$((new_version/1000)) '+%Y-%m-%d %H:%M:%S')"
  if [ -d "${filePath}/jd_cookie" ]; then
    cd ${filePath}/jd_cookie || exit
    if [ ! -f ${filePath}/jd_cookie/version ]; then
        touch ${filePath}/jd_cookie/version
        echo "19700101" >> ${filePath}/jd_cookie/version
    fi
    old_version=$(cat version)
    if version_gt "${new_version}" "${old_version}"; then
      #检测更新
      update_soft
      #成功后下载version文件到本地
      wget -O ${filePath}/jd_cookie/version  --no-check-certificate ${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/version  >/dev/null 2>&1
    else
     #检测是否已经下载静态文件
     check_statics
     #检测是否安装redis
     check_redis
     #检测是否已经有配置文件
     check_yml
     #检测是否已经有app.jar文件
     check_jar
     #启动jd_cookie
     cd ${filePath}/jd_cookie && check_restart_jd_cookie
     echo  -e "${yellow}当前没有需要升级的版本${plain}"
    fi
  else
    check_install
    #成功后下载version文件到本地
    wget -O ${filePath}/jd_cookie/version  --no-check-certificate ${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/version  >/dev/null 2>&1
  fi
}

version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }





main() {
  # 一键脚本
  echo -e "\n   ${yellow}欢迎使用jd_cookie一键脚本：${plain}"

  #检测是否存在文件 && 下载更新文件
  check_update

  #删除脚本
  if [ -f "${filePath}/jd_cookie.sh" ]; then
  	rm -rf ${filePath}/jd_cookie.sh
  	echo  -e "${yellow}删除当前脚本文件成功${plain}"
  fi

  echo  -e "${yellow}jd_cookie启动成功${plain}"
  ip_url=$(curl -Ls ifconfig.me)
  echo  -e "${yellow}查看日志请在终端输入：docker logs -f --tail 100 jd_cookie${plain}"
  echo  -e "${yellow}有公网ip请网页打开本项目地址：http://$ip_url:1170${plain}"
  echo  -e "${yellow}无公网ip请使用内网或者本地ip127.0.0.1替换上方ip${ip_url}${plain}"
}

main