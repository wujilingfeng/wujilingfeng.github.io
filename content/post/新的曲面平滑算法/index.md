+++
author = 'libo'
date = '2026-08-10T09:04:57+08:00'
math= true
draft = false
title = '新的曲面平滑算法'
image = "image.png"
+++

假设有顶点 $p_0, p_1, p_2, p_3$。令 $e = p_1 - p_0, a = p_2 - p_0, b = p_3 - p_0$。

定义法向量计算函数为：

$$
N(e) = \frac{(e \times a) \times (b \times e)}{\|e \times a\| \|b \times e\|}
$$

下面将梳理整个推导过程，并验证雅可比矩阵。

### 1. 利用向量三重积恒等式化简

利用向量三重积恒等式：

$$
(e \times a) \times (b \times e) = \bigl(e \cdot (b \times e)\bigr) a - \bigl(a \cdot (b \times e)\bigr) e
$$

因为 $e \cdot (b \times e) = b \cdot (e \times e) = 0$，第一项消失；再利用混合积的轮换性：

$$
a \cdot (b \times e) = e \cdot (a \times b)
$$

所以：

$$
(e \times a) \times (b \times e) = -\bigl(e \cdot (a \times b)\bigr) \, e
$$

令：

$$
c = a \times b, \qquad s = c^{\mathsf T} e
$$

则分子为 $-s \, e$。

分母由两个范数组成：

$$
\|e \times a\|^2 = \|e\|^2 \|a\|^2 - (e \cdot a)^2 = e^{\mathsf T} (\|a\|^2 I - aa^{\mathsf T}) e
$$

$$
\|b \times e\|^2 = \|b\|^2 \|e\|^2 - (b \cdot e)^2 = e^{\mathsf T} (\|b\|^2 I - bb^{\mathsf T}) e
$$

定义矩阵：

$$
M_a = \|a\|^2 I - aa^{\mathsf T}, \qquad M_b = \|b\|^2 I - bb^{\mathsf T}
$$

以及标量：

$$
A = e^{\mathsf T} M_a e, \qquad B = e^{\mathsf T} M_b e, \qquad D = \sqrt{A}\sqrt{B}
$$

于是化简得到：

$$
N(e) = -\frac{s}{D} \, e
$$

（注：原推导中存在笔误写为 $N = -\frac{D}{s} e$，根据前后文逻辑已修正为 $-\frac{s}{D} e$。）

### 2. 雅可比矩阵推导

令 $f(e) = \dfrac{s}{D} \, e$，则 $N = -f$，故雅可比矩阵 $J_N = -\dfrac{\partial f}{\partial e}$。

先对 $f = u/v$ 求导，其中 $u = s e$，$v = D$。

$$
\frac{\partial u}{\partial e} = e \frac{\partial s}{\partial e}^{\mathsf T} + s I = e c^{\mathsf T} + s I
$$

$$
\frac{\partial v}{\partial e} = \frac{\partial D}{\partial e}
$$

由 $D = \sqrt{A}\sqrt{B}$，得：

$$
\frac{\partial D}{\partial e} = \frac{\sqrt{B}}{2\sqrt{A}} \frac{\partial A}{\partial e} + \frac{\sqrt{A}}{2\sqrt{B}} \frac{\partial B}{\partial e}
$$

而：

$$
\frac{\partial A}{\partial e} = 2 M_a e, \qquad \frac{\partial B}{\partial e} = 2 M_b e
$$

所以：

$$
\frac{\partial D}{\partial e} = \frac{\sqrt{B}}{\sqrt{A}} M_a e + \frac{\sqrt{A}}{\sqrt{B}} M_b e = D \left( \frac{M_a e}{A} + \frac{M_b e}{B} \right)
$$

利用商法则求导：

$$
\frac{\partial f}{\partial e} = \frac{v \frac{\partial u}{\partial e} - u \frac{\partial v}{\partial e}^{\mathsf T}}{v^2} = \frac{D (e c^{\mathsf T} + s I) - s e \, D \left( \frac{M_a e}{A} + \frac{M_b e}{B} \right)^{\mathsf T}}{D^2}
$$

整理得：

$$
\frac{\partial f}{\partial e} = \frac{e c^{\mathsf T} + s I}{D} - \frac{s}{D} \, e \left( \frac{M_a e}{A} + \frac{M_b e}{B} \right)^{\mathsf T}
$$

因此，最终的雅可比矩阵为：

$$
J_N = -\frac{\partial f}{\partial e} = -\frac{s}{D} I - \frac{e c^{\mathsf T}}{D} + \frac{s}{D} \, e \left( \frac{M_a e}{A} + \frac{M_b e}{B} \right)^{\mathsf T}
$$

### 3. 在离散三角网格中的应用

现考虑离散三角网格，设中心顶点为 $v$，其邻接顶点为 $v_i$。顶点 $v$ 与 $v_i$ 之间存在边，对应的半边定义为 $he = v - v_i$。

对于该半边所在的三角形，设其第三个顶点为 $p_2$；对于与该半边相对的相邻三角形，设其除 $v$ 和 $v_i$ 外的第三个顶点为 $p_3$。同时，记 $v$ 的坐标为 $p_1$，$v_i$ 的坐标为 $p_0$。基于上述定义，半边法向量 $N(he)$ 可由前文给出的函数计算。

定义能量函数：

$$
energy(v) = \left( \sum_{i} N(e_i) \right)^{\mathsf T} \left( \sum_{i} N(e_i) \right)
$$

其中，$p$ 为顶点 $v$ 的位置坐标，$e_i$ 表示所有 $v - v_i$ 的半边。

对 $p$ 求导，得到能量的梯度：

$$
\nabla_p energy(v) = 2 \left( \sum_i J_{N_i} \right)^{\mathsf T} \left( \sum_i N(e_i) \right)
$$

为简化表达，记 $\overline{N(v)} = \sum_i N(e_i)$，则：

$$
\nabla_p energy(v) = 2 \left( \sum_i J_{N_i} \right)^{\mathsf T} \overline{N(v)}
$$

此外，顶点 $v$ 的相邻顶点 $v_i$ 也定义了各自的能量。由于我们是对 $p$（即 $v$ 的位置）进行求导，因此 $v_i$ 能量对 $p$ 的梯度贡献为：

$$
\nabla_p energy(v_i) = -2 J_{N_i} \overline{N(v_i)}
$$

将上述两部分梯度相加，得到系统总能量 $E(v)$ 对位置 $p$ 的总梯度：

$$
\nabla_p E(v) = 2 \sum_i \left( J_{N_i}^{\mathsf T} (\overline{N(v)} - \overline{N(v_i)}) \right)
$$

*注：请注意，这里的求和符号 $\sum$ 位于最外层。*

对于处在边界处的半边，也就是边界边只有一个半边时，有三种办法，第一，这种半边计算跳过。第二，$N(he)$的值直接取he的单位化向量即可。第三种方法，由于这样的半边缺少另一个半边极其三角形，因为我们需要的是两个三角形的点。所以我们可以手动添加一个虚拟点坐标即可。这样$N（he）$就可以计算了，形象的描述这个添加的点坐标和半边的点组成了一个虚拟的三角形。

那么每个边界处的半边如何对应一个点呢？这个点坐标如何获得？

 这个半边相邻的边界半边（一般是有两个相邻的边界处半边），这些相邻半边的所有点的重心坐标可以当作此半边对应的虚拟点。
