---
title: "Ubuntu ARM Docker 安装"
date: 2022-05-13T14:13:00+08:00
tags: 
  - Ubuntu
  - ARM
  - Docker
---

### 1、卸载可能存在的旧版本

```shell
sudo apt remove docker docker-engine docker-ce docker.io
```

### 2、安装依赖使 apt 可通过 HTTPS 下载包

```shell
sudo apt update && apt install -y apt-transport-https ca-certificates curl software-properties-common
```

### 3、添加 docker 密钥

#### 3.1、阿里云 docker 源

```shell
curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
```

#### 3.2、官方 docker 源

```shell
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

### 4、添加对应的 docker 源「需要和第三部一致」

#### 4.1、阿里云 [「官方文档」](https://developer.aliyun.com/mirror/docker-ce)

```shell
sudo add-apt-repository "deb [arch=arm64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
```

#### 4.2、官方源

```shell
sudo add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

> `$(lsb_release -cs)`是获取当前 Ubuntu 代号
>
> 如果没有科学上网手段，推荐使用阿里云源

### 5、安装 docker

```shell
sudo apt update && apt install -y docker-ce
```

### 6、配置镜像仓库

```shell
mkdir /etc/docker
cat > /etc/docker/daemon.json << EOF
{
	"exec-opts": ["native.cgroupdriver=systemd"],
	"log-driver": "json-file",
	"log-opts": {
		"max-size": "100m"
	},
	"registry-mirrors": ["https://xxx.mirror.aliyuncs.com"]
}
EOF

# 设置完成后重启
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 7、验证安装

```shell
systemstl status docker
```

正常运行则会显示

![image-20220513142604338.png](https://lsky.ronin-zc.com/i/2022/08/17/62fc9697284d7.png)
