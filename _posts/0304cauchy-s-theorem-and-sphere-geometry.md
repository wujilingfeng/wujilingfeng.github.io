---
title: cauchy's theorem and sphere geometry
tags: 数学
categories: 学习笔记
date: 2019-03-04 16:40:59
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});
</script>
<script type="text/javascript" async
  src="https://wujilingfeng.top/MathJax/MathJax.js?config=TeX-AMS_CHTML">
</script>


<!--more-->

#### 球面几何
Instead of polyhedra,we can study the spherical image of polyhedra's angle,which is the effective and popular method.
球面多边形以大圆弧作为直线

##### 命题(强对偶性质)
map the angle of polyhedra to the unit sphere by gauss mapping,then the angle of the spherical image is related to the angle of polyhedra satisfying the following fomulation
$\theta = \pi-\sigma $

##### 命题

球面三角形的三个角为$\theta_i$,则面积为$\sum\limits_i \theta_i -\pi$

##### 推论

球面多边形的角度为$\theta_i$,则多边形的面积为$\sum\limits_i\theta_i-\left(n-2\right)\pi$
##### Proposition

the triangle on sphere has three edges $a,b,c$,then $a+b\le c$
##### Corollary 
$a+b+c\le 2\pi$
* $two-dimensial\ manifold$

#### 平面三角形

对于平面三角形$\Delta ABC$，模掉刚体变换（彼此间相差一个刚体变换视为同一个三角形），则此三角形可以由三个点$A\left(0,0\right),B\left(x_1,0\right),C\left(x_2,x_3\right),x_1>0$确定。

$\angle BAC=\arccos\frac{x_1x_2}{x_1\sqrt{x_2^2+x_3^2}}$

$\angle ABC=\arccos\frac{x_1\left(x_1-x_2\right)}{x_1\sqrt{\left(x_1-x_2\right)^2+x_3^2}}$

以及边长$AB=x_1,AC=\sqrt{x_2^2+x_3^2},BC=\sqrt{\left(x_1-x_2\right)^2+x_3^2}，AC=\sqrt{\left(x_1-x_2\right)^2+x_3^2}$

以下结论立得：

* 所有三角形构成三维流形
* 相似三角形（角度对应相等视为一个）构成二维流形
* （余弦定理）$BC=AB^2+AC^2-2AB*BC\cos{\angle BAC}$
* 对于三角形$\Delta ABC$,两边长度不变，其夹角增大，则第三边增大

##### 推论

对于polygon,保持n-1个边长度不变，增大这些边的夹角，则最后一个边长增大

#### 回到球面几何

对于单位球面，一个三角形可以由三个点确定$A\left(1,0,0\right),B\left(\cos{\theta},\sin{\theta},0\right),C\left(\sin{\varphi}\cos{\theta_1},\sin{\varphi}\sin{\theta_1},\cos{\varphi}\right)$

then three sides' length is $a=\theta, b=\arccos{sin{\varphi}\cos{\theta}},c=\arccos{\sin{\varphi}\left(\cos{theta}\cos{\theta_1}+\sin{\theta}\sin{\theta_1}\right)}$

three normal vectors of polar plane are $\left(0,0,0\right)$

$\frac{1}{\sqrt{\cos{\varphi}^2+\sin{\varphi}^2\sin{\theta_1}^2}}\left(0,-\cos{\varphi},\sin{\varphi}\sin{\theta_1}\right)$

$\frac{1}{\sin{\theta}^2\cos{\varphi}^2+\cos{\theta}^2\cos{\varphi}^2+\sin{\varphi}^2\left(\cos{\theta}\sin{\theta_1}-\sin{\theta}\cos{\theta_1}\right)^2}\left(\sin{\theta}\cos{\varphi}-\cos{\theta}\cos{\varphi}+\sin{\varphi}\left(\cos{\theta}\sin{\theta_1}-\sin{\theta}\cos{\theta_1}\right)\right)$

##### Proposition(cosine theorem)

$\cos{\angle A}=\frac{\sin{\varphi}\sin{\theta_1}}{\sqrt{\cos{\varphi}^2+\sin{\varphi}^2\sin{\theta_1}^2}}=\frac{\cos{c}-\cos{a}\cos{b}}{\sin{a}\sin{b}}$

##### Corollary

* 三边长唯一确定三角形
* 由强对偶性，三个角唯一确定三角形
* 模掉相似三角形，仍为三维流形
* 对于三角形$\Delta ABC$,保持两边不变，其夹角增大，则第三边增大
* 对于polygon,保持n-1个边长度不变，增大这些边的夹角，则最后一个边长增大