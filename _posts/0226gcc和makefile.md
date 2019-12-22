---
title: gcc和makefile
tags: 计算机
categories: 学习笔记
date: 2019-02-26 19:50:53
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});
</script>
<script type="text/javascript" async
  src="https://wujilingfeng.top/MathJax/MathJax.js?config=TeX-AMS_CHTML">
</script>
本文记录gcc和makefile



<!--more-->

#### GCC

| 选项          | 作用                     |
| ------------- | ------------------------ |
| -E            | 预处理,生成.i文件        |
| -S            | 编译，生成.s文件         |
| -c            | 汇编，生成.o文件         |
| NULL          | 连接，生成可执行文件     |
| -o            | 输出文件，以上均可用     |
| -l(小写L)     | 后面跟要添加的lib库      |
| -I(大写I)     | 后面跟要添加的头文件目录 |
| -L            | 后面跟要添加库的目录     |
| -fPIC -shared | 打包成共享动态库         |

连接器的作用是连接目标代码，*系统启动代码*，库代码。





c++ 两阶段名字查找，对于非 dependent name 都是现场决议的，所以空写 f 的时候，编译器不查找基类 scope，没找到就报错，编译器不查找基类，因为此时基类还是个类模板，到底是什么东西还不定呢。
然后实例化的时候进行第二阶段名字查找，这时候所有类型都是确定的，才能够查找基类 scope。
增加 this 或 Y<T>:: 就是把对 f 的查找延迟到第二阶段，这是 c++ 标准规定的。

#### MAKE

makefile实际上有作用的是命令行，它对文件依赖的生成并没有多大作用....

$^命令代表依赖文件，但它等于"找到的依赖文件的路径",所以命令行里尽量使用他，因为makefile实际工作的是命令行，就算你找不找的到所依赖的文件，他都按你敲的命令行工作，所以.....，这个makefile还真是鸡肋...,，$@代表目标文件，仅此而以

makefile命令执行顺序，从上到下，从左到右

| 变量  | 含义                                                         |
| ----- | ------------------------------------------------------------ |
| $@    | 规则中的目标文件                                             |
| $<    | 规则中第一个依赖文件,但是有隐藏规则，所以才可以用来遍历依赖文件 |
| $?    |                                                              |
| $^    | 规则中所有依赖文件                                           |
| $(RM) | rm -f                                                        |
| $(AR) | ar                                                           |
|       |                                                              |
|       |                                                              |
|       |                                                              |

第一个（伪）目标总是默认目标，总是被执行。而且每个makefile只有一个总目标，如果你实质上要生成多个目标，你需要先用个总目标，否则它默认取一个目标，从而达不到你要的结果。

#### 一个简易的IDE

[脚本](./test.sh)文件和[README.md](./README)

配合vim，按<F5>执行。vim的[配置](../../../01/31/vim使用和配置/index.html)

#### CMake

不同的编译工具(eg.nmake GNU make..)，有不同的语法，他们的工作方式都是读取一个文本文件(makefile)。正因为不同的编译工具是应用不同的语法，我们在不同的平台上就要写不同的makefile.cmake的工作就是自动查找当前平台下的编译工具，生成对应的文本文件(makefile)。

cmake权限不够

* 改变安装目录 CMAKE_INSTALL_PREFIX
* su进入root命令行

[这里](https://blog.csdn.net/chengde6896383/article/details/86497016)介绍了cmake findpackage