---
title: "Docker 部署 Nginx 出现「host not found in upstream」问题解决"
date: 2022-07-20T15:17:19+08:00
draft: false
categories:
  - 折腾
tags: 
  - Docker
  - Nginx
---

## 问题

这个问题是本人在折腾自己的~~良心云~~（凉心云）的时候发现的，当时是想使用一个前置 Nginx 转发所有的请求，同时进行日志的记录等等。

当我写完配置文件，测试时没有任何问题。但是当我关闭了自己搭建的 es 服务，我发现我访问所有的服务都 500 了，这时我查看 nginx error 日志，记录如下

```
[emerg] 1#1: host not found in upstream "es" in /etc/nginx/conf.d/es.conf:13
```

## 解决

在 nginx 的配置文件中添加以下内容

```nginx
server {
  listen 80;
  server_name test.com;
  # 添加额外的 dns 解析地址，此地址为 docker 内部 dns 地址
  # 当 proxy_pass 为变量时 必须添加
  resolver 127.0.0.11;

  location / {
    set $tmp es;
    proxy_pass http://$tmp;
  }  
}
```

### 原理

nginx 启动时，会对其配置的 upstream 进行 DNS 解析测试，如果无法解析成功则会报错无法启动。

但是，当我们将 upstream 修改为**变量**时，nginx 不会进行测试，以此绕过这个问题。

resolver 则为 Nginx 设置 DNS 服务器，Nginx会动态利用 resolver 设置的DNS服务器（本机设置的 DNS 服务器或 /etc/hosts 无效），将域名解析成 IP，proxy 模块会将请求转发到解析后的IP上。

如果不添加的话，访问将会`502 Bad Gateway`，同时日志会显示

```
no resolver defined to resolve es
```

