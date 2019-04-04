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

| 选项      | 作用                     |
| --------- | ------------------------ |
| -E        | 预处理,生成.i文件        |
| -S        | 编译，生成.s文件         |
| -c        | 汇编，生成.o文件         |
| NULL      | 连接，生成可执行文件     |
| -o        | 输出文件，以上均可用     |
| -l(小写L) | 后面跟要添加的lib库      |
| -I(大写I) | 后面跟要添加的头文件目录 |
| -L        | 后面跟要添加库的目录     |
|           |                          |

#### CMAKE

makefile实际上有作用的是命令行，它对文件依赖的生成并没有多大作用....

$^命令代表依赖文件，但它等于"找到的依赖文件的路径",所以命令行里尽量使用他，因为makefile实际工作的是命令行，就算你找不找的到所依赖的文件，他都按你敲的命令行工作，所以.....，这个makefile还真是鸡肋...,，$@代表目标文件，仅此而以

makefile命令执行顺序，从上到下，从左到右

| 变量  | 含义                 |
| ----- | -------------------- |
| $@    | 规则中的目标文件     |
| $<    | 规则中第一个依赖文件 |
| $?    |                      |
| $^    | 规则中所有依赖文件   |
| $(RM) | rm -f                |
| $(AR) | ar                   |
|       |                      |
|       |                      |
|       |                      |

第一个（伪）目标总是默认目标，总是被执行。而且每个makefile只有一个总目标，如果你实质上要生成多个目标，你需要先用个总目标，否则它默认取一个目标，从而达不到你要的结果。

#### 一个简易的IDE

[脚本](./test.sh)文件和[README.md](./README)

配合vim，按<F5>执行。vim的[配置](../../../01/31/vim使用和配置/index.html)

