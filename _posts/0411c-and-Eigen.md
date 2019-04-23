---
title: c++and Eigen
tags: 数学
categories: 学习笔记
date: 2019-04-11 22:01:23
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});
</script>
<script type="text/javascript" async
  src="https://wujilingfeng.top/MathJax/MathJax.js?config=TeX-AMS_CHTML">
</script>


本文记录c++学习笔记

<!--more-->

##### STL

| 常用函数     | 意义 |
| :--- | :------- |
| push_back |          |
|      |          |
|      |          |
|      |          |
|      |          |
|      |          |



###### remove和erase

remove形参为值，erase的形参为位置。vector的remove是将等于value元素放到末尾，并不影响size。

erase会销毁指针使用时请注意。

###### ++

前++表示先自身++再传递自身值，后++表示自身++完后，传递没++之前的值。

如下两个例子，一个b值为2，一个为3.

```bash
int a=2,b=a++;
int a=2,b=++a;
```

##### 继承

子类的构造函数会默认调用父类无参构造函数

#### Opengl

gl是核心库，glu是实用库，glut是实用工具库

[这里](<https://blog.csdn.net/z_dmsd/article/details/70949102>)有关于opengl有用的解释

glext.h是各个厂家写的扩展库

##### ubuntu安装glfw

```bash
sudo apt-get install cmake xorg-dev libglu1-mesa-dev
```



