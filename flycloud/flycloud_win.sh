#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

#当前文件路径(默认安装在C盘)
filePath=C:\\Docker
if [ ! -d "${filePath}" ]; then
    mkdir -p ${filePath}
fi

#获取当前路径
path=$PWD

#判断是否已安装wget
if ! command wget -V >/dev/null 2>&1;  then
   echo -e "${red}检测到系统未安装wget，请先安装wget！${plain}\n" && exit 1
fi



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
            echo -e "${yellow}使用默认加速镜像：${proxyURL}${plain}"
        else
            proxyURL=${proxyURLTemp}
            echo -e "${yellow}使用自定义加速镜像：${proxyURL}${plain}"
        fi
   ;;
   2) echo "你选择了国外主机或使用内置加速镜像,不需要设置"
   ;;
esac


#判断是否还在运行jd_cookie
check_jd_cookie(){
    # 关闭容器
    jd_cookie_id=$(docker ps | grep "jd_cookie" | awk '{print $1}')
    jd_cookie_id1=$(docker ps -a | grep "jd_cookie" | awk '{print $1}')
    if [ -n "$jd_cookie_id" ]; then
      #docker rm -f $jd_cookie_id
      docker kill $jd_cookie_id
    else if [ -n "$jd_cookie_id1" ]; then
      #docker rm -f $jd_cookie_id1
      docker kill $jd_cookie_id1
      fi
    fi
}

#检测是否需要重启flycloud容器
check_restart_flycloud(){
    # 移除容器
    flycloud_id=$(docker ps | grep "flycloud" | awk '{print $1}')
    flycloud_id1=$(docker ps -a | grep "flycloud" | awk '{print $1}')
    if [ -n "$flycloud_id" ]; then
      docker rm -f $flycloud_id
    else if [ -n "$flycloud_id1" ]; then
      docker rm -f $flycloud_id1
      fi
    fi
    #未启动时，需要启动
    start_flycloud
}

#检测是否已下载静态文件statics
check_statics(){
    if [ ! -d "${filePath}\\flycloud\\statics" ]; then

      cd ${filePath}
      mkdir -p flycloud && cd flycloud || exit
      echo -e "[INFO] 检测到当前不存在静态文件夹statics，即将下载文件"
      echo -e "${yellow}下载文件模式${plain}";
      echo "   1) 国内模式，启用加速下载"
      echo "   2) 国外模式，不加速"
      echo -ne "\n你的选择："
      read  is_statics_file
      case $is_statics_file in
          1) 	echo "国内模式下载中。。。"
              wget -O ${filePath}\\flycloud\\statics.tar.gz  --no-check-certificate ${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/flycloud/statics.tar.gz
          ;;
          2) 	echo "国外模式下载中。。。"
              wget -O ${filePath}\\flycloud\\statics.tar.gz  --no-check-certificate https://raw.githubusercontent.com/yuanter/shell/main/flycloud/statics.tar.gz
          ;;
      esac

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
                echo -e "${yellow}下载脚本模式${plain}";
                echo "   1) 国内模式，启用加速"
                echo "   2) 国外模式，不加速"
                echo -ne "\n你的选择："
                read  is_speed_two
                case $is_speed_two in
                    1) 	echo "国内模式下载安装脚本中。。。"
                        wget -O redis_install.sh  --no-check-certificate {proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/redis_install.sh >/dev/null 2>&1
                        chmod +x *sh
                        bash redis_install.sh
                    ;;
                    2) 	echo "国外模式下载安装脚本中。。。"
                        wget -O redis_install.sh  --no-check-certificate https://raw.githubusercontent.com/yuanter/shell/main/redis_install.sh >/dev/null 2>&1
                        chmod +x *sh
                        bash redis_install.sh
                    ;;
                esac
            ;;
      esac
    fi
}

start_flycloud(){
        cd "${filePath}\\flycloud" || exit
        # 更新镜像
        echo -e "\n${yellow}更新最新镜像中...${plain}"
        docker pull yuanter/flycloud:latest

        #使用模式
        num=""
        echo -e "\n${yellow}请输入数字选择启动脚本模式：${plain}"
        echo "   1) 使用关联redis模式启动，请保证redis端口为6379(云服务器一般推荐使用该模式，其他系统如群晖，则不推荐使用)"
        echo "   2) 以普通模式启动"
        echo "   0) 退出"
        echo -ne "\n你的选择："
        read param
        num=$param
        case $param in
            0) echo -e "${yellow}退出脚本程序${plain}";exit 1 ;;
            1) echo -e "${yellow}使用关联redis模式启动脚本，请保证redis端口为6379${plain}"; echo -e "\n"
               read -r -p "请确定使用该脚本的前提是redis是使用本脚本安装的容器且redis端口为6379，同时和flycloud容器在同一个主机? [y/n]: " link_input
               case $link_input in
                 [yY][eE][sS]|[yY]) ;;
        		 [nN][oO]|[nN]) exit 1 ;;
        		 esac
        		;;
            2) echo -e "${yellow}以普通模式启动脚本${plain}"; echo -e "\n";;
        esac

        #启动容器
        if  [ $num -eq 1 ];then
            docker run -d --privileged=true --restart=always  --name flycloud --ulimit core=0 -p 1170:1170  -v ${filePath}\\flycloud:/root/flycloud --link redis:redis yuanter/flycloud
            echo -e "${yellow}使用关联redis模式启动成功${plain}"
        else if [ $num -eq 2 ];then
            docker run -d --privileged=true --restart=always  --name flycloud --ulimit core=0 -p 1170:1170  -v ${filePath}\\flycloud:/root/flycloud yuanter/flycloud
            echo -e "${yellow}以普通模式启动成功${plain}"
            fi
        fi
}



#判断是否已经下载application.yml
check_yml(){
    echo -e "${yellow}检测application.yml配置文件中...${plain}\n"
    if [ ! -f "${filePath}\\flycloud\\application.yml" ]; then
        echo -e "${yellow}检测到application.yml配置文件不存在，开始下载一份示例文件用于初始化...${plain}\n"
        echo -e "${yellow}下载配置文件application.yml模式${plain}";
        echo "   1) 国内模式，启用加速下载"
        echo "   2) 国外模式，不加速"
        echo -ne "\n你的选择："
        read  is_speed_yml_file
        case $is_speed_yml_file in
            1) 	echo "国内模式下载配置文件application.yml中。。。"
                wget -O ${filePath}\\flycloud\\application.yml  --no-check-certificate ${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/flycloud/application.yml >/dev/null 2>&1
                echo -e "${yellow}当前新下载的application.yml文件所在路径为：${filePath}\\flycloud${plain}"
            ;;
            2) 	echo "国外模式下载配置文件application.yml中。。。"
                wget -O ${filePath}\\flycloud\\application.yml  --no-check-certificate https://raw.githubusercontent.com/yuanter/shell/main/flycloud/application.yml >/dev/null 2>&1
                echo -e "${yellow}当前新下载的application.yml文件所在路径为：${filePath}\\flycloud${plain}"
            ;;
        esac

        #跳转至application.yml文件夹下
        cd ${filePath}\\flycloud
        echo -e "application.yml文件所在路径为：${filePath}\\flycloud"

        # 替换脚本内容
        echo -e "\n   ${yellow}开始配置启动文件：${plain}"
        # 配置host
        echo -e "   ${yellow}设置redis的连接地址host: ${plain}"
        echo "   1) host默认关联redis启动，请保证redis端口为6379"
        echo "   2) host使用ip或者域名（当使用公网时，请放行redis使用的公网端口）"
        echo "   0) 退出"
        echo -ne "\n你的选择: "
        read host
        case $host in
            0)	echo -e "${yellow}退出脚本程序${plain}";exit 1 ;;
            1)	echo -e "${yellow}host使用默认redis，请保证redis端口为6379${plain}";
                grep -rnl 'host:'  ${filePath}\\\\flycloud\\\\application.yml | xargs sed -i -r "s/host:.*$/host: redis/g" >/dev/null 2>&1
                echo -e "\n";;
            2)	echo -e "${yellow}host使用ip或者域名（当使用公网时，请放行redis使用的公网端口）${plain}"; echo -e "\n"
                read -r -p "请输入ip或者域名：" url
                if  [ ! -n "${url}" ] ;then
                    #url=$(curl -Ls ifconfig.me)
                    echo -e "${red}未输入ip地址，退出程序${plain}"
                    exit 1
                fi
                grep -rnl 'host:'  ${filePath}\\\\flycloud\\\\application.yml | xargs sed -i -r "s/host:.*$/host: $url/g" >/dev/null 2>&1
            ;;
        esac
        # 配置密码
        echo -e "${yellow}配置本程序连接redis的密码: ${plain}"
        read -r -p "请输入你之前设置的redis密码（必填）：" password
        grep -rnl 'password:'  ${filePath}\\\\flycloud\\\\application.yml | xargs sed -i -r "s/password:.*$/password: $password/g" >/dev/null 2>&1
        # 配置端口
        echo -e "${yellow}配置连接redis的端口（当使用关联redis模式启动时，请使用6379端口）${plain}"
        echo -e "${yellow}请输入你之前设置的redis端口(建议使用6379，回车默认6379)：${plain}"
        read port
        if  [ ! -n "${port}" ] ;then
            port=6379;
            echo -e "${yellow}未输入端口，使用默认端口6379${plain}"
        fi
        grep -rnl 'port: '  ${filePath}\\\\flycloud\\\\application.yml | xargs sed -i -r "s/port: [^port: 1170].*$/port: $port/g" >/dev/null 2>&1
        # 配置卡密
        echo -e "${yellow}设置授权token: ${plain}"
        read -r -p "请输入您的授权码：" token
        grep -rnl 'token:'  ${filePath}\\\\flycloud\\\\application.yml | xargs sed -i -r "s/token:.*$/token: $token/g" >/dev/null 2>&1
        # 授权地址
        #echo -e "${yellow}设置授权网址: ${plain}"
        #read -r -p "请输入您的授权网址：" url
        #grep -rnl 'url:'  ${filePath}\\\\flycloud\\\\application.yml | xargs sed -i -r "s/url:.*$/url: $url/g" >/dev/null 2>&1
    fi
}


check_install() {
    #检测静态文件
    check_statics

    #检测app.jar
    if [ ! -f "${filePath}\\flycloud\\app.jar" ]; then
       echo -e "[INFO] 检测到当前不存在jar文件，即将下载文件"
       cd ${filePath}\\flycloud || exit
       echo -e "${yellow}下载文件模式${plain}";
       echo "   1) 国内模式，启用加速下载"
       echo "   2) 国外模式，不加速"
       echo -ne "\n你的选择："
       read  is_jar_file
       case $is_jar_file in
            1) 	echo "国内模式下载中。。。"
                wget -O ${filePath}\\flycloud\\app.jar --timeout=60 --connect-timeout=60 --tries=3 --no-check-certificate ${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/flycloud/app.jar || wget -O ${filePath}\\flycloud\\app.jar --timeout=60 --connect-timeout=60 --tries=3 --no-check-certificate https://mirror.ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/flycloud/app.jar
            ;;
            2) 	echo "国外模式下载中。。。"
                wget -O ${filePath}\\flycloud\\app.jar  --no-check-certificate https://raw.githubusercontent.com/yuanter/shell/main/flycloud/app.jar
            ;;
       esac

       if [ $? -ne 0 ]; then
         echo -e "[Error] 下载app.jar文件失败，请检查网络或重新执行本脚本" && exit 2
       fi
    fi

    #检测旧版的jd_cookie是否还在运行，需关闭
    check_jd_cookie
    #检测是否安装redis
    check_redis
    #检测application.yml文件
    check_yml
    #启动容器
    check_restart_flycloud
}

update_soft() {
  if [ -d "${filePath}\\flycloud" ]; then
    cd "${filePath}\\flycloud" || exit
    echo -e "[INFO] 当前已安装flycloud，检测到有新版本，即将下载更新文件"
    echo -e "${yellow}下载文件模式${plain}";
    echo "   1) 国内模式，启用加速下载"
    echo "   2) 国外模式，不加速"
    echo -ne "\n你的选择："
    read  is_new_jar_file
    case $is_new_jar_file in
        1) 	echo "国内模式下载中。。。"
            wget -O ${filePath}\\flycloud\\app.jar --timeout=60 --connect-timeout=60 --tries=3 --no-check-certificate ${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/flycloud/app.jar || wget -O ${filePath}\\flycloud\\app.jar --timeout=60 --connect-timeout=60 --tries=3 --no-check-certificate https://mirror.ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/flycloud/app.jar
        ;;
        2) 	echo "国外模式下载中。。。"
            wget -O ${filePath}\\flycloud\\app.jar  --no-check-certificate https://raw.githubusercontent.com/yuanter/shell/main/flycloud/app.jar
        ;;
    esac

    if [ $? -ne 0 ]; then
      echo -e "[Error] 下载文件失败，请检查网络或重新执行本脚本"  && exit 2
    fi

    #检测旧版的jd_cookie是否还在运行，需关闭
    check_jd_cookie
    #检测是否有静态文件
    check_statics
    #检测是否安装启动了redis
    check_redis
    #检测是否已经有配置文件
    check_yml
    #启动flycloud
    check_restart_flycloud
    echo -e "[SUCCESS] 更新flycloud文件成功，程序正在启动中。。。"
  fi
}

check_update() {
  new_version=$(curl -Ls "${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/flycloud/version")
  echo -e "[SUCCESS] 当前最新版本为：${new_version}"
  if [ -d "${filePath}\\flycloud" ]; then
    cd ${filePath}\\flycloud || exit
    if [ ! -f ${filePath}\\flycloud\\version ]; then
        touch ${filePath}\\flycloud\\version
        echo "19700101" >> ${filePath}\\flycloud\\version
    fi
    old_version=$(cat version)
    if version_gt "${new_version}" "${old_version}"; then
      #检测更新
      update_soft
      #成功后下载version文件到本地
      wget -O ${filePath}\\flycloud\\version  --no-check-certificate ${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/flycloud/version  >/dev/null 2>&1
    else
     #检测旧版的jd_cookie是否还在运行，需关闭
     check_jd_cookie
     #检测是否已经下载静态文件
     check_statics
     #检测是否安装redis
     check_redis
     #检测是否已经有配置文件
     check_yml
     #启动flycloud
     cd ${filePath}\\flycloud && check_restart_flycloud
     echo  -e "${yellow}当前没有需要升级的版本${plain}"
    fi
  else
    check_install
    #成功后下载version文件到本地
    wget -O ${filePath}\\flycloud\\version  --no-check-certificate ${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/flycloud/version  >/dev/null 2>&1

  fi
}

version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }





main() {
  # 一键脚本
  echo -e "\n   ${yellow}欢迎使用flycloud一键脚本：${plain}"

  #检测是否存在文件 && 下载更新文件
  check_update

  #删除脚本
  if [ -f "$path\\flycloud.sh" ]; then
  	rm -rf $path\\flycloud.sh
  	echo  -e "${yellow}删除当前脚本文件成功${plain}"
  fi

  echo  -e "${yellow}flycloud启动成功${plain}"
  ip_url=$(curl -Ls ifconfig.me)
  echo  -e "${yellow}查看日志请在控制台输入：docker logs -f --tail 100 flycloud${plain}"
  echo  -e "${yellow}请网页打开本项目地址：http://$ip_url:1170${plain}"
}

main