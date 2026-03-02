+++
author = 'libo'
date = '2026-03-02T15:02:11+08:00'
math= true
draft = false
image = 'wanxia.png'
title = '带约束的凸优化'
+++



#### 带不等式约束的梯度下降法

$\min_{x}f\left(x\right)$ $st.Ax\le b$

现假设$x_0$是满足不等式约束的点，按照梯度下降法它的梯度是$df\left(x_0\right)$,步长是$\alpha$。

检查$x_1=x+\alpha d f\left(x_0\right)$时，$Ax_1\le b$是否成立，如果不满足减小$\alpha$，令$\alpha_1$是0与$\alpha$之间 满足不等式约束的最大值。

那么此时$x_1=x+\alpha_1 df\left(x_0\right)$, 对于某些不等式约束刚好满足等式，找到那些满足等式需求的约束$A_{block}x_1= b_{block}$,  此时梯度方向对这些约束形成的空间进行投影，得到$\overline{df\left(x_0\right)}$, (也所谓投影也就是$A_{block} df\left(x_0\right)=A_{block}A^T_{block}\lambda$,且$\overline{df\left(x_0\right)}=A^T_{block}\lambda$) .



此时再令 $\alpha_2= \alpha -\alpha_1,x2=x_1+\alpha_2 \overline{d f \left(x_0\right)}$

检查$x_2$是否满足约束$Ax_2\le b$,  如果不满足，缩小$\alpha_2$, 取0和$\alpha_2$之间满足不等式约束的最大值，记为$\alpha_3$,此时$x_3=x_2+\alpha_3 \overline{df\left(x_0\right)}$ 就是一次梯度下降法的完整过程。继续下一次梯度下降。



#### 带不等式和等式约束的梯度下降法

* 方法一，把等式消除，也就是利用等式消除变量个数，也就是用自由变量代替里面其他变量

* 方法二，对于上面的的带不等式约束的算法里面的$df\left(x_0\right)$和$\overline{df\left(x_0\right)}$也同时做等式空间投影即可。
