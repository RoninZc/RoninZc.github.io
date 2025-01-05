# K8Sv1.24.0 Containerd 安装教程


### 1、卸载旧版本

```shell
sudo apt remove docker docker-engine docker.io containerd runc
```

### 2、安装相关依赖包

```shell
sudo apt update &amp;&amp; sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
```

### 3、添加证书&amp;镜像

* 官方镜像

  ```shell
  # 官方镜像
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  # 如果你使用的是 Ubuntu 22.04 请使用
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/aliyun-docker-archive-keyring.gpg
  
  sudo add-apt-repository &#34;deb [arch=arm64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable&#34;
  ```

* 阿里云镜像

  ```shell
  curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
  # 如果你使用的是 Ubuntu 22.04 请使用
  curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg ｜ sudo gpg --dearmor -o /usr/share/keyrings/aliyun-docker-archive-keyring.gpg
  
  sudo add-apt-repository &#34;deb [arch=arm64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable&#34;
  ```

&gt; 如果卡住不动的话，可以先 wget 下载文件，直接导入
&gt;
&gt; ```shell
&gt; wget http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg
&gt; sudo apt-key add ./gpg
&gt; ```

### 4、安装

```shell
sudo apt update &amp;&amp; sudo apt install -y containerd
```

### 5、生成配置文件

```shell
mkdir -p /etc/containerd &amp;&amp; containerd config default | sudo tee /etc/containerd/config.toml

# 修改配置文件
# 老版本需要手动添加 `SystemdCgroup = true`
sudo sed -i &#39;s/SystemdCgroup = false/SystemdCgroup = true/&#39; /etc/containerd/config.toml &amp;&amp;
grep &#39;SystemdCgroup&#39; -B 11 /etc/containerd/config.toml
```

### 6、配置镜像加速[官方链接](https://cr.console.aliyun.com/cn-shenzhen/instances/mirrors)

```shell
# 这里需要替换为自己阿里云的镜像加速器地址
sudo sed -i &#39;s#endpoint = &#34;&#34;#endpoint = &#34;https://xxxxxx.mirror.aliyuncs.com&#34;#g&#39; /etc/containerd/config.toml &amp;&amp;
grep &#39;endpoin&#39; -B 5 /etc/containerd/config.toml

sed -i &#39;s#sandbox_image = &#34;k8s.gcr.io/pause#sandbox_image = &#34;registry.aliyuncs.com/google_containers/pause#g&#39; /etc/containerd/config.toml &amp;&amp;
grep &#39;sandbox_image&#39; /etc/containerd/config.toml
```

### 7、重载服务器配置

```shell
systemctl daemon-reload &amp;&amp; systemctl restart containerd.service
```

### 8、检查运行情况

```shell
systemctl status containerd
```

---

> 作者: RoninZc  
> URL: https://ronin-zc.com/posts/k8sv1.24.0-containerd%E5%AE%89%E8%A3%85%E6%95%99%E7%A8%8B/  

