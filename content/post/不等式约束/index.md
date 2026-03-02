+++
author = 'libo'
date = '2026-02-10T10:49:20+08:00'
math= true
draft = false
image = 'jiuwei.png'
title = '不等式约束'
+++

#### 如何求解不等式约束是否有解

有如下不等式约束n个$a_ix> \left(=\right)b_i$,(每个既可以是>，也可以是$\ge$),想要知道它是否有解。

把上述不等式约束写为$Ax>\left(=\right)B$,则令$\lambda_i \ge 0,i\in 0..(n-1)$ , $A^T\lambda=0$,  $\max_{\lambda} B^T\lambda$

则不等式是否有解等价于 $0>\left(=\right) \max_{\lambda} B^T\lambda $是否恒成立。

如果$\max_{\lambda} B^T\lambda$ 是大于0的数，则无解。

如果 $\max_{\lambda} B^T\lambda$等于0，则看是否是$>$还是$\ge$, 前者无解，后者有解。至于到底是$>$ 还是$\ge$,那就要看那些$\lambda_i>0$的不等式了，如果那些$\lambda_i>0$的不等式有一个是$>$，那么判断的就是$0> \max_{\lambda} B^T\lambda$,否则就是$0 \ge \max_{\lambda} B^T\lambda$

#### 具体算法

只需要把$A^T\lambda =0$ 求解为$\lambda=A_b\lambda_{re}+b$, 其中$\lambda_{re}$是自由变量，然后代入$\max_{\lambda} B^T\lambda$,即可。

#### 不等式减少变量的手段

假设齐次不等式约束中有一个齐次的不等式约束$a_ix >0$ ,那么可以直接令$a_ix=1$,因为这是言而易见，如果存在解，那么这个等式约束也是成立的。所以根据这个等式可以减少一个变量。如果是$a_ix\ge 0$,那么就可以分类讨论，分别令$a_ix=0$和$a_ix=1$,即可完成减少变量。



任何非齐次不等式约束都可以通过坐标变换转化为齐次不等式，，如$Ax+b>0$ ,那么存在$A^`y>0$ 。

