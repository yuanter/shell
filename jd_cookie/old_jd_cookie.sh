#!/bin/sh

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# 一键脚本
echo -e "\n   ${yellow}欢迎使用jd_cookie一键脚本：${plain}"
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
            proxyURL=${proxyURLTemp}
            echo -e "${yellow}使用自定义加速镜像${proxyURL}${plain}"
        fi
   ;;
   2) echo "你选择了国外主机或使用内置加速镜像,不需要设置"
   ;;
esac

# 配置host
echo -e "   ${yellow}jd_cookie安装与升级聚合脚本 ${plain}"
echo "   1) 安装jd_cookie(自带安装redis容器)"
echo "   2) 升级jd_cookie"
echo "   3) 安装redis容器（额外脚本，非必选）"
echo "   0) 退出"
echo -ne "\n你的选择: "
read input
case $input in
    0)	echo -e "${yellow}退出脚本程序${plain}";exit 1 ;;
    1)	echo -e "${yellow}正在拉取安装jd_cookie脚本${plain}";
        echo -e "${yellow}下载脚本模式${plain}";
		echo "   1) 国内模式，启用加速"
		echo "   2) 国外模式，不加速"
		echo -ne "\n你的选择："
        read  is_speed_one
		case $is_speed_one in
			1) 	echo "国内模式下载安装脚本中。。。"
				wget -O start_jd_cookie.sh  --no-check-certificate ${proxyURL}/https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/start_jd_cookie.sh
				chmod +x *sh
				bash start_jd_cookie.sh
			;;
			2) 	echo "国外模式下载安装脚本中。。。"
				wget -O start_jd_cookie.sh  --no-check-certificate https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/start_jd_cookie.sh
				chmod +x *sh
				bash start_jd_cookie.sh
			;;
		esac

    ;;
    2)	echo -e "${yellow}正在拉取升级jd_cookie脚本${plain}";
        echo -e "${yellow}下载脚本模式${plain}";
		echo "   1) 国内模式，启用加速"
		echo "   2) 国外模式，不加速"
		echo -ne "\n你的选择："
        read  is_speed_two
		case $is_speed_two in
			1) 	echo "国内模式下载安装脚本中。。。"
				wget -O update_jd_cookie.sh  --no-check-certificate ${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/update_jd_cookie.sh
				chmod +x *sh
				bash update_jd_cookie.sh
			;;
			2) 	echo "国外模式下载安装脚本中。。。"
				wget -O update_jd_cookie.sh  --no-check-certificate https://raw.githubusercontent.com/yuanter/shell/main/jd_cookie/update_jd_cookie.sh
				chmod +x *sh
				bash update_jd_cookie.sh
			;;
		esac

    ;;
    3)	echo -e "${yellow}正在拉取安装redis脚本${plain}";
        echo -e "${yellow}下载脚本模式${plain}";
		echo "   1) 国内模式，启用加速"
		echo "   2) 国外模式，不加速"
		echo -ne "\n你的选择："
        read  is_speed_three
		case $is_speed_three in
			1) 	echo "国内模式下载安装脚本中。。。"
				wget -O redis_install.sh  --no-check-certificate ${proxyURL}https://raw.githubusercontent.com/yuanter/shell/main/redis_install.sh
				chmod +x *sh
				bash redis_install.sh
			;;
			2) 	echo "国外模式下载安装脚本中。。。"
				wget -O redis_install.sh  --no-check-certificate https://raw.githubusercontent.com/yuanter/shell/main/redis_install.sh
				chmod +x *sh
				bash redis_install.sh
			;;
		esac
	;;
esac
