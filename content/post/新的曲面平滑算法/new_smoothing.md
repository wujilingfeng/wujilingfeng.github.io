+++
author = 'libo'
date = '2026-08-16T00:00:00+08:00'
math = true
draft = false
title = '基于有符号精确二面角的曲面平滑算法（展开公式版）'
image = "image.png"
+++

# 基于有符号精确二面角的曲面平滑算法（展开公式版）

本文使用精确二面角重新定义半边向量。与旧定义相比，只改变半边向量的模长，不改变其方向。

旧定义为：

$$
N_{old}(e)
=
\frac{(e\times a)\times(b\times e)}
{\|e\times a\|\,\|b\times e\|}.
$$

新的定义要求：

$$
\boxed{
\|N(e)\|=\theta
}
$$

并且严格保持：

$$
\boxed{
\frac{N(e)}{\|N(e)\|}
=
\frac{(e\times a)\times(b\times e)}
{\|(e\times a)\times(b\times e)\|}.
}
$$

为了减少阅读和代码实现中的中间符号，全文只长期保留以下几个量：

- $e,a,b$：半边局部几何向量；
- $\phi$：带符号二面角；
- $N(e)$：新的半边向量；
- $\bar N(v)$：顶点周围半边向量之和。

像边长、单位边方向、法向量长度平方、投影矩阵、角度梯度等量，公式中尽量直接展开，不另外引入符号。

---

## 1. 半边向量定义

设内部半边周围四个顶点为 $p_0,p_1,p_2,p_3$，定义：

$$
\boxed{
e=p_1-p_0,\qquad
a=p_2-p_0,\qquad
b=p_3-p_0.
}
$$

其中：

- $p_0\rightarrow p_1$ 为当前有向半边$he=(p_0,p_1)$；
- $p_2$ 为当前面第三个顶点；
- $p_3$ 为对偶面第三个顶点。

如果网格面朝向一致，则两个三角形应分别采用：

$$
(p_0,p_1,p_2),\qquad(p_1,p_0,p_3).
$$

### 1.1 原半边向量的方向

原公式分子为：

$$
W=(e\times a)\times(b\times e).
$$

利用三重积恒等式：

$$
(e\times a)\times(b\times e)
=-\bigl[e\cdot(a\times b)\bigr]e.
$$

因此：

$$
\boxed{
W=-\bigl[e\cdot(a\times b)\bigr]e.
}
$$

这说明 $W$ 始终平行于 $e$，但可能与 $e$ 同向，也可能与 $e$ 反向。

所以新的 $N(e)$ 不能简单写成无符号角度乘 $e/\|e\|$。必须把原分子的方向符号保留下来。

---

## 2. 带符号精确二面角

两个相邻三角形的未单位化法向量分别是：

$$
e\times a,
\qquad
b\times e.
$$

它们之间的无符号夹角就是二面角大小 $\theta$。

为了同时保留原 $W$ 的方向，使用带符号角度：

$$
\boxed{
\phi
=
\operatorname{atan2}
\left(
-\|e\|\,[e\cdot(a\times b)],
(e\times a)\cdot(b\times e)
\right).
}
$$

这里 `atan2` 的调用顺序为：

```text
atan2(y, x)
```

因此代码必须写成：

```text
phi = atan2(
    -length(e) * dot(e, cross(a, b)),
    dot(cross(e, a), cross(b, e))
)
```

无符号二面角为：

$$
\theta=|\phi|.
$$

### 2.1 为什么 $\phi$ 的符号能够保持原方向

由：

$$
W=-\bigl[e\cdot(a\times b)\bigr]e
$$

可知：

$$
\frac{e}{\|e\|}\cdot W
=
-\|e\|\,[e\cdot(a\times b)].
$$

这正是 `atan2` 的第一个参数。

所以，当 $0<|\phi|<\pi$ 时：

$$
\operatorname{sgn}(\phi)
=
\operatorname{sgn}
\left(
\frac{e}{\|e\|}\cdot W
\right).
$$

因此新的半边向量定义为：

$$
\boxed{
N(e)=\phi\frac{e}{\|e\|}.
}
$$

虽然公式中出现的是 $e/\|e\|$，但 $\phi$ 自身带符号，因此：

$$
\boxed{
N(e)
=
|\phi|
\frac{(e\times a)\times(b\times e)}
{\|(e\times a)\times(b\times e)\|}.
}
$$

所以新旧两个向量的方向严格一致，改变的只有模长：

$$
\boxed{
\|N_{old}(e)\|=|\sin\phi|,
\qquad
\|N(e)\|=|\phi|.
}
$$

在小角度区域：

$$
\sin\phi
=
\phi-\frac{\phi^3}{6}+O(\phi^5),
$$

所以新算法保留了旧算法在平滑区域的一阶行为。

---

## 3. 带符号角度对 $e,a,b$ 的梯度

为了后续求 $N(e)$ 的雅可比，需要 $\phi$ 对三个局部向量的导数。

这里不再额外定义 $q_e,q_a,q_b$，直接写成原始变量。

### 3.1 对 $a$ 的梯度

$$
\boxed{
\frac{\partial\phi}{\partial a}
=
-\|e\|
\frac{e\times a}{\|e\times a\|^2}.
}
$$

### 3.2 对 $b$ 的梯度

$$
\boxed{
\frac{\partial\phi}{\partial b}
=
-\|e\|
\frac{b\times e}{\|b\times e\|^2}.
}
$$

### 3.3 对 $e$ 的梯度

$$
\boxed{
\frac{\partial\phi}{\partial e}
=
\frac{a\cdot e}{\|e\|}
\frac{e\times a}{\|e\times a\|^2}
+
\frac{b\cdot e}{\|e\|}
\frac{b\times e}{\|b\times e\|^2}.
}
$$

这三个公式已经适合直接转换成代码，不需要矩阵中间量。

如果需要对四个原始顶点求角度梯度，由：

$$
e=p_1-p_0,\qquad a=p_2-p_0,\qquad b=p_3-p_0
$$

直接得到：

$$
\boxed{
\frac{\partial\phi}{\partial p_1}
=
\frac{\partial\phi}{\partial e},
}
$$

$$
\boxed{
\frac{\partial\phi}{\partial p_2}
=
\frac{\partial\phi}{\partial a},
}
$$

$$
\boxed{
\frac{\partial\phi}{\partial p_3}
=
\frac{\partial\phi}{\partial b},
}
$$

$$
\boxed{
\frac{\partial\phi}{\partial p_0}
=-
\left(
\frac{\partial\phi}{\partial e}
+
\frac{\partial\phi}{\partial a}
+
\frac{\partial\phi}{\partial b}
\right).
}
$$

---

## 4. 新半边向量 $N(e)$ 的雅可比

新的半边向量为：

$$
N(e)=\phi\frac{e}{\|e\|}.
$$

### 4.1 对 $e$ 的雅可比

直接展开后：

$$
\boxed{
\begin{aligned}
J_e
=&\frac{e}{\|e\|^2}
\left[
(a\cdot e)
\frac{e\times a}{\|e\times a\|^2}
+
(b\cdot e)
\frac{b\times e}{\|b\times e\|^2}
\right]^T\\[4pt]
&+
\frac{\phi}{\|e\|}
\left(
I-\frac{ee^T}{\|e\|^2}
\right).
\end{aligned}
}
$$

这里第一项表示二面角变化带来的 $N(e)$ 变化，第二项表示半边方向变化带来的 $N(e)$ 变化。

### 4.2 对 $a$ 的雅可比

$$
\boxed{
J_a
=
-\frac{e(e\times a)^T}{\|e\times a\|^2}.
}
$$

### 4.3 对 $b$ 的雅可比

$$
\boxed{
J_b
=
-\frac{e(b\times e)^T}{\|b\times e\|^2}.
}
$$

可以看到，新的精确角度定义下，$J_a$ 和 $J_b$ 都非常简单，只是两个秩一外积。

### 4.4 对四个顶点的雅可比

$$
\boxed{
\frac{\partial N}{\partial p_1}=J_e,
\qquad
\frac{\partial N}{\partial p_2}=J_a,
\qquad
\frac{\partial N}{\partial p_3}=J_b.
}
$$

而：

$$
\boxed{
\frac{\partial N}{\partial p_0}
=-(J_e+J_a+J_b).
}
$$

因此自动满足平移不变性：

$$
\frac{\partial N}{\partial p_0}
+
\frac{\partial N}{\partial p_1}
+
\frac{\partial N}{\partial p_2}
+
\frac{\partial N}{\partial p_3}
=0.
$$

---

## 5. 三角网格中的顶点能量

设中心顶点为 $v$，邻接顶点为 $v_i$。

对于所有指向 $v$ 的半边：

$$
h_i=(v_i,v),
$$

按照第 1、2 节计算对应的 $N(h_i)$。

定义：

$$
\boxed{
\bar N(v)=\sum_{h_i=(v_i,v)}N(h_i).
}
$$

顶点局部能量为：

$$
\boxed{
E(v)=\|\bar N(v)\|^2.
}
$$

整个网格总能量为：

$$
\boxed{
\mathcal E
=
\sum_v\|\bar N(v)\|^2.
}
$$

由于一个顶点的位置不仅影响自己的 $E(v)$，还会影响邻接顶点和二环邻域顶点的 $\bar N$，因此完整梯度仍然分成：

$$
\boxed{
\nabla_p\mathcal E
=
\nabla_pE_1
+
\nabla_pE_2.
}
$$

其中：

- $E_1$：当前顶点作为半边端点时的贡献；
- $E_2$：当前顶点作为相邻三角形第三点时的贡献。

---

## 6. 邻接半边贡献 $E_1$

设当前顶点为 $v$，邻接半边为：

$$
he=(v_i,v),
\qquad
e=v-v_i.
$$

该半边两侧另外两个顶点仍记为 $p_2,p_3$，因此：

$$
a=p_2-v_i,
\qquad
b=p_3-v_i.
$$

对应带符号角度为：

$$
\boxed{
\phi
=
\operatorname{atan2}
\left(
-\|e\|[e\cdot(a\times b)],
(e\times a)\cdot(b\times e)
\right).
}
$$

该半边对应的顶点能量残差为：

$$
\bar N(v)-\bar N(v_i).
$$

因此：

$$
\boxed{
\begin{aligned}
\nabla_pE_1(v)
=2\sum_{he=(v_i,v)}
\Bigg\{
&
\left[
(a\cdot e)
\frac{e\times a}{\|e\times a\|^2}
+
(b\cdot e)
\frac{b\times e}{\|b\times e\|^2}
\right]
\frac{
e\cdot[\bar N(v)-\bar N(v_i)]
}{\|e\|^2}
\\[5pt]
&+
\frac{\phi}{\|e\|}
\left[
\bar N(v)-\bar N(v_i)
-
e\frac{
e\cdot[\bar N(v)-\bar N(v_i)]
}{\|e\|^2}
\right]
\Bigg\}.
\end{aligned}
}
$$

这就是邻接边部分最终可以直接转成代码的完整公式。

---

## 7. 环状边贡献 $E_2$

对于二环邻域中的半边：

$$
he=(v_j,v_i),
\qquad
e=v_i-v_j.
$$

对应残差为：

$$
\bar N(v_i)-\bar N(v_j).
$$

### 7.1 当前待求顶点 $v$ 是 $p_2$

此时：

$$
a=v-v_j.
$$

因为：

$$
J_a^Tr
=
-\frac{e\times a}{\|e\times a\|^2}(e\cdot r),
$$

所以环状边贡献直接为：

$$
\boxed{
\nabla_pE_{2,a}(v)
=
-2\sum_{he=(v_j,v_i)}
\frac{e\times a}{\|e\times a\|^2}
\left[
e\cdot[\bar N(v_i)-\bar N(v_j)]
\right]
}
$$

### 7.2 当前待求顶点 $v$ 是 $p_3$

此时：

$$
b=v-v_j.
$$

对应：

$$
\boxed{
\nabla_pE_{2,b}(v)
=
-2\sum_{he=(v_j,v_i)}
\frac{b\times e}{\|b\times e\|^2}
\left[
e\cdot[\bar N(v_i)-\bar N(v_j)]
\right]
}
$$

如果现有拓扑遍历能够统一把待求顶点放到 $p_2$，那么实现中只保留第一种分支即可。

---

## 8. 最终顶点梯度

对于待求顶点 $v$：

$$
\boxed{
\nabla_p\mathcal E(v)
=
\nabla_pE_1(v)
+
\nabla_pE_2(v).
}
$$

位置更新为：

$$
\boxed{
p_v^{new}
=
p_v^{old}
-\eta\nabla_p\mathcal E(v).
}
$$

其中 $\eta>0$ 为步长。

建议全部梯度都基于同一份旧顶点位置计算完成后，再统一更新顶点，避免 Gauss-Seidel 式的新旧坐标混用。

---

## 9. 退化情况与数值处理

为了简洁考虑，退化情况暂不讨论

---

## 10. 半边反向关系

当前半边为：

$$
(p_0,p_1,p_2,p_3).
$$

反向半边必须同时交换端点和两侧第三点：

$$
\boxed{
(p_1,p_0,p_3,p_2).
}
$$

此时新的精确角度保持不变：

$$
\phi_{reverse}=\phi,
$$

而边方向改变：

$$
e_{reverse}=-e.
$$

所以：

$$
\boxed{
N(reverse)=-N(forward).
}
$$

这个反对称性质是：

$$
\bar N(v)-\bar N(v_i)
$$

能够出现在 $E_1$ 梯度中的基础。

---

## 11. 边界半边

边界半边缺少一侧真实三角形，因此无法直接得到完整的 $p_2,p_3$。

可以继续使用原算法中的处理方式：



1. 构造 ghost 顶点形成第二个三角形。这个三角形是虚拟的，ghost点位置是固定的，所以ghost点不参与梯度贡献，只方便计算边界边相关点的能量和梯度计算。
2. 直接跳过此boundary边的计算，也就是假设它的N(e)=0.

---

## 12. 推荐的完整计算流程

一次平滑迭代推荐按以下顺序执行。

### 第一步：计算所有半边 $N(e)$

对每条需要参与平滑的半边：

1. 读取 $p_0,p_1,p_2,p_3$；
2. 计算 $e,a,b$；
3. 检查 $\|e\|^2$、$\|e\times a\|^2$、$\|b\times e\|^2$；
4. 计算：

$$
\phi
=
\operatorname{atan2}
\left(
-\|e\|[e\cdot(a\times b)],
(e\times a)\cdot(b\times e)
\right);
$$

5. 计算：

$$
N(e)=\phi\frac{e}{\|e\|}.
$$

### 第二步：计算所有顶点的 $\bar N$

$$
\boxed{
\bar N(v)=\sum_{he=(v_i,v)}N(he).
}
$$

### 第三步：计算邻接半边贡献 $E_1$

对每个顶点遍历 `adjacent_halfedges`，使用第 7 节的展开公式。

### 第四步：计算环状边贡献 $E_2$

对每个顶点遍历 `surrounding_halfedges`，使用第 8 节的展开公式。

### 第五步：合并梯度

$$
\boxed{
\nabla_p\mathcal E(v)
=
\nabla_pE_1(v)
+
\nabla_pE_2(v).
}
$$

### 第六步：统一更新顶点

$$
\boxed{
p_v^{new}
=
p_v^{old}
-\eta\nabla_p\mathcal E(v).
}
$$

所有梯度应先根据旧坐标计算完毕，再统一更新，便于并行化并避免遍历顺序影响结果。

---

## 13. 实现校验

### 13.1 方向校验

对于非零角度、非退化半边，新 $N(e)$ 必须满足：

$$
\boxed{
N(e)\cdot[(e\times a)\times(b\times e)]>0.
}
$$

如果该值小于零，优先检查：

1. $p_2,p_3$ 是否放反；
2. 半边方向是否与面方向一致；
3. `atan2` 是否误写成 `atan2(x,y)`；
4. 第一个参数前面的负号是否遗漏。

### 13.2 平移不变性

单条内部半边对四个顶点的雅可比应满足：

$$
\boxed{
J_{p_0}+J_{p_1}+J_{p_2}+J_{p_3}=0.
}
$$

### 13.3 有限差分校验

对任意一个顶点坐标分量 $x$，使用中心差分：

$$
\boxed{
\frac{\partial\mathcal E}{\partial x}
\approx
\frac{
\mathcal E(x+h)-\mathcal E(x-h)
}{2h}.
}
$$

将其与解析梯度对应分量比较。

建议先对单条内部半边验证 $J_e^Tr,J_a^Tr,J_b^Tr$，确认无误后再验证完整 $E_1+E_2$。

---

# 最终核心公式汇总

实际写代码时，最重要的公式可以压缩为下面几组。

## 半边几何

$$
e=p_1-p_0,
\qquad
a=p_2-p_0,
\qquad
b=p_3-p_0.
$$

## 带符号精确二面角

$$
\boxed{
\phi
=
\operatorname{atan2}
\left(
-\|e\|[e\cdot(a\times b)],
(e\times a)\cdot(b\times e)
\right).
}
$$

## 新半边向量

$$
\boxed{
N(e)=\phi\frac{e}{\|e\|}.
}
$$

## 邻接端点所需的 $J_e^Tr$

$$
\boxed{
\begin{aligned}
J_e^Tr
=&
\left[
(a\cdot e)
\frac{e\times a}{\|e\times a\|^2}
+
(b\cdot e)
\frac{b\times e}{\|b\times e\|^2}
\right]
\frac{e\cdot r}{\|e\|^2}
\\[4pt]
&+
\frac{\phi}{\|e\|}
\left[
r-e\frac{e\cdot r}{\|e\|^2}
\right].
\end{aligned}
}
$$

## 第三个顶点所需的 $J_a^Tr$

$$
\boxed{
J_a^Tr
=
-\frac{e\times a}{\|e\times a\|^2}(e\cdot r).
}
$$

## 另一侧第三顶点所需的 $J_b^Tr$

$$
\boxed{
J_b^Tr
=
-\frac{b\times e}{\|b\times e\|^2}(e\cdot r).
}
$$

## 顶点总梯度

$$
\boxed{
\nabla_p\mathcal E(v)
=
\nabla_pE_1(v)
+
\nabla_pE_2(v).
}
$$

这套展开形式保留了精确角度算法的完整数学含义，但减少了大量仅用于推导的中间符号，更适合直接阅读并转换为 Zig/C++ 代码。
