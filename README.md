### nginx 服务目录
	
	安装目录：
	/usr/local/nginx

	约定nginx服务根放置的目录，不同项目可以在根目录下创建子目录。
	/var/www/

### docker 构建命令

	docker build -t nginx-1.10.2:v1 .

	# nginx-1.10.2:v1 为 构建镜像的tag，docker run 命令依赖这个tag


### docker 启动命令

	如果本地没有web服务，可以使用端口 -p 80:80 , 如果有web服务，需要修改端口，例如 -p 8080:80 。

	本地目录和容器映射需要绝对路径，需要修改source的值

	docker run -it -d -p 9080:80 -p 9090:443 --mount type=bind,source=F:/git/http/projects,target=/var/www --mount type=bind,source=F:/git/http/nginx/nginx.conf,target=/usr/local/nginx/conf/nginx.conf --mount type=bind,source=F:/git/http/nginx/ssl/,target=/usr/local/nginx/ssl/ --mount type=bind,source=F:/git/http/nginx/nginx_vhosts/,target=/usr/local/nginx/nginx_vhosts/ --mount type=bind,source=F:/git/http/nginx/logs/,target=/usr/local/nginx/logs/ --mount type=bind,source=F:/git/http/hosts/hosts,target=/etc/hosts --name web_h2 nginx-1.10.2:v1 


	docker run -it -d -p 9080:80 -p 9090:443 --name web_h2 nginx-1.10.2:v1


### 证书创建

	登录容器，在/usr/local/nginx/ssl 目录下创建对应证书

	penssl genrsa -des3 -out h1.com.key 2048 
	openssl req -new -key h1.com.key -out h1.com.csr   
	sudo openssl x509 -req -in h1.com.csr -out h1.com.crt -signkey h1.com.key -days 3650 