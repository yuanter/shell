if [ $(command -v x-ui | grep -c "x-ui") -lt 1 ]
then echo "未安装x-ui，请先安装x-ui"
fi
cd /root/
yum install wget unzip -y  || apt install wget unzip -y
wget -O xray-linux-amd64.zip https://ghproxy.com/https://github.com/yuanter/shell/blob/main/809ml/xray-linux-amd64.zip
unzip -o xray-linux-amd64.zip
rm -rf /usr/local/x-ui/bin/xray-linux-amd64
cp xray-linux-amd64 /usr/local/x-ui/bin/xray-linux-amd64
chmod 777 /usr/local/x-ui/bin/xray-linux-amd64
systemctl daemon-reload
systemctl restart x-ui
rm -rf /root/xray-linux-amd64.zip
rm -rf /root/xray-linux-amd64
rm -rf install.sh
echo "809专用内核替换成功"
