# 如何在Hugo和Typora中显示图片


### 问题

Typora 可以方便的将文件保存在本地，但是不合理的设置将无法适应各种静态博客生成工具（比如：hugo）的图片存储方式，所以要对 Typora 进行设置。

### 目标

hugo 的默认图片路径为 `${site}/static/images`目录，所以我们需要配置 Typora 的图片默认复制到整个目录。并且达到在网站和 Typora 中同时可查看。

### 解决

对于 Typora 图片的默认复制路径可以直接进行配置，如下图所示：

![image-20220511141441075.png](https://lsky.ronin-zc.com/i/2022/08/17/62fc964e34f23.png)

也可以再加上 `static/images/${filename}/`，这样可以更加方便的管理图片。

但是这样配置完会发现，Hugo 读取图片的条件满足了，Typora 预览没法满足，在设置里我们也找到调整的位置。

其实 Typora 有一个隐藏的配置，`格式( Format ) -&gt; 图像( Image ) -&gt; 设置图片根目录( Use Image Root Path )`，具体可以依据下图。

![image-20220511141908384.png](https://lsky.ronin-zc.com/i/2022/08/17/62fc964ec9604.png)

配置是在当个 `md` 文件中生效的，在设置后在文件的开头会添加上`typora-root-url: ../../../static/`，也就是具体的原理了。


---

> 作者: RoninZc  
> URL: https://ronin-zc.com/posts/%E5%A6%82%E4%BD%95%E5%9C%A8hugo%E5%92%8Ctypora%E4%B8%AD%E6%98%BE%E7%A4%BA%E5%9B%BE%E7%89%87/  

