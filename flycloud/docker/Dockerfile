#FROM node:16.16.0-alpine3.16
FROM node:18-alpine3.20
ENV SHELL /bin/bash
MAINTAINER yuanter


RUN set -eux

# Default to UTF-8 file.encoding
#ENV LANG en_US.UTF-8
# 设置语言环境
ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8

#架构
ARG TARGETARCH


#运行目录
ENV DIR_ROOT=/root/flycloud
WORKDIR ${DIR_ROOT}

#复制运行文件
ADD ./flycloud/docker/start.sh /start.sh
ADD ./flycloud/docker/docker-entrypoint.sh /docker-entrypoint.sh


RUN mkdir -p ${DIR_ROOT} \
	&& chmod 777 /docker-entrypoint.sh \
	&& chmod 777 /start.sh

# 安装环境
RUN echo '------------------------------------开始安装环境------------------------------------'
RUN apk update \
	&& apk add --no-cache curl wget bash tzdata unzip tar openjdk11 \
    chromium \
    chromium-chromedriver\
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    mesa-gl \
    xvfb \
    libstdc++ \
    wait4ports \
    xorg-server \
    dbus \
    # --- 新增字体 --- \
    font-noto-cjk \
    font-noto-emoji \
    && \
    # 清理缓存减小体积
    rm -rf /var/cache/apk/*

# 新增
# 设置 JAVA_HOME (可选，为了确保程序能找到 Java 11)
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk
ENV PATH="$JAVA_HOME/bin:$PATH"

# 设置 DISPLAY 环境变量
ENV CHROMIUM_BIN=/usr/bin/chromium-browser
ENV CHROME_DRIVER=/usr/bin/chromedriver
ENV DISPLAY=:99
# 启动虚拟显示 (增加 -ac 参数取消访问控制，更稳定)
RUN Xvfb :99 -ac -screen 0 1920x1080x24 &
	
RUN echo '------------------------------------脚本安装完毕，开始打包中------------------------------------'	

# set timezone
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone

EXPOSE 1170
ENTRYPOINT ["sh", "/start.sh"]
#ENTRYPOINT ["nohup","java","-server","-Xms64m","-Xmx128m","-Djava.security.egd=file:/dev/./urandom","-jar","-Dfile.encoding=UTF-8","/root/flycloud/app.jar","&"]