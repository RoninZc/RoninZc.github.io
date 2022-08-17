---
title: "Webhooks实现博客自动更新"
date: 2021-11-08T11:31:25+08:00
images:
tags: 
  - Webhooks
  - docker
---



今年嫖了一波良心云的服务器（2c4g8m），打算把 github page迁移到自己的服务器上。

又不想每次都 ssh 上服务器去拉取，也不想 ftp 去上传文件（公司安全要求）。所以想通过webhooks通知，让服务器自动的去更新博客。具体实现希望通过 docker 来解决，这样可以通用，下次迁移服务的时候可以直接拿个 docker-compose 文件就迁移完成了。~~毕竟良心云续费可不良心~~。

说干就干。

首先，我们需要一个能接收到请求的东西，任意方式都行，我这里使用的是 golang 。

build镜像需要以下目录结构，也可以自行调整。

```tex
.
├── Dockerfile
├── src
│   ├── cmd
│   │   ├── main.go
│   │   └── sync.sh
│   ├── go.mod
│   └── go.sum
└── ssh
    ├── id_rsa
    ├── id_rsa.pub
    └── known_hosts
```

* main.go

```golang
package main

import (
	"fmt"
	"net/http"
	"os/exec"

	"github.com/go-playground/webhooks/v6/github"
)

const (
	path = "/webhooks" // 可以自行修改
)

func main() {
	hook, err := github.New(github.Options.Secret("你自己设置的秘钥"))
	if err != nil {
		panic(err)
	}

	http.HandleFunc(path, func(w http.ResponseWriter, r *http.Request) {
		cmd := exec.Command("/bin/sh", "./cmd/sync.sh")
		out, err := cmd.Output()
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(out)

		payload, err := hook.Parse(r, github.ReleaseEvent, github.PushEvent)
		if err != nil {
			if err == github.ErrEventNotFound {
				fmt.Println(err)
			}
		}
		switch payload.(type) {
		case github.PushPayload:
			fmt.Println("received push event")
			exec.Command("/bin/sh", "./cmd/sync.sh").Run()
		default:
			fmt.Println(payload)
		}
	})
	http.ListenAndServe(":8888", nil)
}

```

接收到请求并校验通过之后，会执行 sync.sh 脚本。里面的内容可以根据自己需要进行修改

* sync.sh

```shell
#!/bin/bash
cd /data/www
echo $(pwd)
echo $(git pull)
```

运行的服务现在准备好了，得准备运行的环境

因为是个小功能所以使用的镜像也希望轻量一些，选用的是 ```golang:alpine```镜像

如果需要其他功能也可以自行修改

Dockerfile

```dockerfile
FROM golang:alpine

# 设置 go mod 代理
ENV GOPROXY=https://goproxy.cn,direct
# 替换apk镜像源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories


# 设置ssh pub key
COPY ./ssh /root/.ssh
RUN chmod -R 600 /root/.ssh

# 设置工作目录
WORKDIR /tmp/src
# 复制代码
COPY ./src /tmp/src
RUN apk update
RUN apk add git && apk add openssh
RUN go mod tidy
RUN go build -o bin/hugo cmd/main.go 

ENTRYPOINT ["./bin/hugo"]
CMD ["-logtostderr"]
```

可以看到这里需要ssh信息，自行添加文件即可。

这里也直接给出 docker-compose 文件

```yaml
  hugo:
    container_name: hugo
    build: ./services/go-hugo/
    volumes:
      - {你需要同步的git目录}:/data/www:rw # 资源目录
    links: 
      - nginx # 如果你不需要nginx做转发，可以去除这里

  nginx:
    container_name: nginx
    build:
      context: ./services/nginx
      args:
        NGINX_VERSION: 1.21.3-alpine
        CONTAINER_PACKAGE_URL: mirrors.aliyun.com
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - {你的资源目录}:/www/:rw
      - {你的https目录}:/ssl:rw
      - {你的配置文件目录}:/etc/nginx/conf.d/:rw
      - {你的根配置文件}:/etc/nginx/nginx.conf:ro
      - {nginx日志目录}:/var/log/nginx/:rw
    environment:
      TZ: "Asia/Shanghai"
    restart: always
    networks:
      - default


```

可以直接把端口暴露出公网，也可以使用nginx做一层转发，可以提高安全性不暴露端口

* nginx的Dockerfile

```dockerfile
ARG NGINX_VERSION
FROM nginx:${NGINX_VERSION}

ARG TZ
ARG NGINX_VERSION
ARG CONTAINER_PACKAGE_URL
ARG NGINX_INSTALL_APPS

ENV INSTALL_APPS=",${NGINX_INSTALL_APPS},"

RUN if [ "${CONTAINER_PACKAGE_URL}" != "" ]; then \
        sed -i "s/dl-cdn.alpinelinux.org/${CONTAINER_PACKAGE_URL}/g" /etc/apk/repositories; \
    fi

RUN if [ -z "${INSTALL_APPS##*,certbot,*}" ]; then \
        echo "---------- Install certbot ----------"; \
        apk add --no-cache certbot; \
    fi

WORKDIR /www

```

* nginx配置文件

```nginx
server {
    listen       80;
    server_name  你的域名;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name  你的域名;
    # server_name  localhost;
	  root    {根地址};

    # ssl证书地址
    ssl_certificate     /ssl/xxx.pem;  # pem文件的路径
    ssl_certificate_key  /ssl/xxx.key; # key文件的路径

    location /webhook {
        proxy_pass http://hugo:8888; # HTTP 代理转发port。这里因为使用了已命名为 hugo 的 docker 容器，所以可以在nginx配置中直接使用。
        proxy_set_header    Host localhost; # 不要忘记这句 Host $host
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-Proto https;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location / {
        index index.html;
    }
}
```

配置都完成后，直接使用 docker-compose up -d 启动容器。在github上设置webhooks的部分就不再此赘述。