FROM  centos:centos7
ENV SHELL /bin/bash
MAINTAINER yuanter


# set timezone
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone

RUN set -eux

ENV JAVA_HOME /usr/java/openjdk-8
ENV JRE_HOME=$JAVA_HOME/jre
ENV JAVA_PATH=$JAVA_HOME/bin:$JRE_HOME/bin
ENV CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
ENV PATH=$PATH:$JAVA_HOME/bin

ENV NODE_HOME=/usr/local/node

# Default to UTF-8 file.encoding
ENV LANG en_US.UTF-8

#架构
ARG TARGETARCH


#复制运行文件
#ADD application.yml application.yml
#ADD FlyCloud-1.0.jar app.jar
#ADD /statics /statics
ADD ./flycloud/docker/arm/openjdk-8 /arm/openjdk-8
ADD ./flycloud/docker/start.sh start.sh
ADD ./flycloud/docker/docker-entrypoint.sh docker-entrypoint.sh


#运行目录
ENV DIR_ROOT=/root/flycloud
WORKDIR ${DIR_ROOT}

RUN mkdir -p "$JAVA_HOME"  \
	&& mkdir -p /arm/openjdk-8  \
	&& mkdir -p /arm/node-v16.9.1-linux-arm64 \
	&& mkdir -p ${DIR_ROOT} \
	&& chmod +x /docker-entrypoint.sh \
	&& chmod +x /start.sh \
	&& sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* \
	&& sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* \
	&& yum  clean  all \
	&& yum makecache



# 安装环境
#arch="$(uname -m)"&& echo "$(uname -m)";
RUN yum install wget curl tar sysvinit-tools -y  2>&1 > /dev/null\
	&& echo '------------------------------------开始安装环境------------------------------------' \
	&& cd / && chmod 777  /docker-entrypoint.sh \
	#安装nodejs
	&& curl -fsSL https://rpm.nodesource.com/setup_16.x | bash -  2>&1 > /dev/null\
	&& yum install -y nodejs  2>&1 > /dev/null\
	&& case "$TARGETARCH" in \
		'amd64') \
			echo "------------------------------------amd64正在yum安装jdk中------------------------------------" \
			&& yum install java-1.8.0-openjdk.x86_64 -y  2>&1 > /dev/null \
			;; \
		'arm64') \
			mv /arm/openjdk-8 /usr/java \
			&& chmod -R 777 /usr/java \
			&& echo "------------------------------正在安装arm64位jdk中------------------------------------" \
			&& echo "export JAVA_HOME=$JAVA_HOME"  >>  /etc/profile \
			&& echo "export JRE_HOME=\$JAVA_HOME/jre"  >>  /etc/profile \
			&& echo "export JAVA_PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin"  >>  /etc/profile \
			&& echo "export CLASSPATH=.:\$JAVA_HOME/lib:\$JRE_HOME/lib:\$CLASSPATH"  >>  /etc/profile \
			&& echo "export PATH=\$PATH:\$JAVA_HOME/bin"  >>  /etc/profile \
			&& source /etc/profile \
			&& echo "arm64的JDK版本如下：" \
			&& javac -version \
			&& java -version  \
			#配置nodejs环境问题  /usr/local/sbin/node不存在，用软连接  ln -s /usr/bin/node /usr/local/sbin/node
			&& ln -s /usr/bin/node /usr/local/sbin/node \
			;; \
		*) echo >&2 "error: 不支持架构: '$TARGETARCH'"; exit 1 ;; \
	esac; \
#	echo "------------------------------正在安装pm2中------------------------------------" && \
#	npm install pm2@latest -g && \
	echo '------------------------------------脚本安装完毕，开始打包中------------------------------------'



EXPOSE 1170
ENTRYPOINT ["sh", "/start.sh"]
#ENTRYPOINT ["nohup","java","-server","-Xms64m","-Xmx128m","-Djava.security.egd=file:/dev/./urandom","-jar","-Dfile.encoding=UTF-8","/root/flycloud/app.jar","&"]