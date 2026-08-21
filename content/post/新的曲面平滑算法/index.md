+++
author = 'libo'
date = '2026-08-19T00:00:00+08:00'
math = true
draft = false
title = '新的曲面平滑算法 '
image = "image.png"
+++

# 新的曲面平滑算法

本文沿用带符号精确二面角 $\left(\phi\right)$ 的定义，只把半边向量修改为：

$$
\boxed{
N(e) =\phi\left(
\frac{e}{\|e\|}
+
\lambda\left(\frac{e\times a}{\|e\times a\|}
+
\frac{b\times e}{\|b\times e\|}\right)
\right).
}
$$

下文中三维楔积 $\left(\wedge\right)$ 统一写成叉积 $\left(\times\right)$，$\lambda$ 为 $[0,0.5]$ 区间内的固定参数，不是变量。

$\lambda$调节向量补偿的方向，越低$\sum N(e)$的模长在低能量下增长缓慢，低识别。$\lambda$越高，$\sum N(e)$的模长在低能量下增长迅速，高识别，但在高能量处增长缓慢，低识别。

---

## 1. 半边法向量定义

设内部半边周围四个顶点为 $\left(p_0,p_1,p_2,p_3\right)$，定义：

$$
\boxed{
e=p_1-p_0,\qquad
a=p_2-p_0,\qquad
b=p_3-p_0.
}
$$

三个单位向量为：边方向向量与两个相邻三角形的面法向量

$$
\boxed{
u=\frac{e}{\|e\|},
\qquad
n_a=\frac{e\times a}{\|e\times a\|},
\qquad
n_b=\frac{b\times e}{\|b\times e\|}.
}
$$

带符号精确二面角仍定义为：

$$
\boxed{
\phi=\operatorname{atan2}
\left(
-\|e\|\,[e\cdot(a\times b)],
(e\times a)\cdot(b\times e)
\right).
}
$$

因此新的有向半边向量为：

$$
\boxed{
N_+(e)=\phi S_+,
\qquad
S_+=u+\lambda\left(n_a+n_b\right).
}
$$

### 1.1 反向半边

反向半边 $\left(p_1,p_0,p_3,p_2\right)$ 的局部向量满足：

$$
e^-=-e,
\qquad
a^-=b-e,
\qquad
b^-=a-e.
$$

直接计算可得：

$$
e^-\times a^-=b\times e,
\qquad
b^-\times e^-=e\times a,
\qquad
\phi^-=\phi.
$$

即反向半边的两个面法向量恰好互换，而 $\left(n_a+n_b\right)$ 在互换下不变，所以反向半边向量可以直接用正向半边的 $\left(e,a,b\right)$ 写成：

$$
\boxed{
N_-(e)=\phi S_-,
\qquad
S_-=-u+\lambda\left(n_a+n_b\right).
}
$$

因此：

$$
\boxed{
N_-(e)\neq -N_+(e),
\qquad
N_-(e)=N_+(e)-2\phi u.
}
$$

这一点与旧定义不同。因此后面的能量梯度不能再把正反半边贡献简单合并成
$\left(\bar N(v)-\bar N(v_i)\right)$。

---

## 2. 雅可比矩阵

定义叉乘矩阵（反对称矩阵）$\left([q]_\times\right)$：

$$
[q]_\times r=q\times r.
$$

定义三个正交投影矩阵（分别投影到与 $\left(e,n_a,n_b\right)$ 垂直的平面上）：

$$
\boxed{
P_e=I-uu^T,
\qquad
P_a=I-n_an_a^T,
\qquad
P_b=I-n_bn_b^T.
}
$$

### 2.1 带符号角度 $\left(\phi\right)$ 的梯度

对 $\left(e\right)$ 的梯度：

$$
\boxed{
g_e:=\frac{\partial\phi}{\partial e}
=\frac{a\cdot e}{\|e\|\,\|e\times a\|}\,n_a
+\frac{b\cdot e}{\|e\|\,\|b\times e\|}\,n_b.
}
$$

对 $\left(a\right)$ 的梯度：

$$
\boxed{
g_a:=\frac{\partial\phi}{\partial a}
=-\frac{\|e\|}{\|e\times a\|}\,n_a.
}
$$

对 $\left(b\right)$ 的梯度：

$$
\boxed{
g_b:=\frac{\partial\phi}{\partial b}
=-\frac{\|e\|}{\|b\times e\|}\,n_b.
}
$$

因此对四个原始顶点：

$$
\frac{\partial\phi}{\partial p_1}=g_e,
\qquad
\frac{\partial\phi}{\partial p_2}=g_a,
\qquad
\frac{\partial\phi}{\partial p_3}=g_b,
\qquad
\frac{\partial\phi}{\partial p_0}=-(g_e+g_a+g_b).
$$

### 2.2 三个单位向量的雅可比

对于边方向：

$$
\boxed{
\frac{\partial u}{\partial e}=\frac{P_e}{\|e\|}.
}
$$

由于：

$$
d(e\times a)=-[a]_\times\,de+[e]_\times\,da,
$$

所以：

$$
\boxed{
\frac{\partial n_a}{\partial e}
=-\frac{P_a[a]_\times}{\|e\times a\|},
\qquad
\frac{\partial n_a}{\partial a}
=\frac{P_a[e]_\times}{\|e\times a\|}.
}
$$

由于：

$$
d(b\times e)=[b]_\times\,de-[e]_\times\,db,
$$

所以：

$$
\boxed{
\frac{\partial n_b}{\partial e}
=\frac{P_b[b]_\times}{\|b\times e\|},
\qquad
\frac{\partial n_b}{\partial b}
=-\frac{P_b[e]_\times}{\|b\times e\|}.
}
$$

其余交叉偏导均为零。

### 2.3 半边向量 $\left(N_\sigma=\phi S_\sigma\right)$ 的雅可比

为了同时表示正向和反向半边，令 $\left(\sigma\in\{+1,-1\}\right)$：

$$
\boxed{
S_\sigma=\sigma u+\lambda\left(n_a+n_b\right),
\qquad
N_\sigma=\phi S_\sigma,
}
$$

其中 $\left(S_{+1}=S_+\right)$，$\left(S_{-1}=S_-\right)$。由乘积法则：

$$
dN_\sigma
=S_\sigma\,d\phi+\phi\,dS_\sigma.
$$

结合 2.1 与 2.2 的结果，对 $\left(e\right)$：

$$
\boxed{
J_e^{(\sigma)}:=\frac{\partial N_\sigma}{\partial e}
=S_\sigma g_e^T
+\phi\left(
\sigma\frac{P_e}{\|e\|}
-\lambda\frac{P_a[a]_\times}{\|e\times a\|}
+\lambda\frac{P_b[b]_\times}{\|b\times e\|}
\right).
}
$$

对 $\left(a\right)$：

$$
\boxed{
J_a^{(\sigma)}:=\frac{\partial N_\sigma}{\partial a}
=S_\sigma g_a^T
+\lambda\phi\,\frac{P_a[e]_\times}{\|e\times a\|}.
}
$$

对 $\left(b\right)$：

$$
\boxed{
J_b^{(\sigma)}:=\frac{\partial N_\sigma}{\partial b}
=S_\sigma g_b^T
-\lambda\phi\,\frac{P_b[e]_\times}{\|b\times e\|}.
}
$$

注意：

- $\left(J_a^{(\sigma)}\right)$、$\left(J_b^{(\sigma)}\right)$第二项 与 $\left(\sigma\right)$ 无关，但第一项仍随正反半边变化；
- $\left(\lambda\right)$ 只通过 $\left(S_\sigma\right)$ 和各面法向项进入雅可比，令 $\left(\lambda=0\right)$（即 $\left(S_\sigma=\sigma u\right)$）时以上各式退化为旧定义的雅可比；
- 正向半边取 $\left(\sigma=+1\right)$，反向半边取 $\left(\sigma=-1\right)$。

### 2.4 对四个顶点的雅可比

对于 $\left(N_\sigma\right)$，由于：

$$
de=dp_1-dp_0,
\qquad
da=dp_2-dp_0,
\qquad
db=dp_3-dp_0,
$$

所以：

$$
\boxed{
\frac{\partial N_\sigma}{\partial p_1}=J_e^{(\sigma)},
\qquad
\frac{\partial N_\sigma}{\partial p_2}=J_a^{(\sigma)},
\qquad
\frac{\partial N_\sigma}{\partial p_3}=J_b^{(\sigma)},
}
$$

$$
\boxed{
\frac{\partial N_\sigma}{\partial p_0}
=-\left(
J_e^{(\sigma)}
+J_a^{(\sigma)}
+J_b^{(\sigma)}
\right).
}
$$

因此自动满足平移不变性：

$$
\frac{\partial N_\sigma}{\partial p_0}
+\frac{\partial N_\sigma}{\partial p_1}
+\frac{\partial N_\sigma}{\partial p_2}
+\frac{\partial N_\sigma}{\partial p_3}
=0.
$$

### 2.5 能量中直接使用的 $\left(J^Tr\right)$

对于任意三维向量 $\left(r\right)$，有：

$$
\boxed{
\left(J_e^{(\sigma)}\right)^Tr
=g_e\,(S_\sigma\cdot r)
+\phi\left[
\sigma\frac{P_er}{\|e\|}
+\lambda\frac{a\times(P_ar)}{\|e\times a\|}
-\lambda\frac{b\times(P_br)}{\|b\times e\|}
\right].
}
$$

$$
\boxed{
\left(J_a^{(\sigma)}\right)^Tr
=g_a\,(S_\sigma\cdot r)
-\lambda\phi\,\frac{e\times(P_ar)}{\|e\times a\|}.
}
$$

$$
\boxed{
\left(J_b^{(\sigma)}\right)^Tr
=g_b\,(S_\sigma\cdot r)
+\lambda\phi\,\frac{e\times(P_br)}{\|b\times e\|}.
}
$$

这三式可以直接用于能量梯度计算，不需要显式构造 $\left(3\times3\right)$ 矩阵。

---

## 3. 三角网格中的能量梯度

设所有指向顶点 $\left(v\right)$ 的有向半边集合为：

$$
\mathcal H(v)=\{h=(v_i,v)\}.
$$

定义：

$$
\boxed{
\bar N(v)=\sum_{h\in\mathcal H(v)}N(h).
}
$$

顶点能量为：

$$
\boxed{
E(v)=\|\bar N(v)\|^2.
}
$$

整个网格总能量为：

$$
\boxed{
\mathcal E=\sum_v\|\bar N(v)\|^2.
}
$$

对任意顶点 $\left(p_v\right)$，总梯度的一般形式为：

$$
\boxed{
\nabla_{p_v}\mathcal E=2\sum_q
\left(
\frac{\partial\bar N(q)}{\partial p_v}
\right)^T
\bar N(q).
}
$$

等价地，对所有局部四点结构中包含 $\left(v\right)$ 的有向半边求和：

$$
\boxed{
\nabla_{p_v}\mathcal E=2\sum_{h:\,v\in Q(h)}
J_{h,v}^T\,
\bar N(\operatorname{head}(h)).
}
$$

其中 $\left(Q(h)\right)$ 表示该半边对应的四个局部顶点。

完整梯度仍分为：

$$
\boxed{
\nabla_{p_v}\mathcal E=\nabla_pE_1(v)
+
\nabla_pE_2(v).
}
$$

其中：

- $\left(E_1\right)$：$\left(v\right)$ 作为边端点时的贡献；
- $\left(E_2\right)$：$\left(v\right)$ 作为相邻三角形第三个顶点时的贡献。

### 3.1 邻接半边贡献 $\left(E_1\right)$

对每个邻接顶点 $\left(v_i\right)$，统一取正向半边 $\left(h=(v_i,v)\right)$，即 $\left(p_0=v_i,\ p_1=v\right)$。正向半边 $\left(N_+\right)$ 进入 $\left(\bar N(v)\right)$，反向半边 $\left(N_-\right)$ 进入 $\left(\bar N(v_i)\right)$。

由于移动 $\left(v=p_1\right)$ 时，在正向局部变量中只改变 $\left(e\right)$，单条邻接边的贡献为 $\left(2[(J_e^+)^T\bar N(v)+(J_e^-)^T\bar N(v_i)]\right)$，对所有邻接边求和：

$$
\boxed{
\nabla_pE_1(v)=2\sum_{h=(v_i,v)}
\left[
(J_e^+)^T\bar N(v)
+
(J_e^-)^T\bar N(v_i)
\right].
}
$$

展开后得到：

$$
\boxed{
\begin{aligned}
\nabla_pE_1(v)
=2\sum_{h=(v_i,v)}
\Bigg\{
&g_e\Big[
S_+\cdot\bar N(v)
+
S_-\cdot\bar N(v_i)
\Big]
\\[3pt]
&+
\phi\frac{P_e[\bar N(v)-\bar N(v_i)]}{\|e\|}
\\[3pt]
&+
\lambda\phi\frac{
a\times P_a[\bar N(v)+\bar N(v_i)]
}{\|e\times a\|}
\\[3pt]
&-
\lambda\phi\frac{
b\times P_b[\bar N(v)+\bar N(v_i)]
}{\|b\times e\|}
\Bigg\}.
\end{aligned}
}
$$

这里每条半边的 $\left(e,a,b,\phi,S_\pm,P_e,P_a,P_b,g_e\right)$ 都使用该半边自己的局部几何量。

与旧公式相比，只有边方向项出现
$\left(\bar N(v)-\bar N(v_i)\right)$；两个面法向项对应的都是
$\left(\bar N(v)+\bar N(v_i)\right)$，并且都带因子 $\left(\lambda\right)$。

---

## 4. 环状边贡献

考虑二环邻域中的一条边：

$$
h=(v_j,v_i),
\qquad
e=v_i-v_j,
$$

取 $\left(p_0=v_j,\ p_1=v_i\right)$。正向半边 $\left(N_+\right)$ 进入 $\left(\bar N(v_i)\right)$，反向半边 $\left(N_-\right)$ 进入 $\left(\bar N(v_j)\right)$。记：

$$
\bar N_i=\bar N(v_i),
\qquad
\bar N_j=\bar N(v_j).
$$

### 4.1 当前顶点 $\left(v=p_2\right)$

此时 $\left(a=v-v_j\right)$，移动 $\left(v\right)$ 只改变局部变量 $\left(a\right)$。单条环状边的贡献为 $\left(2[(J_a^+)^T\bar N_i+(J_a^-)^T\bar N_j]\right)$，对所有满足 $\left(v=p_2\right)$ 的环状边求和：

$$
\boxed{
\nabla_pE_{2,a}(v)=2\sum_{h=(v_j,v_i),\,v=p_2}
\left[
(J_a^+)^T\bar N_i
+
(J_a^-)^T\bar N_j
\right].
}
$$

展开为：

$$
\boxed{
\begin{aligned}
\nabla_pE_{2,a}(v)
=2\sum_{h=(v_j,v_i),\,v=p_2}
\Bigg\{
&g_a
\Big[
S_+\cdot\bar N_i
+
S_-\cdot\bar N_j
\Big]
\\[3pt]
&-
\lambda\phi
\frac{
e\times P_a(\bar N_i+\bar N_j)
}{\|e\times a\|}
\Bigg\}.
\end{aligned}
}
$$

### 4.2 当前顶点 $\left(v=p_3\right)$

此时 $\left(b=v-v_j\right)$，移动 $\left(v\right)$ 只改变局部变量 $\left(b\right)$。单条环状边的贡献为 $\left(2[(J_b^+)^T\bar N_i+(J_b^-)^T\bar N_j]\right)$，对所有满足 $\left(v=p_3\right)$ 的环状边求和：

$$
\boxed{
\nabla_pE_{2,b}(v)=2\sum_{h=(v_j,v_i),\,v=p_3}
\left[
(J_b^+)^T\bar N_i
+
(J_b^-)^T\bar N_j
\right].
}
$$

展开为：

$$
\boxed{
\begin{aligned}
\nabla_pE_{2,b}(v)
=2\sum_{h=(v_j,v_i),\,v=p_3}
\Bigg\{
&g_b
\Big[
S_+\cdot\bar N_i
+
S_-\cdot\bar N_j
\Big]
\\[3pt]
&+
\lambda\phi
\frac{
e\times P_b(\bar N_i+\bar N_j)
}{\|b\times e\|}
\Bigg\}.
\end{aligned}
}
$$

因此：

$$
\nabla_pE_2(v)=\nabla_pE_{2,a}(v)
+
\nabla_pE_{2,b}(v),
$$

最终顶点总梯度为：

$$
\boxed{
\nabla_{p_v}\mathcal E=\nabla_pE_1(v)
+
\nabla_pE_{2,a}(v)
+
\nabla_pE_{2,b}(v).
}
$$

如果拓扑遍历可以统一选择半边方向，使待求顶点始终位于 $\left(p_2\right)$，则实现中只需要保留 $\left(E_{2,a}\right)$ 分支。

---

## 5. 退化情况与边界处理

### 5.1 零长度边

当 $\left(\|e\|=0\right)$ 时，$\left(u\right)$ 和对应雅可比无法定义，应跳过该半边。

### 5.2 退化三角形

当 $\left(\|e\times a\|=0\right)$ 或 $\left(\|b\times e\|=0\right)$ 时，对应三角形退化，$\left(n_a,n_b\right)$、角度梯度和雅可比均无法定义，应跳过该半边或先修复网格。

实际计算建议使用阈值：

$$
\|e\times a\|^2
\le
\varepsilon_{area}^2\|e\|^2\|a\|^2,
\qquad
\|b\times e\|^2
\le
\varepsilon_{area}^2\|b\|^2\|e\|^2.
$$

### 5.3 $\left(\phi=0\right)$

平面状态 $\left(\phi=0\right)$ 不是退化情况。此时 $\left(N_+=N_-=0\right)$，但是 $\left(J_e,J_a,J_b\right)$ 中的 $\left(S_\sigma g^T\right)$ 项一般仍然存在，因此不能因为 $\left(\phi=0\right)$ 就直接把雅可比设为零。

### 5.4 接近 $\left(180^\circ\right)$ 翻折

当：

$$
(e\times a)\cdot(b\times e)<0
$$

且 `atan2` 的第一个参数接近零时，$\left(|\phi|\approx\pi\right)$。

此时 $\left(\phi\right)$ 位于 $\left(+\pi/-\pi\right)$ 分支附近，角度本身不连续。建议检测并跳过完全翻折状态，或者对 $\left(\phi\right)$ 做跨迭代连续展开。

### 5.5 边界半边

边界半边缺少一个相邻三角形，因此无法同时定义：

$$
\frac{e\times a}{\|e\times a\|},
\qquad
\frac{b\times e}{\|b\times e\|},
\qquad
\phi.
$$

可以采用：

1. 跳过边界半边；
2. 固定边界顶点；
3. 构造 ghost 顶点补齐第二个三角形。

如果 ghost 顶点依赖真实顶点：

$$
p_g=\sum_kw_kp_k,
$$

则严格梯度还需要链式回传：

$$
\boxed{
\frac{\partial\mathcal E}{\partial p_k}
\mathrel{+}=
w_k
\frac{\partial\mathcal E}{\partial p_g}.
}
$$
