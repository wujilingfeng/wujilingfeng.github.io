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

如果 $\max_{\lambda} B^T\lambda$等于0，则看是否是$>$还是$\ge$, 前者无解，后者有解。只有到底是$>$ 还是$\ge$,那就要看哪些$\lambda_i>0$的不等式组成了，如果那些$\lambda_i>0$的不等式有一个是$>$，那么就是看$0> \max_{\lambda} B^T\lambda$,否则就是$0 \ge \max_{\lambda} B^T\lambda$
