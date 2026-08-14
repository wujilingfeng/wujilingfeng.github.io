你的关键疑问来自一个常见混淆：

$ \boxed{\text{Dirichlet 条件限制函数值；Neumann 条件限制法向导数。}} $

对于

$ -\Delta u=f\quad\text{in }\Omega,\qquad \frac{\partial u}{\partial n}=g\quad\text{on }\partial\Omega, $

Neumann 条件对应的函数空间不是

$ u|_{\partial\Omega}=g, $

而通常仍然是

$ u\in H^1(\Omega). $

$g$ 通过弱形式中的边界积分进入右端项，而不是通过固定边界基函数系数进入。Neumann 因此被称为自然边界条件。([Jørgen S. Dokken](https://jsdokken.com/dolfinx-tutorial/chapter3/neumann_dirichlet_code.html?utm_source=chatgpt.com "Combining Dirichlet and Neumann conditions — FEniCSx tutorial"))

---

## 1. 你的 (+1) 镜像只表示齐次 Neumann 条件

设边界是 $x=0$，原始基函数为 $\phi(x)$。偶对称镜像

$ \phi^N(x)=\phi(x)+\phi(-x) $

满足

$ \frac{d\phi^N}{dx}(0)=0. $

因此对于任意系数 $c_i$，

$ u_h(x)=\sum_i c_i\phi_i^N(x) $

都有

$ \frac{\partial u_h}{\partial n}=0. $

也就是说，这个空间严格地是一个**齐次 Neumann 空间**。Kazhdan 等人的 B-spline 实现中，正镜像明确用于 "trivial Neumann boundary conditions"，即边界导数为零。

所以：

$ \boxed{\text{偶镜像} \Longrightarrow \partial_n u_h=0,\quad\text{而不是 }\partial_n u_h=g.} $

单位分解

$ \sum_i\phi_i^N(x)=1 $

只保证常数再现和离散一致性，并不能保证任意非零边界通量 $g$。

更重要的是：如果所有边界基函数都是偶镜像的，那么无论怎样限制系数，仍然有

$ \partial_nu_h=0. $

因此对 $g\neq0$，**仅仅约束这些基函数的系数是没有用的**。

---

## 2. 推荐方案：把 Neumann 条件放进弱形式

对

$ -\Delta u=f,\qquad \partial_nu=g, $

弱形式为

$ \int_\Omega\nabla u\cdot\nabla v\,dx = \int_\Omega fv\,dx + \int_{\partial\Omega}gv\,ds. $

离散后：

$ A_{ij} = \int_\Omega\nabla\phi_j\cdot\nabla\phi_i\,dx, $

$ b_i = \int_\Omega f\phi_i\,dx + \int_{\partial\Omega}g\phi_i\,ds. $

这里不需要固定边界系数。非齐次 Neumann 数据就是右端向量中的一个边界积分项。([Jørgen S. Dokken](https://jsdokken.com/dolfinx-tutorial/chapter3/neumann_dirichlet_code.html?utm_source=chatgpt.com "Combining Dirichlet and Neumann conditions — FEniCSx tutorial"))

但这时不能再使用“所有基函数法向导数都为零”的偶镜像空间。你需要使用不预先强制 $\partial_nu=0$ 的空间，例如：

- 保留所有支撑与 $\Omega$ 相交的 B-spline，包括一层或多层 ghost 基函数，并把 ghost 系数作为独立自由度；
- 使用 open/clamped knot 的边界 B-spline；
- 使用直接限制到 $\Omega$ 上的完整 B-spline 基；
- 使用专门构造的边界基，使它们在边界具有非零法向导数。

也就是说：

$ \boxed{\text{基函数空间负责表示一般 }H^1\text{ 函数，}g\text{ 负责进入右端项。}} $

### 泊松重建中的具体形式

泊松重建通常来自

$ \min_u\frac12\int_\Omega|\nabla u-V|^2dx. $

其离散方程为

$ \sum_jc_j \int_\Omega\nabla\phi_j\cdot\nabla\phi_i\,dx = \int_\Omega V\cdot\nabla\phi_i\,dx. $

这个能量的自然边界条件是

$ \partial_nu=V\cdot n. $

这是从梯度场最小二乘形式直接得到的。([Department of Computer Science](https://www.cs.jhu.edu/~misha/MyPapers/SIG08.pdf "Streaming Multigrid for Gradient-Domain Operations on Large Images"))

如果你希望指定另外的 Neumann 条件

$ \partial_nu=g, $

则右端改成

$ \boxed{ b_i= \int_\Omega V\cdot\nabla\phi_i\,dx + \int_{\partial\Omega}(g-V\cdot n)\phi_i\,ds } $

因为原始梯度能量默认已经包含了自然通量 $V\cdot n$。

因此：

- 若 $g=V\cdot n$，不需要额外边界项；
- 若外边界有足够 padding，使 $V\approx0$，则自然条件近似为齐次 Neumann；
- 若要求 $g=0$，但 $V\cdot n\neq0$，需要加入

$ -\int_{\partial\Omega}(V\cdot n)\phi_i\,ds. $

---

## 3. 必须保留偶镜像基时：使用 lifting

如果你的八叉树多重网格、嵌套性或 stencil 实现要求必须使用偶镜像基，那么应写成

$ u_h=u_g+v_h, $

其中

$ \partial_nu_g=g, \qquad \partial_nv_h=0. $

令

$ v_h=\sum_jc_j\phi_j^N, $

这里的 $\phi_j^N$ 就是现有的偶镜像基。离散系统变成

$ \sum_jc_j\,a(\phi_j^N,\phi_i^N) = L(\phi_i^N)-a(u_g,\phi_i^N), $

即

$ A c=b-Au_g. $

这样：

- 偶镜像基负责齐次部分；
- lifting $u_g$ 负责非齐次边界通量；
- 系数 $c_j$ 不需要额外限制。

关键是 $u_g$ 不能也由偶镜像基构成，否则它的法向导数仍然为零。你可以在八叉树边界附近增加一层非对称边界基，先求一个边界 lifting：

$ \int_{\partial\Omega} \mu_k\,\partial_nu_g\,ds = \int_{\partial\Omega}\mu_k g\,ds, $

然后在内部使用原来的镜像多重网格系统。

这是在不破坏现有偶镜像层级结构时，最干净的非齐次处理方式。

---

## 4. 如果一定要通过系数约束强制满足 $g$

必须改用在边界处法向导数不全为零的原始基函数 $\eta_j$。构造边界导数矩阵

$ C_{kj} = \int_{\partial\Omega} \mu_k\,\partial_n\eta_j\,ds, $

以及

$ d_k = \int_{\partial\Omega}\mu_k g\,ds. $

然后施加

$ Cc=d. $

可解增广系统

$ \begin{bmatrix} A&C^T\\ C&0 \end{bmatrix} \begin{bmatrix} c\\\lambda \end{bmatrix} = \begin{bmatrix} b\\d \end{bmatrix}. $

但注意：

$ \eta_j=\phi_j+\phi_j^{\mathrm{ghost}} \quad\Longrightarrow\quad \partial_n\eta_j=0, $

此时

$ C=0, $

所以 $d\neq0$ 时系统根本不可行。必须保留非对称基、独立 ghost 自由度，或者增加 lifting 基。

---

## 5. 纯 Neumann 系统还需要处理常数零空间

如果整个边界都是 Neumann 条件，刚度矩阵满足

$ A\mathbf 1=0, $

解只能确定到一个加法常数。单位分解恰好使常数函数成为离散零空间。

对

$ -\Delta u=f,\qquad\partial_nu=g, $

可解性要求

$ \boxed{ \int_\Omega f\,dx+ \int_{\partial\Omega}g\,ds=0 } $

离散上对应

$ z^Tb=0,\qquad Az=0, $

其中 $z$ 是常数函数的系数向量；在严格单位分解基下通常就是全 $1$ 向量。纯 Neumann 问题的奇异性、兼容条件和常数零空间需要显式处理。([FEniCS Project](https://oldqa.fenicsproject.org/2406/solve-poisson-problem-with-neumann-bc/?show=11705&utm_source=chatgpt.com "Solve Poisson problem with Neumann BC - FEniCS Q&A"))

可选择：

$ \int_\Omega u\,dx=0, $

或固定一个自由度，或向迭代求解器提供 nullspace 并将 $b$ 投影到其正交补。

---

## 对你的实现最直接的结论

### 当 $g=0$

继续使用

$ \phi_i^N=\phi_i+\phi_i^{\mathrm{ghost}} $

即可，不需要限制边界系数，但要处理常数零空间。

### 当 $g\neq0$

不能仅靠限制偶镜像基函数的系数。应选以下之一：

1. **推荐：**不绑定 ghost 镜像系数，使用一般边界基，在右端装配

$ \int_{\partial\Omega}g\phi_i\,ds. $

2. 保留偶镜像层级结构，但写成

$ u=u_g+v,\qquad \partial_nu_g=g,\quad\partial_nv=0. $

3. 使用具有非零边界法向导数的基，并通过 $Cc=d$ 的增广系统强制边界条件。

对于泊松表面重建的外层八叉树盒子，通常最省事的是增加 padding，让 $V$ 在盒子边界附近为零，然后采用齐次 Neumann 偶镜像；只有当你确实需要非零外边界通量时，才需要 lifting 或边界积分方案。
