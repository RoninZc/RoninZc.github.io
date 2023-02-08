---
title: "MacOS使用DoH"
date: 2023-02-08T13:45:00+08:00
draft: false
categories:
  - 折腾
tags: 
  - MacOS
  - DNS

---

### 安装 HomeBrew（已有则忽略）

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

### 安装 cloudflared

```bash
brew install cloudflare/cloudflare/cloudflared
```

### 创建配置文件

```bash
mkdir -p /usr/local/etc/cloudflared
vim /usr/local/etc/cloudflared/config.yaml
```

```yaml
proxy-dns: true
proxy-dns-upstream:
  - https://doh.pub/dns-query
  - https://1.1.1.1/dns-query
  - https://1.0.0.1/dns-query
```

> 这里使用的是默认 DNSPod 的 DoH 服务
> 下列两个是 Cloudflare 提供的 DoH 服务用于冗余

### 启动服务

```bash
sudo cloudflared service install
// 之后不想使用的话可以执行 sudo cloudflared service uninstall
```

### 修改本机设定

「系统设置」->「Wi-Fi」->「详细信息」->「DNS」

![image-20230208140729655](https://lsky.ronin-zc.com/i/2023/02/08/63e33c226a130.png)

![image-20230208140806644](https://lsky.ronin-zc.com/i/2023/02/08/63e33c46ea36f.png)

### 测试

```bash
dig ronin-zc.com
```

查看相应请求的 DNS 服务器 ip