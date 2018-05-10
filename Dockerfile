FROM ubuntu:12.04.5
MAINTAINER copentop



# nginx 版本
ENV NGINX_VERSION 1.10.2
# openssl 版本
ENV OPENSSL_VERSION 1.0.2
#nginx 环境变量
ENV PATH="/usr/local/nginx/sbin:$PATH"

ARG DEBIAN_FRONTEND=noninteractive
# 更新
RUN apt-get -qq update \
	&&  apt-get install -yq --no-install-recommends apt-utils \
    wget \
    build-essential \
	vim \
	&& mkdir -p /var/log/nginx \
	&& mkdir -p /data/webpackages \
	&& mkdir -p /usr/local/nginx/conf/ \
	&& mkdir -p /usr/local/nginx/sbin/ \
	&& mkdir -p /usr/local/nginx/nginx_vhosts/ \
	&& mkdir -p /usr/local/nginx/ssl/ \
	&& mkdir -p /usr/local/nginx/etc/ \
	&& mkdir -p /usr/local/nginx/logs/

	
# openssl
RUN cd /data/webpackages/ \
	&& wget --no-check-certificate https://www.openssl.org/source/old/${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}l.tar.gz \
	&& tar -zxf openssl-${OPENSSL_VERSION}l.tar.gz \
	&& cd ./openssl-${OPENSSL_VERSION}l \
	&& ./config \
	&& make \
	&& make test \
	&& make install \
	&& ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl \
	&& rm -rf /data/webpackages/openssl-${OPENSSL_VERSION}l.tar.gz \
	&& make clean 

# PCRE &  zlib
RUN cd /data/webpackages/ \
	&& wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.39.tar.gz \
	&& tar -zxf pcre-8.39.tar.gz \
	&& cd pcre-8.39 \
	&& ./configure \
	&& make \
	&& make install \
	&& make clean \
	&& cd /data/webpackages/ \
	&& wget http://zlib.net/zlib-1.2.11.tar.gz \
	&& tar -zxf zlib-1.2.11.tar.gz \
	&& cd zlib-1.2.11 \
	&& ./configure \
	&& make \
	&& make install \
	&& make clean  \
	&& rm -rf /data/webpackages/pcre-8.39.tar.gz \
	&& rm -rf /data/webpackages/zlib-1.2.11.tar.gz
	

# Nginx
RUN cd /data/webpackages/ \
	&& wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
	&& tar zxf nginx-${NGINX_VERSION}.tar.gz \
	&& cd nginx-${NGINX_VERSION} \
	&& ./configure \
	--prefix=/usr/local/nginx \
	--conf-path=/usr/local/nginx/conf/nginx.conf \
	--sbin-path=/usr/local/nginx/sbin/nginx \
    --pid-path=/usr/local/nginx/etc/nginx.pid \
    --with-http_v2_module \
	--with-http_ssl_module \
	--with-http_realip_module \
	--with-http_addition_module \
	--with-http_sub_module \
	--with-http_dav_module \
	--with-http_flv_module \
	--with-http_mp4_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_random_index_module \
	--with-http_secure_link_module \
	--with-http_stub_status_module \
	--with-http_auth_request_module \
	--with-mail \
	--with-mail_ssl_module \
	--with-file-aio \
	--with-threads \
	--with-stream \
	--with-stream_ssl_module \
    --with-pcre=../pcre-8.39 \
    --with-zlib=../zlib-1.2.11 \
    --with-openssl=../openssl-${OPENSSL_VERSION}l \
	&& make \
	&& make install \
	&& ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx \
	&& make clean \
	&& rm -rf /data/webpackages/nginx-${NGINX_VERSION}.tar.gz

	
# 复制nginx配置
COPY ./nginx/nginx.conf /usr/local/nginx/conf/

# 暴露端口
EXPOSE 22 80 443

# nginx 后台执行命令
CMD ["nginx", "-g", "daemon off;"]