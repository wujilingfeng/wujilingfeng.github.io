+++
author = 'libo'
date = '2026-08-10T09:04:57+08:00'
math= true
draft = false
title = '新的曲面平滑算法'
image = "image.png"
+++

# 新的曲面平滑算法

## 1. 半边法向量定义

设四个顶点为 $p_0,p_1,p_2,p_3$，定义：

$$
e=p_1-p_0,\qquad a=p_2-p_0,\qquad b=p_3-p_0
$$

定义半边向量函数：

$$
N(e)=\frac{(e\times a)\times(b\times e)}{\|e\times a\|\|b\times e\|}
$$

利用三重积恒等式：

$$
(e\times a)\times(b\times e)=\bigl(e\cdot(b\times e)\bigr)a-\bigl(a\cdot(b\times e)\bigr)e
$$

第一项为零，并且：

$$
a\cdot(b\times e)=e\cdot(a\times b)
$$

因此：

$$
(e\times a)\times(b\times e)=-\bigl(e\cdot(a\times b)\bigr)e
$$

令：

$$
c=a\times b,\qquad s=c^Te
$$

则分子为：

$$
-se
$$

定义：

$$
M_a=\|a\|^2I-aa^T,\qquad M_b=\|b\|^2I-bb^T
$$

则：

$$
A=e^TM_ae=\|e\times a\|^2
$$

$$
B=e^TM_be=\|b\times e\|^2
$$

令：

$$
D=\sqrt A\sqrt B
$$

最终得到：

$$
N(e)=-\frac{s}{D}e
$$

---

## 2. 雅可比矩阵

令：

$$
f(e)=\frac{s}{D}e
$$

则：

$$
N=-f
$$

因此：

$$
J_N=-\frac{\partial f}{\partial e}
$$

其中：

$$
\frac{\partial(se)}{\partial e}=ec^T+sI
$$

又因为：

$$
\frac{\partial A}{\partial e}=2M_ae,\qquad
\frac{\partial B}{\partial e}=2M_be
$$

所以：

$$
\frac{\partial D}{\partial e}
=D(\frac{M_ae}{A}+\frac{M_be}{B})
$$

由商法则：

$$
J_N=-\frac{s}{D}I-\frac{ec^T}{D}
+\frac{s}{D}e(\frac{M_ae}{A}+\frac{M_be}{B})^T
$$

进一步定义：

$$
M_e=\|e\|^2I-ee^T
$$

得到：

$$
J_a=\frac{\partial N}{\partial a}
=-\frac{e(b\times e)^T}{D}
+\frac{s}{D}e(\frac{M_ea}{A})^T
$$

$$
J_b=\frac{\partial N}{\partial b}
=-\frac{e(e\times a)^T}{D}
+\frac{s}{D}e(\frac{M_eb}{B})^T
$$

---

## 3. 三角网格中的能量梯度

设中心顶点为 $v$，邻接顶点为 $v_i$。

对于邻接半边：

$$
he=(v_i,v),\qquad e=v-v_i
$$

对应两个三角形的另外两个顶点记为 $p_2,p_3$，由上述公式计算 $N(he)$。

定义顶点能量：

$$
E(v)=\|\sum_iN(e_i)\|^2
$$

记：

$$
\bar N(v)=\sum_iN(e_i)
$$

对于顶点 $v$ 自身能量：

$$
\nabla_pE(v)=2(\sum_iJ_{N_i})^T\bar N(v)
$$

邻接顶点能量同样会受到 $p_v$ 的影响。由于半边方向满足：

$$
e=v-v_i
$$

因此对邻接边贡献：

$$
\nabla_pE_1(v)=2\sum_{he}
J_{N_{he}}^T(\bar N(v)-\bar N(v_i))
$$

其中 $he=(v_i,v)$。

---

## 4. 环状边贡献

对于二环邻域中的半边：

$$
he=(v_j,v_i),\qquad e=v_i-v_j
$$

如果 $v$ 是该半边对应三角形中的第三个顶点，则：

$$
K_{ij}=\frac{\partial N_h}{\partial p_v}=J_a
$$

对应梯度贡献：

$$
\nabla_pE_2(v)=2\sum_{he}K_{ij}^T(\bar N(v_i)-\bar N(v_j))
$$

最终：

$$
\nabla_pE(v)=\nabla_pE_1(v)+\nabla_pE_2(v)
$$

---

## 5. 退化情况与边界处理

当：

$$
e\times a=0\quad\text{或}\quad e\times b=0
$$

表示三角形退化，此时分母为零，应跳过该半边梯度计算。

对于边界半边，由于缺少相邻三角形，可以采用：

1. 直接跳过边界半边；
2. 使用单位化边方向近似 $N(he)$；
3. 构造虚拟顶点形成虚拟三角形，使 $N(he)$ 可以继续计算。

若采用虚拟顶点，可利用相邻边界半边相关顶点的重心作为虚拟点位置，细节则各自决定即可。
