+++
author = 'libo'
date = '2026-04-22T20:54:13+08:00'
math= true
draft = false
title = 'Dual_contouring算法'

image = 'img.png'

+++

dc算法中，每个体素对应重建网格中的点，每个体素的面对应重建网格的边，每个体素的边对应重建网格的面。

由于重建网格的连通性由边来联通，所以体素通过面来联通。

也就是重建网格从一个面同过共用的边来访问另一个面，那么体素的（差分为0）的边通过共用的体素面来访问另一个（差分为0）的边。

由于流形定义，重建网格的边只能有两个面，所以体素的每个面只能有两个（差分为0）的边。

所以对于复杂情况，体素的点要计算多个，体素中的每个点都对应一组联通的（差分为0）的边。上面也说了如何把体素上的（差分为0）的边按连通性分割。

如何访问体素的边，每个八叉树的节点（体素）代表三个边，也就是左下角（xyz最小）为原点，向xyz正方向增长的三个边。同样，这三个边所在的三个面也由这个节点代表。这样通过访问每个节点就能访问所有的边和面。

---

## 结论先说：防止 DC 顶点逃出体素，最稳的是“盒约束 QEF”

在 Dual Contouring 里，体素内顶点 (x) 本质上是一个 **QEF 最小二乘拟合点**。如果只做普通 QEF：

$\min_x E(x)=\sum_i \left(n_i^T(x-p_i)\right)^2$

这个点**不一定落在当前体素内**，尤其是在平面、边特征、法线退化、Hermite 数据噪声较大时。

工程上有三种常见处理：

| 方法                                 | 是否保证在体素内 | 是否改变原始 QEF   | 推荐程度    |
| ---------------------------------- | -------- | ------------ | ------- |
| 令 $y=x-c$，求离质点最近的 QEF 解            | 不严格保证    | 不改变原 QEF，只选解 | 推荐      |
| 加入 $\lambda\|x-c\|^2$正则项           | 不严格保证    | 会改变 QEF      | 可用，但要谨慎 |
| 解盒约束 QEF：$\min E(x),\ l\le x\le u$ | **严格保证** | 不改变目标，只加约束   | **最推荐** |

如果你的目标是“**绝对不能逃出体素**”，应该做：

$\boxed{
\min_x |Ax-b|^2,\quad l_x\le x_x\le u_x,\ l_y\le x_y\le u_y,\ l_z\le x_z\le u_z
}$

其中 (l,u) 是当前体素的最小、最大坐标。

------

# 1. Dual Contouring 算法整体流程

Dual Contouring，简称 DC，是一种从体素 / 标量场中提取等值面的算法。它与 Marching Cubes 不同，Marching Cubes 是在每个体素边上插值出三角形，而 DC 是在每个包含等值面穿过的体素内部放置一个代表顶点，然后连接相邻体素的代表顶点。原始 DC 论文使用的是 Hermite 数据，也就是每条穿过等值面的体素边会保存交点位置和法线信息；这个方法的优势是可以较好保留锐边，而不需要显式识别特征线。([Semantic Scholar](https://www.semanticscholar.org/paper/Dual-contouring-of-hermite-data-Ju-Losasso/23d67521848ca436ab9ec1b89bca6d35bc885d26?utm_source=chatgpt.com))

流程如下。

------

## 1.1 输入：标量场

假设有一个隐式函数：

$f(x,y,z)$

目标等值面是：

$f(x,y,z)=0$

对于一个体素，它有 8 个角点。如果某条体素边两端的 $f$值异号，说明等值面穿过这条边。

设边的两个端点为 (a,b)，标量值为 $f(a),f(b)$，则交点可以线性插值：
$t=\frac{f(a)}{f(a)-f(b)}$

$p=a+t(b-a)$

这里的 $p$就是 Hermite 点。

------

## 1.2 法线计算

如果有隐式函数，可以直接用梯度：

$n=\frac{\nabla f(p)}{|\nabla f(p)|}$

如果只有离散体素数据，可以用中心差分近似：
$$ \nabla f(x,y,z)\left(
\frac{f(x+h,y,z)-f(x-h,y,z)}{2h},
\frac{f(x,y+h,z)-f(x,y-h,z)}{2h},
\frac{f(x,y,z+h)-f(x,y,z-h)}{2h}
\right)$$

归一化后得到：

$n_i=\frac{\nabla f(p_i)}{|\nabla f(p_i)|}$

每个穿过当前体素边的交点 $p_i$和法线 $n_i$，组成一个 Hermite 样本：

$(p_i,n_i)$

------

## 1.3 每个活跃体素生成一个顶点

如果一个体素中存在至少一条异号边，就认为这个体素被等值面穿过，需要生成一个 DC 顶点。

这个顶点不是简单取边交点平均，而是通过 QEF 拟合出来：

$x^*=\arg\min_x E(x)$

------

## 1.4 根据符号变化连接相邻体素顶点

在 3D 中，一条发生符号变化的网格边通常被 4 个体素共享。DC 会把这 4 个体素各自的代表点连接成一个四边形。

也就是说：

- Marching Cubes：体素内部生成三角形；
- Dual Contouring：体素生成顶点，网格边生成面片；
- “Dual”的含义就是原网格中的 cell 变成输出网格中的 vertex。

------

# 2. QEF 的来源：点到切平面的平方距离

对每个 Hermite 样本 $(p_i,n_i)$，用它构造一个切平面：

$n_i^T(x-p_i)=0$

也就是：

$n_i^Tx=n_i^Tp_i$

其中：

- $p_i$：等值面与体素边的交点；
- $n_i$：该点处的单位法线；
- $x$：要求的体素内代表顶点。

如果 (x) 在这个切平面上，那么：

$n_i^T(x-p_i)=0$

如果不在，则：

$n_i^T(x-p_i)$

就是 x到该切平面的有符号距离。

因此，对所有交点的切平面做最小二乘拟合：

$E(x)=\sum_i \left(n_i^T(x-p_i)\right)^2$

这就是 QEF，Quadratic Error Function，二次误差函数。

------

# 3. QEF 的矩阵形式

把所有法线堆成矩阵 (A)，把所有平面右端项堆成向量 (b)。

设：

$$
A=
\begin{bmatrix}
n_1^T\
n_2^T\
\vdots\
n_m^T
\end{bmatrix}
$$

$$
b=
\begin{bmatrix}
n_1^Tp_1\
n_2^Tp_2\
\vdots\
n_m^Tp_m
\end{bmatrix}
$$

那么：

$E(x)=|Ax-b|^2$

展开为：

$E(x)=
x^TA^TAx-2x^TA^Tb+b^Tb$

原始 DC 的后续技术报告也采用了这种形式，并指出 (A^TA) 是一个对称 (3\times 3) 矩阵；同时，直接形成 (A^TA) 会平方条件数，因此数值稳定性会变差。([People @ EECS](https://people.eecs.berkeley.edu/~jrs/meshpapers/SchaeferWarren2.pdf))

令：

$M=A^TA$

$q=A^Tb$

$r=b^Tb$

则：

$E(x)=x^TMx-2x^Tq+r$

对 (x) 求导：

$\nabla E(x)=2Mx-2q$

最小值满足：

$Mx=q$

也就是：

$A^TAx=A^Tb$

这就是 QEF 的正规方程。

------

# 4. 为什么 QEF 拟合点会逃出体素？

关键原因是：**QEF 只关心拟合切平面，不关心体素边界。**

例如在一个近似平面的体素中，所有法线都差不多：

$n_1\approx n_2\approx \cdots \approx n_m$

那么 QEF 只强烈约束法线方向，而对切平面上的两个切向方向几乎没有约束。

此时最小解不是唯一的，而是一整个平面：

${x\mid Ax=b}$

这时如果你用普通伪逆求解，它默认会选择“离世界坐标原点最近”的那个解。这个点可能远远跑出当前体素。

类似地：

- 平面特征：约束秩约为 1，解空间接近平面；
- 边特征：约束秩约为 2，解空间接近直线；
- 角点特征：约束秩约为 3，解接近唯一点。

所以 DC 中的“逃出体素”通常不是因为 QEF 写错，而是因为 QEF 在某些方向上欠约束。

------

# 5. SVD 和 QEF 的关系

QEF 本质是一个最小二乘问题：

$\min_x |Ax-b|^2$

对 (A) 做奇异值分解：

$A=U\Sigma V^T$

其中：

- $U$：左奇异向量矩阵；
- $\Sigma$：奇异值矩阵；
- $V$：右奇异向量矩阵；
- $\sigma_i$：奇异值。

令：

$x=Vz$

由于 (V) 是正交矩阵，所以这只是换了一个坐标系。

又因为：

$Ax=U\Sigma V^T x$

$V^Tx=z$

所以：

$Ax=U\Sigma z$

左乘 (U^T)，利用正交矩阵不改变二范数：

$|Ax-b|^2=|\Sigma z-U^Tb|^2$

设：

$\beta=U^Tb$

那么：

$E(z)=\sum_i(\sigma_i z_i-\beta_i)^2+\text{常数项}$

对于每个 $\sigma_i>0$的方向：

$z_i=\frac{\beta_i}{\sigma_i}$

对于 $\sigma_i=0$的方向，目标函数不依赖 $z_i$，说明该方向没有被 QEF 约束。

Moore-Penrose 伪逆默认取：

$z_i=0$

也就是在所有最小二乘解中取欧氏范数最小的解。

因此：

$x=A^+b$

其中：

$A^+=V\Sigma^+U^T$

这就是 SVD 解 QEF 的理论来源。

------

# 6. SVD 的几何意义

在 DC 的 QEF 中，奇异值可以理解为“某个方向被法线约束的强度”。

设 (V) 的列向量为：

$v_1,v_2,v_3$

它们表示空间中的三个主方向。

如果某个奇异值 $\sigma_i$很大，说明 QEF 对方向 (v_i) 约束强。

如果某个奇异值 $\sigma_i$ 很小，说明该方向几乎没有约束。

因此：

## 平面区域

所有法线几乎相同，(A) 的秩约为 1：

$\sigma_1\gg \sigma_2\approx 0,\quad \sigma_3\approx 0$

只约束法线方向，切平面内两个方向自由。

## 边特征

存在两组明显不同的法线，秩约为 2：

$\sigma_1,\sigma_2 \text{ 较大},\quad \sigma_3\approx 0$

两个法线方向约束后，解空间接近一条线，也就是锐边。

## 角点特征

三个方向都有约束，秩约为 3：

$\sigma_1,\sigma_2,\sigma_3 \text{ 都较大}$

此时 QEF 解接近唯一点，也就是角点。

这也是 DC 能保留锐边的核心原因：它不是只插值边上的点，而是让多个局部切平面在一个体素内共同决定顶点位置。

------

# 7. $A^TA$、SVD 和特征值的关系

如果：

$A=U\Sigma V^T$

那么：

$A^TA= V\Sigma^TU^TU\Sigma V^T$

因为：

$U^TU=I$

所以：

$A^TA=V\Sigma^T\Sigma V^T$

也就是说：

$A^TA$

的特征向量就是 (V)，特征值是：

$\lambda_i=\sigma_i^2$

因此：

$\sigma_i=\sqrt{\lambda_i}$

这说明两件事：

1. 对 (A) 做 SVD 和对 (A^TA) 做特征分解本质上是相关的；
2. 但直接构造 (A^TA) 会把条件数平方，数值稳定性更差。

这也是为什么一些实现会使用 QR 或 SVD 来避免直接求逆。DC 的技术报告中也明确提到，形成 (A^TA) 会平方条件数，而 QR 表示可以更稳定地保存和合并 QEF。([People @ EECS](https://people.eecs.berkeley.edu/~jrs/meshpapers/SchaeferWarren2.pdf))

------

# 8. QEF 和广义逆矩阵的关系

普通满秩情况下：

$A^TAx=A^Tb$

如果 (A^TA) 可逆，则：

$x=(A^TA)^{-1}A^Tb$

但是在 DC 中，(A^TA) 经常不可逆或病态。比如平面区域、边区域，都会导致矩阵秩亏。

于是需要用广义逆，尤其是 Moore-Penrose 伪逆：

$x=(A^TA)^+A^Tb$

也可以写成：

$x=A^+b$

其中：

$A^+=(A^TA)^+A^T$

在 Moore-Penrose 意义下成立。

更一般地，最小二乘解集合可以写为：

$x=A^+b+(I-A^+A)z$

其中 $z$是任意向量。

这里：

$A^+b$

是最小范数解；

$(I-A^+A)z$

是 (A) 的零空间方向，也就是 QEF 没有约束的自由方向。

这正是 DC 顶点可能飞出去的根源：欠约束方向没有几何限制。

------

# 9. “令 (y=x-c)”到底是什么意思？

设 (c) 是体素内的参考点，常用的是：

## 质点 / mass point

$c=\frac{1}{m}\sum_i p_i$

因为每个 (p_i) 都在体素边上，所以它们的平均值是体素内点。

原始 DC 后续说明中也采用了 mass point，即边交点平均值；它的好处是作为边交点的凸组合，天然位于生成它的体素内部。([People @ EECS](https://people.eecs.berkeley.edu/~jrs/meshpapers/SchaeferWarren2.pdf))

现在令：

$y=x-c$

则：

$x=c+y$

代入 QEF：

$\min_x |Ax-b|^2$

得到：

$\min_y |A(c+y)-b|^2=\min_y |Ay-(b-Ac)|^2$

令：

$d=b-Ac$

则：

$\min_y |Ay-d|^2$

用伪逆求最小范数解：

$y=A^+d$

所以：

$\boxed{
x=c+A^+(b-Ac)
}$

这就是“以质点为中心”的 QEF 解法。

------

## 9.1 它的意义

这个方法不是给 QEF 加惩罚项，而是在所有 QEF 最小解中，选择距离 (c) 最近的那个解。

因为：

$x=c+y$

而伪逆求的是最小 $|y|$的解，所以等价于：

$\min |x-c|$

也就是说，在 QEF 欠定时，它不再选择“离世界原点最近”的解，而是选择“离体素内质点最近”的解。

这能显著减少顶点逃出体素的情况。

------

## 9.2 与 $A^TA$写法的关系

从正规方程角度看：

$M=A^TA$

$q=A^Tb$

令：

$x=c+y$

代入：

$M(c+y)=q$

得到：

$My=q-Mc$

用伪逆：

$y=M^+(q-Mc)$

所以：

$\boxed{
x=c+M^+(q-Mc)
}$

也就是：

$\boxed{
x=c+(A^TA)^+(A^Tb-A^TAc)
}$

这和原始 DC 技术报告里给出的“求离点 (p) 最近的 QEF 解”的形式一致。([People @ EECS](https://people.eecs.berkeley.edu/~jrs/meshpapers/SchaeferWarren2.pdf))

------

# 10. 和“加入质点距离能量项”的区别

有些实现会写成：

$E_\lambda(x)=|Ax-b|^2+\lambda|x-c|^2$

这叫正则化，或者 Tikhonov / Ridge regularization。

它的解为：

$(A^TA+\lambda I)x=A^Tb+\lambda c$

即：

$\boxed{
x=(A^TA+\lambda I)^{-1}(A^Tb+\lambda c)
}$

这个方法的特点是：

- $\lambda>0$后矩阵一定更稳定；
- 小奇异值方向会被抑制；
- 解会被拉向 (c)；
- 但它会改变原始 QEF 的最优点；
- 它仍然不能严格保证 (x) 在体素内。

用 SVD 看得更清楚。

令：

$x=c+y$

则：

$E_\lambda(y)=|Ay-(b-Ac)|^2+\lambda|y|^2$

解为：

$$y=V
\operatorname{diag}
\left(
\frac{\sigma_i}{\sigma_i^2+\lambda}
\right)
U^T(b-Ac)$$

所以：

$$\boxed{
x=c+
V
\operatorname{diag}
\left(
\frac{\sigma_i}{\sigma_i^2+\lambda}
\right)
U^T(b-Ac)
}$$

当 $\sigma_i$很小时：

$\frac{\sigma_i}{\sigma_i^2+\lambda}$

会变得很小，说明小奇异值方向被压制。

所以这个方法更像“软约束”，而不是“严格不出体素”。

------

# 11. 如果要严格防止逃出体素：盒约束 QEF

推荐你最终使用这个形式：

$\boxed{
\min_x |Ax-b|^2
}$

约束：

$l\le x\le u$

其中：

$l=(x_{\min},y_{\min},z_{\min})$

$u=(x_{\max},y_{\max},z_{\max})$

这是一个 3 维凸二次规划问题。

因为变量只有 3 个，所以不需要复杂 QP 求解器，可以直接枚举边界状态。

------

## 11.1 盒约束求解思路

每个坐标只有三种状态：

1. 自由；
2. 固定在下边界；
3. 固定在上边界。

所以一共有：

$3^3=27$

种组合。

对于每一种组合：

- 固定某些坐标到边界；
- 对剩下自由坐标解一个低维最小二乘；
- 如果自由坐标解仍在边界范围内，就计算 QEF；
- 选 QEF 最小的可行点。

------

## 11.2 公式

设坐标分成两部分：

- 自由变量：$x_f$
- 固定变量：$x_k$

原问题：

$\min_x |Ax-b|^2$

拆成：

$A_f x_f + A_k x_k$

其中 $x_k$ 已经被固定为某个边界值。

于是变成：

$\min_{x_f}|A_f x_f-(b-A_kx_k)|^2$

解：

$x_f=A_f^+(b-A_kx_k)$

如果：

$l_f\le x_f\le u_f$

则它是当前 active set 下的候选解。

最后在所有候选解中取 QEF 最小者：

$x^*=\arg\min_{x\in \text{candidates}} |Ax-b|^2$

这样得到的点一定在体素盒内。

------

# 12. 实际推荐计算流程

我建议你的 DC 顶点放置流程这样写：

```text
输入：
    当前体素 cell
    Hermite 点 p_i
    Hermite 法线 n_i

1. 构造 A, b
       A 的每一行 = n_i^T
       b_i = n_i^T p_i

2. 计算质点 c
       c = average(p_i)

3. 先求 shifted QEF：
       x = c + A^+ (b - A c)

4. 如果 x 在 cell 内：
       使用 x

5. 如果 x 不在 cell 内：
       解 box-constrained QEF：
       min ||A x - b||^2
       subject to cell_min <= x <= cell_max

6. 如果数值异常：
       fallback = c
```

核心是：

$\boxed{
x=c+A^+(b-Ac)
}$

再配合：

$\boxed{
l\le x\le u
}$

这样既有 DC 的锐特征能力，又能避免体素点飞出。

------

# 13. 不建议直接 clamp

有些实现会直接：

$x=\operatorname{clamp}(x,l,u)$

这虽然能把点拉回体素，但它不是 QEF 在体素边界上的最优解。

直接 clamp 可能导致：

- 顶点沿某个坐标轴被硬拉回；
- 锐边位置偏移；
- 面片局部折叠；
- 相邻体素顶点不连续；
- 出现小尖刺或皱褶。

所以 clamp 只能作为最后兜底，不应该作为主要方法。

更合理的是：

$\min |Ax-b|^2,\quad l\le x\le u$

也就是盒约束 QEF。

------

# 14. 小结

你看到的两种做法本质不同：

## 做法一：令 (y=x-c)

$x=c+A^+(b-Ac)$

含义是：

> 在原始 QEF 的所有最小解中，选离体素内质点 (c) 最近的解。

它不改变原 QEF，满秩时结果和普通 QEF 一样，欠秩时才发挥作用。

------

## 做法二：加入质点距离能量

$E_\lambda(x)=|Ax-b|^2+\lambda|x-c|^2$

解为：

$x=(A^TA+\lambda I)^{-1}(A^Tb+\lambda c)$

含义是：

> 在 QEF 拟合和靠近质点之间做折中。

它会改变原 QEF 的最优点，但数值更稳定。

------

## 最稳工程方案

$\boxed{
x_0=c+A^+(b-Ac)
}$

如果：

$x_0\in [l,u]$

直接使用。

否则求：

$\boxed{
x^*=\arg\min_{l\le x\le u}|Ax-b|^2
}$

如果仍然异常，使用：

$\boxed{
x=c}$

作为兜底。

这个方案在工程上比单纯加 $\lambda|x-c|^2$更可靠，因为它真正保证顶点不会逃出当前体素。

-----

这里为你提供一套**完全自洽、严谨且适合直接转化为代码**的 Jacobi 方法（基于 Givens 旋转）求解实对称矩阵特征值和特征向量的理论公式与算法流程。

我们采用数值线性代数经典教材（如 Golub & Van Loan）中推荐的符号约定，确保矩阵定义、角度推导和更新公式**100% 自洽**。

---

### 一、 理论推导 (Theoretical Derivation)

#### 1. 定义 Givens 旋转矩阵 $J$
设我们要消去对称矩阵 $M$ 中的非对角元素 $m_{pq}$（其中 $p < q$）。我们构造一个 Givens 旋转矩阵 $J(p, q, \theta)$，它在 $(p, q)$ 二维子空间上的形式为：

$$
J_{sub} = \begin{pmatrix} c & s \\ -s & c \end{pmatrix}
\quad \text{即} \quad
J_{pp} = c, \; J_{pq} = s, \; J_{qp} = -s, \; J_{qq} = c
$$
*(注：其余对角线元素为 1，非对角线元素为 0。$c = \cos\theta, s = \sin\theta$)*

#### 2. 相似变换与消元条件
我们对 $M$ 进行正交相似变换：$M' = J^T M J$。
提取出 $(p, q)$ 对应的 $2 \times 2$ 子矩阵进行计算：

$$
\begin{pmatrix} m'_{pp} & m'_{pq} \\ m'_{qp} & m'_{qq} \end{pmatrix} =
\begin{pmatrix} c & -s \\ s & c \end{pmatrix}
\begin{pmatrix} m_{pp} & m_{pq} \\ m_{pq} & m_{qq} \end{pmatrix}
\begin{pmatrix} c & s \\ -s & c \end{pmatrix}
$$

展开乘法后，新的非对角元素 $m'_{pq}$ 为：
$$ m'_{pq} = sc(m_{pp} - m_{qq}) + (c^2 - s^2)m_{pq} $$

为了消去该元素，令 $m'_{pq} = 0$，并利用二倍角公式 $\sin(2\theta) = 2sc$ 和 $\cos(2\theta) = c^2 - s^2$：
$$ \frac{1}{2}\sin(2\theta)(m_{pp} - m_{qq}) + \cos(2\theta)m_{pq} = 0 $$

整理得到求解旋转角 $\theta$ 的核心方程：
$$ \cot(2\theta) = \frac{\cos(2\theta)}{\sin(2\theta)} = \frac{m_{qq} - m_{pp}}{2m_{pq}} $$

#### 3. 数值稳定的参数计算 (核心)
在实际编程中，我们**不直接计算 $\theta$**，而是计算 $t = \tan\theta$，进而求出 $c$ 和 $s$。

令 $\tau = \cot(2\theta) = \frac{m_{qq} - m_{pp}}{2m_{pq}}$。
利用三角恒等式 $\cot(2\theta) = \frac{1 - \tan^2\theta}{2\tan\theta}$，可得关于 $t$ 的二次方程：
$$ t^2 + 2\tau t - 1 = 0 $$

解得 $t = -\tau \pm \sqrt{\tau^2 + 1}$。为了保证数值稳定性并使得旋转角度 $|\theta| \le \frac{\pi}{4}$，我们**选择绝对值较小的根**：

$$
t = \begin{cases} 
\frac{\text{sign}(\tau)}{|\tau| + \sqrt{1 + \tau^2}} & \text{if } \tau \neq 0 \\
1 & \text{if } \tau = 0 
\end{cases}
$$
*(注：$\text{sign}(\tau)$ 是符号函数，$\tau>0$ 时为 1，$\tau<0$ 时为 -1)*

得到 $t$ 后，计算 $c$ 和 $s$：
$$ c = \frac{1}{\sqrt{1 + t^2}}, \quad s = t \cdot c $$

---

### 二、 核心更新公式 (Update Formulas)

得到 $c, s, t$ 后，使用以下公式更新矩阵。**这套公式与上述推导完全自洽。**

#### 1. 更新目标矩阵 $M$ ($M' = J^T M J$)
* **对角线元素**：
  $$ m'_{pp} = m_{pp} - t \cdot m_{pq} $$
  $$ m'_{qq} = m_{qq} + t \cdot m_{pq} $$
* **被消去的非对角元素**：
  $$ m'_{pq} = m'_{qp} = 0 $$
* **受影响的其余非对角元素** (对于所有 $i \neq p, q$)：
  $$ m'_{ip} = m_{pi}' = c \cdot m_{ip} - s \cdot m_{iq} $$
  $$ m'_{iq} = m_{qi}' = s \cdot m_{ip} + c \cdot m_{iq} $$
  *(注：由于 $M$ 是对称矩阵，只需更新上三角或下三角，然后对称赋值即可)*

#### 2. 更新特征向量矩阵 $V$ ($V' = V J$)
初始时 $V = I$（单位矩阵）。每次旋转时，只需更新 $V$ 的第 $p$ 列和第 $q$ 列：
* 对于所有行 $i \in \{1, 2, \dots, n\}$：
  $$ v'_{ip} = c \cdot v_{ip} - s \cdot v_{iq} $$
  $$ v'_{iq} = s \cdot v_{ip} + c \cdot v_{iq} $$

---

### 三、 算法流程 (Algorithm Flow)

Jacobi 算法有两种常见的扫描策略：**经典 Jacobi**（每次找绝对值最大的非对角元）和 **循环 Jacobi**（按固定顺序扫描）。
由于寻找最大元素需要 $O(n^2)$ 的额外开销，现代工程实现中**几乎总是使用循环 Jacobi (Cyclic Jacobi)**，其收敛速度在实际中同样具有二次收敛性。

#### 循环 Jacobi 算法伪代码

```python
def jacobi_eigen(M, max_sweeps=100, tol=1e-10):
    """
    使用循环 Jacobi 方法求解实对称矩阵 M 的特征值和特征向量。
    返回: eigenvalues (对角线元素), eigenvectors (矩阵 V 的列)
    """
    n = M.shape[0]
    V = np.eye(n)  # 初始化特征向量矩阵为单位阵
    A = M.copy()   # 工作矩阵
    
    for sweep in range(max_sweeps):
        # 1. 计算当前非对角元素的平方和 (Frobenius 范数的 off-diagonal 部分)
        off_diag_norm = 0.0
        for i in range(n):
            for j in range(i+1, n):
                off_diag_norm += A[i, j]**2
                
        # 2. 收敛判断
        if off_diag_norm < tol:
            break
            
        # 3. 一次完整的扫掠 (Sweep)：按行优先顺序遍历所有上三角元素
        for p in range(n-1):
            for q in range(p+1, n):
                
                if abs(A[p, q]) < 1e-15:  # 如果已经接近 0，跳过
                    continue
                    
                # --- 计算旋转参数 ---
                tau = (A[q, q] - A[p, p]) / (2.0 * A[p, q])
                if tau >= 0:
                    t = 1.0 / (tau + np.sqrt(1.0 + tau**2))
                else:
                    t = -1.0 / (-tau + np.sqrt(1.0 + tau**2))
                    
                c = 1.0 / np.sqrt(1.0 + t**2)
                s = t * c
                
                # --- 更新矩阵 A (即 M) ---
                # 更新对角线
                A[p, p] = A[p, p] - t * A[p, q]
                A[q, q] = A[q, q] + t * A[p, q]
                A[p, q] = 0.0
                A[q, p] = 0.0
                
                # 更新非对角线 (利用对称性，只算一半然后赋值)
                for i in range(n):
                    if i != p and i != q:
                        a_ip = A[i, p]
                        a_iq = A[i, q]
                        A[i, p] = c * a_ip - s * a_iq
                        A[p, i] = A[i, p]
                        A[i, q] = s * a_ip + c * a_iq
                        A[q, i] = A[i, q]
                        
                # --- 更新特征向量矩阵 V ---
                for i in range(n):
                    v_ip = V[i, p]
                    v_iq = V[i, q]
                    V[i, p] = c * v_ip - s * v_iq
                    V[i, q] = s * v_ip + c * v_iq
                    
    # 4. 提取特征值并排序 (通常按从大到小或从小到大排列)
    eigenvalues = np.diag(A)
    
    # 按特征值降序排序，并相应调整特征向量矩阵的列
    idx = np.argsort(eigenvalues)[::-1] 
    eigenvalues = eigenvalues[idx]
    V = V[:, idx]
    
    return eigenvalues, V
```

### 四、 算法复杂度与特性总结

1. **时间复杂度**：
   * 单次旋转（更新 $A$ 和 $V$）：$O(n)$。
   * 单次扫掠（Sweep，包含 $\frac{n(n-1)}{2}$ 次旋转）：$O(n^3)$。
   * 总时间复杂度：通常为 $O(n^3)$，因为对于大多数矩阵，只需要 5~10 次扫掠即可收敛。
2. **空间复杂度**：$O(n^2)$，用于存储矩阵 $A$ 和 $V$。
3. **数值稳定性**：极高。由于只使用正交变换，不会放大舍入误差，是求解中小型（$n < 1000$）密集对称矩阵特征问题的**最稳定方法之一**。
4. **并行性**：Jacobi 方法天然适合并行计算（特别是 One-sided Jacobi 或 Block Jacobi 变体），在 GPU 加速场景下表现优异。
