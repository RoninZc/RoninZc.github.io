---
title: "解决Hugo字数统计不正确"
date: 2022-05-11T17:26:29+08:00
draft: false
toc: false
images:
tags: 
  - Hugo
---

在 Hugo 的配置文件中添加一行

```shell
hasCJKLanguage = true # 字数统计添加中文支持
```

重新编译即可
