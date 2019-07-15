---
title: python笔记
tags: 计算机
categories: 学习笔记
date: 2019-04-11 22:01:36
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});
</script>
<script type="text/javascript" async
  src="https://wujilingfeng.top/MathJax/MathJax.js?config=TeX-AMS_CHTML">
</script>


本文记录python学习笔记

<!--more-->

python是脚本语言，所以支持一行一运行。

python单双引号，三引号都可以使用，[具体区别](<https://blog.csdn.net/woainishifu/article/details/76105667>)

.py文件可以用`python test.py`或者`python3 test.py`

| 例子 | 解释     |
| ---- | -------- |
| a*b  | a乘b     |
| a**b | a的b次方 |
| a%b  | a取余b   |
| a/b  | a除b     |
| a//b | a整除b   |

---

[python教程](<http://www.runoob.com/python3/python3-data-type.html>)

`python -m pip install numpy`安装numpy
pip3 install package -i url#url是你要用的镜像地址

`python -m pip install matplotlib`在termux下，可能出现ft2build.h找不到的情况，它在/usr/include/freetype2文件夹下，将这个文件夹下的内容拷贝到/usr/include里

#### 函数

python函数的变量大多是引用，除了链表等结构体

##### 类

[python的类](https://www.runoob.com/python3/python3-class.html)

`if __name__=="__main__":`

语句是文件当作脚本和模块运行的区别

三种信息标记形式:xml,json,yaml

#### c为python做模块

#### c中调用python