---
title: Alexandrove thm
tags: 数学
categories: 学习笔记
date: 2019-03-20 17:45:45
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});
</script>
<script type="text/javascript" async
  src="https://wujilingfeng.top/MathJax/MathJax.js?config=TeX-AMS_CHTML">
</script>


本文介绍Alexandrove 定理

<!--more-->

对于任意两个多边形，它们总有相同多个平行边，因为可以把的点视为退化边。

对于两个凸多边形$P_1,P_2$，若其中一个通过平行移动，成为另一个多边形的真子集，则称其可以放置到另一个多边形中(两个多边形全等，也视为不能完全放置到对方当中。)

#### Definition

定义一个凸多面体P的“面“是，它的支撑面与P的交集。[^1]

[^1]: 对于任意两个多面体，他们总有相同多个平行“面“，因为支撑面上的点，边也视为退化的面

---

#### 定理1

两个凸多面体$P_1,P_2$之间有同胚保距映射$\varphi$,对于$P_1$的面$f_1$,$\varphi\left(f_1\right)$在$P_2$中与多个平面相交，并由此$\varphi\left(f_1\right)$划分为多个平面。同理对于$P_2$的平面$f_2$，$\varphi^-\left(f_2\right)$也被划分为多个平面。则这些平面都是凸的，且这两个多面体的新面一一对应，且全等。

*Proof*

#### Lemma 1

如果多边形$P_1$的边总比$P_2$平行对应的边长要短，则$P_1$可以放到$P_2$里。

#### Lemma 2

对于凸多边形，若对其一边向其外法向量平移则此凸多边形周长变长

#### Proposition

若凸多边形$P_1$可以放在$P_2$里，则$P_2$的周长大于$P_1$

*Proof*

我们总可以移动$P_1$的边朝外法向量平移，使其顶点位于$P_2$，则以上结论立得。

#### Lemma 3

若在角O中有两条折线，向角张开的方向弯曲，记为$P_1,P_2$。若$P_1$有一些线段位于$P_2$上方(靠近O点)，则在$P_1$这些线段中，有一条小于$P_2$中对应平行的线段。

#### Lemma 4

若$P_1$,$P_2$不可以放置到对方中，则$P_1$边长相对于$P_2$对应边长，增加记为+，减少记为-，则符号变化大于等于4或者为0,。

#### Lemma 5

如果对于多面体$P_1,P_2$,他们对应平行的面不能相互放置在对方当中，则这两个多面体全等。

*Proof*

考虑$P=P_1\oplus P_2$[^2]，如前所述，$P_1,P_2$所对应的"面",可能是点，边，面。

* P是凸体
* P的面由$P_1,P_2$的minkowski和生成，且一一对应。

对于P的每个正常面$f_3$，其由$f_1\in P_1,f_2\in P_2$生成，这三个面由相同数个平行边，若$f_2$比$f_1$对应边长，则在$f_3$对应边上记+,短记-。

若$f_1\neq f_2$，则由Lemma 4知其面周围至少发生4次符号变化。这样P上有一个被标记符号的网格，每个面周围至少发生4此变化，这与[《cauchy theorem and sphere geometry》](https://wujilingfeng.top/2019/03/04/cauchy-s-theorem-and-sphere-geometry/),proposition 4矛盾。

[^2]: 代表minkowski和

由Lemma 5可以得到下面的定理

#### Theorem 1

对于这样的单调函数f,定义域为凸多边形Q，满足这样的性质，若$Q_1,Q_2\in Q$,$Q_1$能放在$Q_2$中，$f\left(Q_1\right)<f\left(Q_2\right)$,上述函数空间记为F，则对于两个凸面体$P_1,P_2$他们有相同数量的平行面$Q_1^i,Q_2^i$,且$\exists f_i\in F$,使得$f_i\left(Q_1^i\right)=f_i\left(Q_2^i\right),\forall i$,则$P_1,P_2$全等

#### Corallary 1(Minkowski uniqueness theorem)

在$R^n$空间，若有一个凸多面体P，保持其每个面的面积相等，法向量相等，对其变形得到$P'$,则$P=P'$

#### Alexandrov Theorem

在$R^n$空间，若有一个曲面（无限延伸）Q，k个平面，他们围成一个闭或开的凸多面体。保持k个平面每个面的面积相等，法向量相等，对其变形得到$P'$,则$P=P'$

*Proof*

把Q抽象视为连通的面，则考虑$P_1=P\oplus P‘$,得到球面一个网格，这个网格每个面（除了Q）周围发生4次符号变化。这与[《cauchy theorem and sphere geometry》](https://wujilingfeng.top/2019/03/04/cauchy-s-theorem-and-sphere-geometry/),proposition 4矛盾

---

### Minkowski 存在性定理

##### Lemma 6

