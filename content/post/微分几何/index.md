+++
author = 'libo'
date = '2025-08-15T16:16:51+08:00'
draft = false
image =  "image.png"
title = '微分几何'

+++



<!--more-->

### 经典微分几何
#### 定理1

参数t是弧长参数s，的充分必要条件是$\|r^{'} \left(t\right)\|=1$

proof: $\|r^{'} \left(t\right)\|dt=ds$
本文以下未加说明，参数全部是弧长参数
#### 有向正则曲线

* $t\left(u\right)$三次可微

* $t^{‘}$不为0

  
#### 曲线的主法向量
$r^{``}\left(s\right)$是曲线的主法向量，模长为曲率k(s是弧长)
#### frenet标架场和挠率
记$r^{‘}=\alpha,r^{“}=k\beta,\gamma=\alpha\times\beta$,则$\alpha,\beta,\gamma$是frenet标架场，$\|\gamma^{‘}\|=\tau$为挠率
#### frenet矩阵

$$\left(\begin{matrix}\
\alpha^{'}\\\\
\beta^{'}\\\\
\gamma^{‘}
\end{matrix}\right)=\left(\begin{matrix}
0&k&0\\\\
-k&0&\tau\\\\
0&-\tau&0
\end{matrix}\right)\left(\begin{matrix}
\alpha\\\\
\beta\\\\
\gamma
\end{matrix}\right)$$
其实对于正交坐标架他的微分矩阵都是反对称的

有如下命题:


$A^TA=I,dA^TA+A^TdA=0,A=I,dA+dA^T=0$ **

#### 曲线基本定理
在3维空间中给定矩阵F，坐标架$\alpha,\beta,\gamma$（不一定正交，不一定单位模长）
$$d\left(\begin{matrix}
\alpha\\\\
\beta\\\\
\gamma
\end{matrix}\right)=F\left(\begin{matrix}
\alpha\\\\
\beta\\\\
\gamma
\end{matrix}\right)ds$$
这是线性常微分方程，给定初始$\alpha^0,\beta^0 \gamma^0$.则曲线唯一确定（相差一个刚体变换）。

#### 隐函数定理

对于方程组$0=y_i\left(x_j...\right),n \le i>0 ,m \le j>0,m>n$,若有,$\frac{\partial \left(y_1,y_2..y_n\right)}{\partial \left(x_1,..x_n\right)}$满秩，那么$x_1,..x_n$可以表示成$x_{n+1}...x_m$的函数

*proof *:

$\frac{\partial y}{\partial x}dx=0$,得到$\frac{\partial \left(y_1,y_2..y_n\right)}{\partial \left(x_1,..x_n\right)}\left(dx_1..\right)=-\frac{\partial \left(y_1,y_2..y_n\right)}{\partial \left(x_{n+1},..x_m\right)}\left(dx_{n+1}...\right)$,

左边存在逆矩阵，乘到右边，再积分即得证。

#### 正则曲面

曲面$r\left(u,v\right)$的$r_{u}$和$r_{v}$线性无关[^1]

#### 曲面的第一基本形式

曲面的度量张量称为第一基本形式$$\left(\begin{matrix}
E&F\\\\
F&G
\end{matrix}\right)$$或者$ds^2=Edu^2+2Fdudv+Gdv^2$
度量g还有重要的写法是
$$A=\left(\begin{matrix}
\sqrt{E}&\frac{F}{\sqrt{E}}\\\\
0&\sqrt{G-\frac{F^2}{E}}
\end{matrix}\right),g=A^TA$$
用来求平均曲率和gauss曲率。
#### 曲面上正交参数的存在性（不是等温坐标系）[^2]

#### 曲面的第二基本形式

设n为曲面点p处的法向量($du\wedge dv$),那么$<d^2 r,n>$为第二基本形式，因为$<dr,n>=0$,所以$<d^2 r,n>=-<dr, dn >$

#### 曲面上曲线的法曲率

$<d^2 r\left(s\right),n>$称为曲线的法曲率，s为弧长参数.

经过化简的到$$\frac{Ldu^2+2Mdudv+Ndv^2}{ds^2}=\frac{Ldu^2+2Mdudv+Ndv^2}{Edu^2+2Fdudv+Gdv^2}$$

由式子知道法曲率只跟切向量(du,dv)相关，所以我们可以考虑由法截面截取的曲线的法曲率。

#### 主曲率和主方向

每点的法曲率的最大值和最小值称为该点的两个主曲率，两个方向称为该点的主方向。

#### 平均曲率和gauss曲率

两个主曲率之和是平均曲率，两个主曲率之积是gauss曲率。gauss曲率在黎曼流形上的推广是截面曲率。

#### 曲面上自然标架场和微分

曲面上的自然标架場是$\{ r_1,r_2,n  \}$,记第一基本形式的张量为$g_{\alpha \beta}$，它的逆是$g^{\alpha \beta}$,第二基本形式张量为$b_{\alpha \beta}$,它的逆是$b^{\alpha \beta}$,

如果命$b_{\alpha}^{\gamma}=b_{\alpha t}g^{t \gamma}$为指标的上升,以后指标的上升与下降都是这样的关系。

那么自然标架的微分
$$\frac{\partial r_{\alpha}}{\partial u^{\beta}}= b_{\alpha \beta}n+r_{\gamma}\Gamma^{\gamma}_{\alpha \beta}$$和


$$\frac{\partial n}{\partial u^{\beta}}=-b_{\beta}^{\gamma}r_{\gamma}$$

计$$\Gamma^{\gamma}_{\alpha \beta}=g^{\gamma i}\Gamma _{i\alpha \beta}$$（指标的上升）,

$$\Gamma _{\gamma \alpha \beta}=\frac{1}{2}\left(\frac{\partial g _{\alpha \gamma}}{\partial u^{\beta}}+\frac{\partial g _{ \gamma \beta}}{\partial u^{\alpha}}-\frac{\partial g _{\alpha \beta}}{\partial u^{\gamma}}\right)$$


$$\Gamma^{\gamma}_{\alpha \beta}=g^{\gamma i}\Gamma _{i\alpha \beta}=\frac{1}{2}g^{\gamma i}\left(\frac{\partial g _{\alpha \gamma}}{\partial u^{\beta}}+\frac{\partial g _{ \gamma \beta}}{\partial u^{\alpha}}-\frac{\partial g _{\alpha \beta}}{\partial u^{\gamma}}\right)$$
由上知自然标架的christoffel符号是內蕴的
证明见微分几何初步(陈维桓)P.128

#### 曲面唯一性定理 
（在刚体变换意义下）在$E^3$中，第一基本形式和第二基本形式决定了唯一一个曲面

自然标架场的微分方程组是

$$d\left(\begin{matrix}
r _{1}\\\\
r _{2}\\\\
n
\end{matrix}\right)=\left(\begin{matrix}\left(\Gamma^{\gamma} _{1 \beta}r _{\gamma}+b _{1 \beta}n\right)d\beta\\\\
\left(\Gamma^{\gamma} _{2 \beta}r _{\gamma}+b _{2 \beta}n\right)d\beta\\\\
\left(-b^{\gamma} _{\beta}r _{\gamma}\right)d\beta
\end{matrix}\right)$$
这是个偏微分方程组，如果给定第一基本量，和第二基本量，再给定初始条件，和$$dd\left(\begin{matrix}
r _{1}\\\\
r _{2}\\\\
n
\end{matrix}\right)=0$$,(dd是二次外微分，化简得到Gauss-Codazzi方程)，那么存在唯一的自然标架場是方程的解。

#### Gauss-Codazzi方程

记$R^{\delta} _{\alpha\beta\gamma}=\frac{\partial \Gamma^{\delta} _{\alpha\gamma}}{\partial u^{\beta}}-\frac{\partial \Gamma^{\delta} _{\alpha\gamma}}{\partial u^{\beta}}+\Gamma^{\eta} _{\alpha\beta}\Gamma^{\delta} _{\eta\beta}-\Gamma^{\eta} _{\alpha\gamma}\Gamma^{\delta} _{\eta\beta}$,同理$R _{\delta\alpha\beta\gamma}=g _{\delta\eta}R^{\eta} _{\alpha\beta\gamma}$
那么$R^{\delta} _{\alpha\beta\gamma}=b _{\alpha\beta}b _{\gamma}^{\delta}-b _{\alpha\gamma}b _{\beta}^{\delta}$或者$R _{\delta\alpha\beta\gamma}=-\left(b _{\delta\beta}b _{\alpha\gamma}-b _{\delta\gamma}b _{\alpha\beta}\right)$称为gauss方程，
$\frac{\partial b _{\alpha\beta}}{\partial u^{\gamma}}-\frac{\partial b _{\alpha\gamma}}{\partial u^{\beta}}=b _{\beta\delta}\Gamma^{\delta} _{\alpha\gamma}-b _{\gamma\delta}\Gamma^{\delta} _{\alpha\beta}$称为Codazzi方程.曲面方程的存在的充分必要条件是满足Gauss-codazzi方程。

#### gauss theorem
求$\frac{Ldu^2+2Mdudv+Ndv^2}{Edu^2+2Fdudv+Gdv^2}$,的最大值和最小值之积是$\frac{|b|}{|g|}=|b||g^{-1}|$,因为$R _{\delta\alpha\beta\gamma}=g _{\delta\eta}R^{\eta} _{\alpha\beta\gamma}$，可以看出gauss曲率的值是等矩不变量。[^3]

#### 测地曲率，测地挠率

在曲面S上有曲线$u^{\alpha}\left(s\right)$,在曲线上取正交正规坐标架

$e _{i}$,其中$e _{1}=\frac{dr\left(s\right)}{ds}$,$e _{2}=n\times e _{1}$,$e _{3}=n$,

对坐标架微分得到 

$$d\left(\begin{matrix}\
e _{1}\left(s\right)\\\\
e _{2}\left(s\right)\\\\
e _{3}\left(s\right)
\end{matrix}\right)=M\left(\begin{matrix}\
e _{1}\left(s\right)\\\\
e _{2}\left(s\right)\\\\
e _{3}\left(s\right)
\end{matrix}\right)ds$$,由上知M是反对称矩阵，那么$M _{12}$称为测地曲率，$M _{23}$称为测地挠率，$M _{13}$是曲线的法曲率.

$M _{12}=\left(n\times e _1\right)*e^{`} _1=\left(n,e _1,e^{'} _1\right)$,其中三个量都是保长不变量，所以测地曲率是保长不变量。

#### 测地线

曲面上测地曲率等于0的曲线

#### 曲面上向量场的平行移动

#### Gauss-Bonnet公式





在黎曼流形上当度量张量不变时，外微分的积分可以按正常积分计算，但外积符号$\wedge$不可丢。

#### Stokes 公式

#### Poincare Lemma

闭形式但不是恰当形式的例子:

定义在$R^2-0$上的1-form   $\eta=\frac{xdy-ydx}{x^2+y^2}$沿不同闭曲线的积分

定义在$R^3-0$上的2-form   $\eta=\frac{xdy\wedge dz+ydz\wedge dx+zdx\wedge dy}{\left(x^2+y^2+z^2\right)^{\frac{3}{2}}}$



### 现代微分几何

#### Definition（流形的凸性）

可定向流形流形的方向是单射。（准确的说可定向流形有一个类似gauss映射的推广函数，它是单射）

#### 梯度算子

梯度算子并不是微分算子，它是$C^{\infty}\left(M\right)\to TM$即光滑函数到切空间的映射。

他有两个作用，第一个就是定义所说的可以通过度量张量来表示$X\left(f\right)$,

第二个作用是梯度算子的结果是所有$|X|_g=1,X\in TM$,使得$X\left(f\right)$最大的切方向。

#### Ricci flow

给一个黎曼流形M,配有黎曼度量$g _{0}$.

假设度量矩阵g是关于t的函数，且这个函数由常微分方程组$\frac{dg _{ij}}{dt}=-2 R _{ij}$，初始条件$g\left(0\right)=g _0$确定。$R _{ij}$是Ricci tensor.那么$g\left(t\right)$是Ricci flow

#### 黎曼流形上的散度算子

[这里](https://zhuanlan.zhihu.com/p/105097175?utm_source=qq)

[这里](https://blog.csdn.net/weixin_30415801/article/details/96829679)

laplace算子在流形上的推广为拉普拉斯-贝尔特拉米算子,在微分形式上的推广是拉普拉斯–德拉姆算子。

[拉普拉斯-贝尔特拉米算子]([https://baike.baidu.com/item/%E6%8B%89%E6%99%AE%E6%8B%89%E6%96%AF-%E8%B4%9D%E5%B0%94%E7%89%B9%E6%8B%89%E7%B1%B3%E7%AE%97%E5%AD%90/19136598?fr=aladdin](https://baike.baidu.com/item/拉普拉斯-贝尔特拉米算子/19136598?fr=aladdin))

#### Stokes公式

在Rudin的一书中有Stokes公式的[证明](https://zhuanlan.zhihu.com/p/23870023)

#### Poincare引理







[^1]: 概括而言正则流形是每点切空间和流形维数相同
[^2]: 维数大于等于3的黎曼流形不一定存在正交参数系。正交坐标系要求第一基本形式F=0，等温坐标系要求F=0,E=G(保角).

[^3]: 內蕴几何是研究等矩变换不变量的几何，但是等矩变换不是保持度量g一直不变
