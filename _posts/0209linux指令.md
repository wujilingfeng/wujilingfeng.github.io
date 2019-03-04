---
title: linux指令
tags: [工具, linux]
date: 2019-02-09 12:34:58
categories: 计算机
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});
</script>
<script type="text/javascript" async
  src="https://wujilingfeng.top/MathJax/MathJax.js?config=TeX-AMS_CHTML">
</script>
本文介绍Linux指令

<!--more-->

##### 文件的解压

---

没有注释的是为解压

```
xz -d
tar -xvf
tar -cvf #压缩
xz -z #压缩
```

##### 多个命令

```
&表示后台执行任务，如redshift &
|表示前一个命令的输出作为后一个命令的参数，如cat test.txt|grep a
&&表示前一个命令成功时执行后一个命令
||与上面相反
```

##### 常用命令

```
ar#打包，常用于.o文件打包为.a
ar x#展开，提取模块(.o)
ar r#打包一个库，最好用ar rs
useradd name -u yourid -d /home/name -s /bin/bash#create user account
usermod name -g groupname #put name to groupname
groupadd groupname#create group
```

##### 常用脚本

```
cat>文件名<<EOF#向某文件写入内容，内容以EOF结尾
cat>>文件名<<EOF#向某文件追加内容
```

比如

```
cat>test<<EOF
AFD$1
DFADS
EOF
#$1是特殊字符，表示第一个参数的位置，如需输入$,用转义\
```



#### Debian软件包

关于[Debian](https://baike.baidu.com/item/Debian/748667?fr=aladdin)的介绍

```
dpkg -l #显示安装包信息,可以加上| grep显示关于某些的安装包信息
```












