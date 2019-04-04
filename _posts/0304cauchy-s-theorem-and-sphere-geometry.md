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

##### 命题 1

球面三角形的三个角为$\theta_i$,则面积为$\sum\limits_i \theta_i -\pi$

##### 推论1

球面多边形的角度为$\theta_i$,则多边形的面积为$\sum\limits_i\theta_i-\left(n-2\right)\pi$
##### Proposition 2

the triangle on sphere has three edges $a,b,c$,then $a+b\le c$
##### Corollary 2
$a+b+c\le 2\pi$
* $three-dimensial\ manifold$

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

##### 推论 3

对于polygon,保持n-1个边长度不变，增大这些边的夹角，则最后一个边长增大

#### 回到球面几何

对于单位球面，一个三角形可以由三个点确定$A\left(1,0,0\right),B\left(\cos{\theta},\sin{\theta},0\right),C\left(\sin{\varphi}\cos{\theta_1},\sin{\varphi}\sin{\theta_1},\cos{\varphi}\right)$

then three sides' length is $a=\theta, b=\arccos{sin{\varphi}\cos{\theta}},c=\arccos{\sin{\varphi}\left(\cos{\theta}\cos{\theta_1}+\sin{\theta}\sin{\theta_1}\right)}$

three normal vectors of polar plane are $\left(0,0,0\right)$

$\frac{1}{\sqrt{\cos{\varphi}^2+\sin{\varphi}^2\sin{\theta_1}^2}}\left(0,-\cos{\varphi},\sin{\varphi}\sin{\theta_1}\right)$

$\frac{1}{\sin{\theta}^2\cos{\varphi}^2+\cos{\theta}^2\cos{\varphi}^2+\sin{\varphi}^2\left(\cos{\theta}\sin{\theta_1}-\sin{\theta}\cos{\theta_1}\right)^2}\left(\sin{\theta}\cos{\varphi}-\cos{\theta}\cos{\varphi}+\sin{\varphi}\left(\cos{\theta}\sin{\theta_1}-\sin{\theta}\cos{\theta_1}\right)\right)$

##### Proposition(cosine theorem)

$\cos{\angle A}=\frac{\sin{\varphi}\sin{\theta_1}}{\sqrt{\cos{\varphi}^2+\sin{\varphi}^2\sin{\theta_1}^2}}=\frac{\cos{c}-\cos{a}\cos{b}}{\sin{a}\sin{b}}$

##### Corollary 4

* 三边长唯一确定三角形
* 由强对偶性，三个角唯一确定三角形
* 模掉相似三角形，仍为三维流形
* 对于三角形$\Delta ABC$,保持两边不变，且维持凸性，其夹角增大，则第三边增大[^1] 
* 对于polygon,保持n-1个边长度不变，增大这些边的夹角，则最后一个边长增大

[^1]: 如果不维持凸性，不为真，以下同理

##### Proposition 3

给定球面多边形P，若保持边长不变，维持凸性，对其变形，得到$P'$。那么这两个多边形对应的角度变化有两种情况，一种增大，记录为+,一种减少,记录为-。绕$P'$一周，这种符号会交替出现，且交替次数大于等于4.

*Proof*

容易观察到，这种交替此数必为偶数。我们只需证明其交替次数不为2.

假设角$A_1 .... A_m$都是+,$A_{m+1}....A_n$都是-.

如图：

{% asset_img proposition.jpg picture%}

则连接$A_{m+1}A_{n}$,由上面命题知，$A_{m+1}A_{n}$比原边长大，又小，矛盾。

#### Corallary 5

对于多面体角P，若维持这些多面体角的平面角度不变且维持凸性，对P变形得到$P'$,则其对应的二面角变化分别用+表示增加，-表示减少，则符号变化次数大于等于4或者为0.

#### Euler formula

对于一个凸多面体（同胚与球面），取上面一些边，则其满足欧拉公式v+f-e=2

举以下几个例子

{% asset_img lemma.jpg picture%}

红色线为取的线。

图1，有v=4,e=3,f=1,蓝色涂抹的就是面，而且这是个6边形，因为你沿着蓝色涂抹的区域的边界走，每条边经过两次。

图2，有v=4,e=4,f=2,红色多边形里外是两个面。均是四边形。

其严谨的叙述如下：

在球面上给定一个网格，总存在这样的看法[^1]，使得这个网格诱导的边，面，点满足欧拉方程。

[^1]: 这些网格把球面分割成不连通的区域，则这每个区域视为一个面，沿一个面的边缘遍历一周，经过的边数为n,则称此面为n边形。

#### Lemma 1

假设一个同胚于球的多面体的一些边被标记为-或+，那么当围绕一个点一周，边上符号有变化次数，而这些被标记的边组成一个网。那么网上每个点周围符号变化N，满足以下不等式：

$N<4V-8$

*Proof*

First we observed the total number of sign changes around every vertex is equal to the nume of sign changes around every face.

In accordance with Euler's Theorem,v+f-e=n,we have $2e=\sum i f_i$,$f_i$ represents the numver of i-polygons

then $4v-8=4e-4f=2\sum if_i+4\sum f_i=2f_3+4f_4+6f_5+.....\left(i>2\right)$,the number of sign changes around $f_i$ is less than $[i]$,so the total number N is less than the right-hand side of above fomulation.

#### Proposition 4

$N<4F-8$

#### Corallary (Cauchy Lemma)

Suppose that some edges of a closed convex polyhedron are labeled by plus or minus signs,Sign changes may occur in the labeled edges around a vertex.The claim is as follows:It is impossible to have at least four sign changes (excepted at one vertex)at every vertex.（extracted from Convex Polyhedra）

####  Cauchy rigid theorem

若对于一个凸多面体$P_1$,,维持其每个平面多边形及粘连方式的不变，对其变形。则其保持刚性，即唯一。

*Proof*

由上面的corallary 知，若有二面角不相等，则这个二面角相接触的点周围至少发生4次符号变化，这样我们得到一些网格，而由上面的Cauchy Lemma知道不可能发生。。

#### Cauchy rigid theorem of unbounded polyhedra

若对于一个无界凸多面体P保持每个面不变，粘连方式不变，对其变形得到$P'$，则$P=P'$

*Proof*

我们可以添加一个抽象的点O，并假设P无穷远的边与之相连，这样我们P抽象地同胚与球，假设$P'$与P有二面角不相等，那么这个二面角相接触的点（除了O）其周围符号变化至少发生4次，这与Cauchy Lemma矛盾。









