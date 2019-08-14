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
gzip -d
tar -cvf img.tar img1 img2#对img1 img2打包为img.tar
tar -xvf filename.tar.gz#解压文件
xz -z #压缩
unzip#解压zip文件
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
apt-cache admision package_name#显示apt库package_name的版本信息,然后安装指定版本的包
apt install package_name=version
apt_name restart #重启apt_name
ar#打包，常用于.o文件打包为.a
ar x#展开，提取模块(.o)
ar r#打包一个库，最好用ar rs
useradd name -u yourid -d /home/name -s /bin/bash#create user account
usermod name -g groupname #put name to groupname
groupadd groupname#create group
sudo fdisk -l#显示系统分区
badblocks -v /dev/sdb1#对sdb1磁盘进行检查
chmod 777 dir_name -R#改变目录dir_name三个用户的权限，-R表示对子目录递归改变
rm -r ~/.cache/ibus/pinyin#解决拼音数字键问题
cp -ri dir_name/* dir_name1/#将dir_name文件目录下的文件复制到dir_name1下
file file_name#file命令用来检测文件类型
ps aux||grep aria2c#显示aria2c进程信息,然后杀死
kill PID
```

##### 常用脚本
linux下反引号括起来的命令优先执行（不是单引号）

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
linux字符串匹配
```
str="dsfs -I dfs"&&${str#*d}#删除满足匹配的字符串
str="dsfs -I dfs"&&${str/d/lll}#替换字符串
```
ubuntu 下的魔法建`Alt+Prtsc+R+E+I+S+U+B`

#### Debian软件包

关于[Debian](https://baike.baidu.com/item/Debian/748667?fr=aladdin)的介绍

```
dpkg -l #显示安装包信息,可以加上| grep显示关于某些的安装包信息
```

#### 计算机

一个字节是8位，对于16进制来说是2两位。字长是cpu处理一条命令的最大位数，比如32位cpu，64位cpu。










