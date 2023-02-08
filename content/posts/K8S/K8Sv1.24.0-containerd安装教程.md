---
title: "K8Sv1.24.0 containerd 安装教程"
date: 2022-05-14T16:45:00+08:00
images:
categories:
  - 学习
tags: 
  - k8s
  - containerd
---

### 1、卸载旧版本

```shell
sudo apt remove docker docker-engine docker.io containerd runc
```

### 2、安装相关依赖包

```shell
sudo apt update && sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
```

### 3、添加证书&镜像

* 官方镜像

  ```shell
  # 官方镜像
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  # 如果你使用的是 Ubuntu 22.04 请使用
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/aliyun-docker-archive-keyring.gpg
  
  sudo add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  ```

* 阿里云镜像

  ```shell
  curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
  # 如果你使用的是 Ubuntu 22.04 请使用
  curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg ｜ sudo gpg --dearmor -o /usr/share/keyrings/aliyun-docker-archive-keyring.gpg
  
  sudo add-apt-repository "deb [arch=arm64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
  ```

> 如果卡住不动的话，可以先 wget 下载文件，直接导入
>
> ```shell
> wget http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg
> sudo apt-key add ./gpg
> ```

### 4、安装

```shell
sudo apt update && sudo apt install -y containerd
```

### 5、生成配置文件

```shell
mkdir -p /etc/containerd && containerd config default | sudo tee /etc/containerd/config.toml

# 修改配置文件
# 老版本需要手动添加 `SystemdCgroup = true`
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml &&
grep 'SystemdCgroup' -B 11 /etc/containerd/config.toml
```

### 6、配置镜像加速[官方链接](https://cr.console.aliyun.com/cn-shenzhen/instances/mirrors)

```shell
# 这里需要替换为自己阿里云的镜像加速器地址
sudo sed -i 's#endpoint = ""#endpoint = "https://xxxxxx.mirror.aliyuncs.com"#g' /etc/containerd/config.toml &&
grep 'endpoin' -B 5 /etc/containerd/config.toml

sed -i 's#sandbox_image = "k8s.gcr.io/pause#sandbox_image = "registry.aliyuncs.com/google_containers/pause#g' /etc/containerd/config.toml &&
grep 'sandbox_image' /etc/containerd/config.toml
```

### 7、重载服务器配置

```shell
systemctl daemon-reload && systemctl restart containerd.service
```

### 8、检查运行情况

```shell
systemctl status containerd
```