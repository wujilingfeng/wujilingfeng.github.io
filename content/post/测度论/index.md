+++
author = 'libo'
date = '2025-08-15T17:29:37+08:00'
math= true
draft = false
image = "image.png"
title = '测度论'
+++

<!--more-->

这是[pdf](./probability.pdf)

以下空间均假设为概率空间，也就是总测度为1。

pdf中定义了随机变量，那么随机变量x期望的定义是$E\left(x\right)=\int_{-\infty}^{+\infty} xd\mu\left(x\right)$。

由期望的定义知道如下结论

* 如果随机变量x,y相互独立，那么$E\left(xy\right)=E\left(x\right)E\left(y\right)$，这是因为Fubini定理。

协方差的定义是$E\left(\left(x-E\left(x\right)\right)\left(y-E\left(y\right)\right)\right)=\int_{-\infty}^{+\infty} \left(x-\overline{x}\right)\left(y-\overline{y}\right)d\mu\left(x,y\right)$,由上面的定义知道协方差的定义需要知道联合概率密度$\mu\left(x,y\right)$(联合测度)。

但是在实际应用中使用者(统计领域无法像传统数学一样严禁)的不严谨往往导致人们忽略其定义，从而导致其他知识点和定理的无法贯通。有些例子甚至是错误的。

且看下面的例子:

现有采样数据$$y_1=[1,2]\\\\   y_2=[4,5]\\\\  y_3=[7,8]\\\\ y_4=[1,1]\\\\ y_5=[3,4]$$,那么期望
$$\mu_1=\frac{(1+4+7+1+3)}{5}=3.2\\\\ \mu_2=\frac{(2+5+8+1+4)}{ 5}=4$$，协方差为
$cov\left(x_1,y_2\right)=\frac{(1-3.2)(2-4)+(4-3.2)(5-4)+(7-3.2)(8-4)+(1-3.2)(1-4)+(3-3.2)(4-4)}{5}$

在这个例子中联合测度已经默认这样定义了$y_i=\frac{1}{5}$,其他的则为0。


在下面这个例子中，则完全错误：[错误的例子](https://zhidao.baidu.com/question/689931018470753924.html)
