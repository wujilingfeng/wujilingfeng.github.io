+++
author = 'libo'
date = '2026-04-12T10:50:58+08:00'
math= true
draft = false
title = '泊松重建'
+++


---
注意泊松重建构造的方程$Ax=b$中的A是奇异矩阵，因为含有特征值为0的特征向量(1,1,1....1)，要保证这个特性要限制定义域完全落在基函数单位分解的区域。dirichlet边界条件不用加$x_0=0$或$\sigma x=0$这种约束。

下面给出一套从连续理论到八叉树有限元离散的统一框架。为了避免概念混淆，先明确两个完全不同的"边界"：

* **待重建物体的表面** $\partial M$：未知，是最终要提取的等值面；
* **计算域的外边界** $\Gamma=\partial\Omega$：通常是包围点云的立方体或八叉树根节点边界，Dirichlet、Neumann 条件施加在这里。
原始 Poisson 重建利用广义 Stokes/散度定理把 $\partial M$ 上的法向信息转化成指示函数的梯度；有限元弱形式则再次利用分部积分，在 $\partial\Omega$ 上产生边界项。这两次出现的"边界"不是同一个边界。原始论文也是先从指示函数与表面法向的积分关系出发，再构造向量场并求解空间 Poisson 方程。([Hugues Hoppe][1])
---
# 一、Poisson 重建到底在求什么
设未知实体为
$$
M\subset\mathbb R^3,
$$
定义其指示函数
$$
\chi_M(x)=
\begin{cases}
1,&x\in M,\\
0,&x\notin M.
\end{cases}
$$
如果能够恢复 $\chi_M$，那么物体表面就是它的跳变位置。实际计算得到的是平滑近似 $\chi$，最后提取某个等值面：
$$
S=\{x\in\Omega:\chi(x)=\gamma\}.
$$
Screened Poisson 常把点云位置约束到
$$
\chi(p_i)\approx \frac12,
$$
因此通常取 $\gamma=0.5$。原始非 screened 方法则常用所有输入点上的平均函数值作为等值面值：
$$
\gamma=\frac{1}{N}\sum_{i=1}^{N}\chi(p_i).
$$
这样，即使 $\chi$ 存在整体缩放或平移，等值面仍可以保持一致。原始论文明确采用输入点函数值的平均值确定等值面。([Hugues Hoppe][1])
---
# 二、广义 Stokes 公式如何把法向变成指示函数梯度
这是 Poisson 重建最核心的理论起点。
## 2.1 指示函数的梯度不是普通函数
$\chi_M$ 在内部和外部都是常数，所以普通意义下
$$
\nabla\chi_M=0
$$
几乎处处成立。
但它在表面 $\partial M$ 发生跳变，因此从**分布意义**看，梯度集中在表面上。
设 $\varphi$ 是光滑测试函数，取外法向为 $n_{\mathrm{out}}$。分布导数定义为
$$
\langle \partial_j\chi_M,\varphi\rangle
= -\langle\chi_M,\partial_j\varphi\rangle
= -\int_M\partial_j\varphi\,dx.
$$
利用散度定理：
$$
\int_M\partial_j\varphi\,dx
= \int_{\partial M}\varphi n_{\mathrm{out},j}\,dS.
$$
所以
$$
\langle \partial_j\chi_M,\varphi\rangle
= -\int_{\partial M}\varphi n_{\mathrm{out},j}\,dS.
$$
若使用内法向
$$
n_{\mathrm{in}}=-n_{\mathrm{out}},
$$
则
$$
\langle \partial_j\chi_M,\varphi\rangle
= \int_{\partial M}\varphi n_{\mathrm{in},j}\,dS.
$$
因此可以形式化地写成
$$
\boxed{
\nabla\chi_M=n_{\mathrm{in}}\delta_{\partial M}
}
$$
其中 $\delta_{\partial M}$ 是集中在物体表面上的面 Dirac 分布。
这就是"指示函数梯度等于表面法向场"的严格含义。
---
## 2.2 为什么需要平滑核
直接使用 $\nabla\chi_M$ 会得到表面上的奇异分布，因此引入平滑核 $F$：
$$
\widetilde\chi=\chi_M*F.
$$
利用微分与卷积可交换：
$$
\nabla\widetilde\chi
= \nabla(\chi_M*F)
= (\nabla\chi_M)*F.
$$
代入表面分布：
$$
\boxed{
\nabla\widetilde\chi(q)
= \int_{\partial M}
F(q-p)n_{\mathrm{in}}(p)\,dS(p)
}
$$
这就是原始 Poisson 重建论文中的核心积分关系。论文利用散度定理证明，平滑指示函数的梯度等于经过相同平滑核处理的表面法向场。([Hugues Hoppe][1])
---
## 2.3 用离散有向点近似积分
输入点云为
$$
P=\{(p_s,n_s)\}_{s=1}^{N},
$$
其中 $n_s$ 是一致定向的法向。
将表面分成每个采样点对应的小面片 $P_s$，可近似为
$$
\nabla\widetilde\chi(q)
\approx
\sum_s |P_s|F(q-p_s)n_s.
$$
定义向量场
$$
\boxed{
V(q)=\sum_s w_s F(q-p_s)n_s
}
$$
其中 $w_s\approx |P_s|$ 是局部面积或密度补偿权重。
于是目标变成：
$$
\nabla\chi\approx V.
$$
原始论文也是将表面积分用有向点和面片面积的加权和近似，再把结果记作向量场 $V$。([Hugues Hoppe][1])
---
# 三、为什么得到的是 Poisson 方程
由于点云噪声、法向误差、离散误差以及采样不均匀，构造出的 $V$ 通常不是严格可积场：
$$
\nabla\times V\neq 0.
$$
因此一般不存在一个函数 $\chi$ 能够处处满足
$$
\nabla\chi=V.
$$
于是改为求最小二乘意义下最接近的梯度场：
$$
\boxed{
E_0(\chi)
= \frac12\int_\Omega
|\nabla\chi-V|^2\,dx
}
$$
这比直接写
$$
\Delta\chi=\nabla\cdot V
$$
更基础，因为 Poisson 方程实际上是这个能量的 Euler–Lagrange 方程。
原始 Poisson 重建将问题描述为寻找梯度最接近 $V$ 的指示函数，并由此得到
$$
\Delta\chi=\nabla\cdot V.
$$
([Hugues Hoppe][1])
---
# 四、从能量到带边界条件的 Poisson 方程
取任意扰动函数 $\phi$，令
$$
\chi_\varepsilon=\chi+\varepsilon\phi.
$$
能量的一阶变分为
$$
\left.\frac{d}{d\varepsilon}
E_0(\chi+\varepsilon\phi)
\right|_{\varepsilon=0}
= \int_\Omega
(\nabla\chi-V)\cdot\nabla\phi\,dx.
$$
极小值要求
$$
\boxed{
\int_\Omega
\nabla\chi\cdot\nabla\phi\,dx
= \int_\Omega
V\cdot\nabla\phi\,dx
}
$$
对所有允许的测试函数 $\phi$ 成立。
这就是最基本的**弱形式**。
## 4.1 使用广义 Stokes/Green 公式
取
$$
W=\phi(\nabla\chi-V).
$$
有
$$
\nabla\cdot W
= (\nabla\chi-V)\cdot\nabla\phi
+
\phi(\Delta\chi-\nabla\cdot V).
$$
在 $\Omega$ 上积分并应用散度定理：

$\int  \nabla \cdot W dx=\int_{\Gamma} (\nabla \cdot W) \cdot n dS$(散度公式)
$$
\int_\Omega
(\nabla\chi-V)\cdot\nabla\phi\,dx
= -\int_\Omega
\phi(\Delta\chi-\nabla\cdot V)\,dx
+
\int_{\Gamma}
\phi(\partial_n\chi-V\cdot n)\,dS.
$$
因此平稳条件是
$$
-\int_\Omega
\phi(\Delta\chi-\nabla\cdot V)\,dx
+
\int_{\Gamma}
\phi(\partial_n\chi-V\cdot n)\,dS
=0.
$$
如果 $\phi$ 在内部和边界上都可以任意变化，就得到(强形式就是令两项都为0即可)：
$$
\boxed{
\Delta\chi=\nabla\cdot V
\qquad\text{in }\Omega
}
$$
以及自然边界条件
$$
\boxed{
\partial_n\chi=V\cdot n
\qquad\text{on }\Gamma.
}
$$
所以，完整的强形式并不只是
$$
\Delta\chi=\nabla\cdot V,
$$
而是
$$
\boxed{
\begin{cases}
\Delta\chi=\nabla\cdot V,&x\in\Omega,\\
\partial_n\chi=V\cdot n,&x\in\partial\Omega.
\end{cases}
}
$$
弱形式通过 Green 公式把二阶导数转移成一阶导数，并自然产生边界项；这也是有限元处理 Poisson 方程的标准方式。([挪威科技大学数学系][2])
---
# 五、Neumann、Dirichlet 和混合边界条件
设
$$
\Gamma=\Gamma_D\cup\Gamma_N,
\qquad
\Gamma_D\cap\Gamma_N=\varnothing.
$$
## 5.1 Dirichlet 边界条件
规定函数值：
$$
\boxed{
\chi=g_D
\quad\text{on }\Gamma_D.
}
$$
此时试探空间为
$$
H^1_{g_D}(\Omega)
= \{u\in H^1(\Omega):u|_{\Gamma_D}=g_D\},
$$
测试函数必须满足
$$
\phi=0
\quad\text{on }\Gamma_D.
$$
弱形式为：
$$
\int_\Omega\nabla\chi\cdot\nabla\phi\,dx
= \int_\Omega V\cdot\nabla\phi\,dx
+
\int_{\Gamma_N}
(g_N-V\cdot n)\phi\,dS.
$$
对所有
$$
\phi\in H^1_{0,\Gamma_D}(\Omega)
$$
成立。
在 Poisson 重建中，常见的齐次 Dirichlet 条件是
$$
\chi=0
\quad\text{on }\Gamma.
$$
因为约定物体外部指示函数为零，它会强迫重建表面在计算域内部闭合。
2020 年的 envelope-constrained Poisson 重建把这种思想扩展到一般包络面：通过限制 B-spline 支撑域，使隐式函数在包络外部为零，从而把重建表面限制在包络内部。([普林斯顿图形组][3])
### 离散实现
对于齐次 Dirichlet 条件，可以：
1. 删除或修改与外部区域重叠的基函数；
2. 保留基函数，但固定相应自由度；
3. 对非齐次条件先构造 lifting：
   $$
   \chi=\chi_0+\chi_g,
   $$
   其中 $\chi_g|_{\Gamma_D}=g_D$，再求 $\chi_0|_{\Gamma_D}=0$。
---
## 5.2 Neumann 边界条件
规定法向导数：
$$
\boxed{
\partial_n\chi=g_N
\quad\text{on }\Gamma_N.
}
$$
其弱形式为
$$
\boxed{
\int_\Omega
\nabla\chi\cdot\nabla\phi\,dx
= \int_\Omega
V\cdot\nabla\phi\,dx
+
\int_{\Gamma_N}
(g_N-V\cdot n)\phi\,dS.
}
$$
特别地，从最小化
$$
\int_\Omega|\nabla\chi-V|^2
$$
自然得到的条件是
$$
g_N=V\cdot n.
$$


因此边界积分消失：
$$
\int_\Omega\nabla\chi\cdot\nabla\phi
= \int_\Omega V\cdot\nabla\phi.
$$
也就是neuman边界条件是蕴含在V中的，直接用梯度场V限制，在离散求解中正常求解即可。

如果 $V$ 在计算域边界附近已经衰减到零，那么
$$
V\cdot n\approx0,
$$
自然条件近似为齐次 Neumann：
$$
\partial_n\chi=0.
$$
官方 PoissonRecon 实现支持 Free、Dirichlet、Neumann 三种有限元边界类型，当前重建程序默认使用 Neumann；其 `pointWeight=0` 对应原始非 screened Poisson。([GitHub][4])
---
## 5.3 Neumann 问题的兼容条件
对
$$
\Delta\chi=\nabla\cdot V
$$
在整个 $\Omega$ 上积分：
$$
\int_\Omega\Delta\chi\,dx
= \int_\Omega\nabla\cdot V\,dx.
$$
利用散度定理：
$$
\int_\Gamma\partial_n\chi\,dS
= \int_\Gamma V\cdot n\,dS.
$$
所以一般 Neumann 数据必须满足
$$
\boxed{
\int_\Gamma g_N\,dS
= \int_\Gamma V\cdot n\,dS.
}
$$
自然条件 $g_N=V\cdot n$ 自动满足这一要求。
若强行设置齐次 Neumann：
$$
g_N=0,
$$
就需要
$$
\int_\Gamma V\cdot n\,dS=0.
$$
如果 $V$ 的支撑完全位于计算域内部，这一条件通常自动成立。
---
# 六、强形式和弱形式究竟有什么区别
| 项目         | 强形式                           | 弱形式                                                |
| ------------ | -------------------------------- | ----------------------------------------------------- |
| 方程         | $\Delta\chi=\nabla\cdot V$       | $\int\nabla\chi\cdot\nabla\phi=\int V\cdot\nabla\phi$ |
| 正则性       | 通常要求 $\chi$ 有二阶导数       | 只要求一阶弱导数                                      |
| 解空间       | 如 $C^2$、$H^2$                  | 通常为 $H^1$                                          |
| 边界条件     | 直接写在 PDE 后面                | 部分编码在函数空间，部分出现在边界积分中              |
| 有限元适用性 | 不能直接用分片低阶基函数逐点满足 | 非常适合 Galerkin/FEM                                 |
| 含噪、分布源 | 较难解释                         | 可以自然处理弱导数和分布右端项                        |
## 6.1 强解一定是弱解
如果 $\chi$ 足够光滑，并满足强形式和相应边界条件，那么通过分部积分可以证明它一定满足弱形式。
## 6.2 弱解不一定是经典强解
弱解可能只有分片一阶可微，二阶导数可能不存在于普通函数意义下。但在额外正则性条件成立时，弱解可以提升为强解。
## 6.3 有限元实际求的是弱解
你的八叉树基函数可能是截断 B-spline、分片多项式或有限元基函数。它们通常只有有限阶连续性，不适合逐点计算
$$
\Delta\chi.
$$
但
$$
\nabla B_i
$$
以及积分
$$
\int\nabla B_i\cdot\nabla B_j
$$
是良好定义的，所以代码应主要基于弱形式组装。
---
# 七、为什么只写 Poisson 方程不能得到唯一解
你提出的疑问是：
> 明明根据强形式或弱形式能够得到唯一的解 $x$，为什么还要限制边界条件？
> 关键是：
$$
\boxed{\text{只给内部 PDE，通常根本没有唯一解。}}
$$
## 7.1 一个最简单的一维例子
考虑
$$
u''(x)=0,\qquad x\in(0,1).
$$
所有
$$
u(x)=ax+b
$$
都是解。
仅凭内部方程无法确定 $a,b$。
加入 Dirichlet 条件：
$$
u(0)=0,\qquad u(1)=0,
$$
才得到唯一解
$$
u=0.
$$
加入 Neumann 条件：
$$
u'(0)=u'(1)=0,
$$
只能推出
$$
a=0,
$$
但
$$
u=b
$$
中的常数 $b$ 仍然任意。
---
## 7.2 三维中的情况更严重
假设 $\chi_1,\chi_2$ 都满足
$$
\Delta\chi=\nabla\cdot V.
$$
令
$$
h=\chi_1-\chi_2,
$$
则
$$
\Delta h=0.
$$
也就是说，两个解可以相差任意调和函数。
所以仅有内部 Poisson 方程时，解并不是只差一个常数，而是可以相差整个调和函数空间。只有加入边界条件后，才会把这些自由度限制掉。
---
## 7.3 纯 Neumann 为什么只差一个常数
如果两个解还满足相同 Neumann 条件，则
$$
\Delta h=0,
\qquad
\partial_n h=0.
$$
有
$$
\int_\Omega|\nabla h|^2\,dx
= -\int_\Omega h\Delta h\,dx
+
\int_\Gamma h\partial_nh\,dS
=0.
$$
因此
$$
\nabla h=0,
$$
所以 $h$ 只能是常数。
因此纯 Neumann Poisson 问题通常是：
$$
\boxed{\text{解存在时，只在加法常数意义下唯一。}}
$$
可以通过下列方式固定：
$$
\int_\Omega\chi\,dx=0,
$$
或者固定一个自由度：
$$
x_k=0,
$$
或者指定输入点上的平均函数值。
---
## 7.4 "线性系统解唯一"不代表 PDE 本身不需要边界条件
当你得到
$$
Ax=b
$$
时，矩阵 $A$ 已经包含了以下选择：
* 计算域；
* 基函数空间；
* 边界附近如何截断或修改基函数；
* Dirichlet 自由度是否删除；
* 是否加入 screening；
* 是否固定常数零空间；
* 测试函数空间。
也就是说，边界条件往往已经被你**隐式写进矩阵**了。
因此：
$$
\boxed{
Ax=b\text{ 唯一}
\not\Rightarrow
\text{未指定边界条件的连续 PDE 唯一}.
}
$$
更准确地说，是"基函数空间、边界处理和 screening 共同定义的离散问题"具有唯一解。
---
# 八、Screened Poisson 重建
传统 Poisson 只约束梯度：
$$
\nabla\chi\approx V.
$$
它对低频误差比较宽容，可能出现表面收缩、平滑过度或偏离输入点。
Screened Poisson 额外要求输入点接近指定等值面：
$$
\chi(p_s)\approx a_s.
$$
通常
$$
a_s=\frac12.
$$
定义能量：
$$
\boxed{
E_{\mathrm{SP}}(\chi)
= \frac12
\int_\Omega
|\nabla\chi-V|^2\,dx
+
\frac{\lambda}{2}
\sum_s\eta_s
\big(\chi(p_s)-a_s\big)^2
}
$$
其中：
* $\lambda$：screening 权重；
* $\eta_s$：采样点权重或置信度；
* $a_s$：目标函数值，通常为 $0.5$。
Screened Poisson 的特征是 screening 项只定义在稀疏输入点上，而不是整个三维计算域中。该方法正是为了在 Poisson 梯度拟合之外显式加入点位置插值约束。([Department of Computer Science][5])
---
## 8.1 Screened Poisson 的弱形式
对 $\chi$ 做变分：
$$
\int_\Omega
(\nabla\chi-V)\cdot\nabla\phi\,dx
+
\lambda
\sum_s\eta_s
(\chi(p_s)-a_s)\phi(p_s)
=0.
$$
所以
$$
\boxed{
\int_\Omega
\nabla\chi\cdot\nabla\phi\,dx
+
\lambda\sum_s\eta_s
\chi(p_s)\phi(p_s)
= \int_\Omega
V\cdot\nabla\phi\,dx
+
\lambda\sum_s\eta_s
a_s\phi(p_s).
}
$$
这是代码组装最应使用的形式。
---
## 8.2 Screened Poisson 的形式强方程
引入采样算子
$$
S\chi=
\begin{bmatrix}
\chi(p_1)\\
\vdots\\
\chi(p_N)
\end{bmatrix},
$$
权重矩阵
$$
W=\operatorname{diag}(\eta_1,\dots,\eta_N),
$$
则能量可写为
$$
E(\chi)
= \frac12|\nabla\chi-V|_{L^2}^2
+
\frac{\lambda}{2}|S\chi-a|_W^2.
$$
Euler–Lagrange 方程是
$$
\boxed{
-\Delta\chi
+
\lambda S^*WS\chi
= -\nabla\cdot V
+
\lambda S^*Wa.
}
$$
如果形式化地把点采样写成 Dirac 分布：
$$
\boxed{
-\Delta\chi
+
\lambda\sum_s
\eta_s\chi(p_s)\delta_{p_s}
= -\nabla\cdot V
+
\lambda\sum_s
\eta_s a_s\delta_{p_s}.
}
$$
这与经典的全域 screened Poisson
$$
-\Delta\chi+\lambda\chi=f
$$
不同。Poisson 表面重建使用的是**稀疏点 screening**。
严格地说，在三维无限维 $H^1$ 空间中，任意点值不是连续泛函，因此上述 Dirac 强形式主要是一种形式表达。实际代码中 $\chi_h$ 位于连续的有限维 B-spline 空间，$\chi_h(p_s)$ 可以直接计算，因此离散能量是完全明确的。
---
# 九、离散后得到什么矩阵
设你已经构造出八叉树基函数
$$
\{B_j\}_{j=1}^{m},
$$
表示
$$
\chi_h(x)=\sum_{j=1}^{m}x_jB_j(x).
$$
令测试函数取 $B_i$。
## 9.1 Poisson 刚度矩阵
$$
\boxed{
A_{ij}
= \int_\Omega
\nabla B_i\cdot\nabla B_j\,dx
}
$$
右端项：
$$
\boxed{
b_i
= \int_\Omega
V\cdot\nabla B_i\,dx.
}
$$
于是非 screened 系统为
$$
\boxed{
Ax=b.
}
$$
其中 $A$ 是对称半正定矩阵。
对于纯 Neumann 边界，如果基函数能够表示常数，则
$$
A\mathbf c=0
$$
其中 $\mathbf c$ 是表示常数函数的系数向量。
---
## 9.2 Screened 矩阵
定义
$$
C_{ij}
= \sum_s
\eta_s B_i(p_s)B_j(p_s),
$$
以及
$$
d_i
= \sum_s
\eta_s a_sB_i(p_s).
$$
最终线性系统为
$$
\boxed{
(A+\lambda C)x
= b+\lambda d.
}
$$
其中：
$$
A_{ij}
= \int\nabla B_i\cdot\nabla B_j,
$$
$$
C_{ij}
= \sum_s\eta_sB_i(p_s)B_j(p_s),
$$
$$
b_i
= \int V\cdot\nabla B_i,
$$
$$
d_i
= \sum_s\eta_s a_sB_i(p_s).
$$
Screened Poisson 的有限元离散会产生稀疏、对称、通常正定的线性系统，并可利用八叉树层次结构进行多重网格求解。([普林斯顿图形组][3])
---
# 十、Screening 为什么能消除常数零空间
对任意常数 $c$：
$$
\nabla(\chi+c)=\nabla\chi.
$$
所以非 screened 能量满足
$$
E_0(\chi+c)=E_0(\chi).
$$
它无法确定函数的整体偏移。
但 screened 项变为
$$
\sum_s
(\chi(p_s)+c-a_s)^2,
$$
一般会随 $c$ 改变。
因此，只要至少有有效采样约束，screening 就会惩罚常数模式，使
$$
A+\lambda C
$$
从半正定变为正定。
不过这不等于"screened Poisson 不需要边界条件"。
原因是：当你把能量定义在整个 $H^1(\Omega)$ 中时，已经隐式采用了自然边界条件
$$
\partial_n\chi=V\cdot n.
$$
screening 解决的是常数零空间和数据贴合问题；边界条件仍决定函数在计算域边缘的行为。
---
# 十一、Dirichlet、Neumann 对重建结果有什么实际影响
## 11.1 Dirichlet
例如
$$
\chi=0\quad\text{on }\partial\Omega.
$$
作用是：
* 明确把计算域边缘定义为物体外部；
* 强迫等值面在边界之前闭合；
* 消除常数零空间；
* 对缺失区域具有较强形状约束。
缺点是如果计算框太紧，零值边界会把等值面向内部拉，造成收缩。
## 11.2 Neumann
例如
$$
\partial_n\chi=0.
$$
作用是：
* 函数在边界法向方向上不变化；
* 边界值本身不被固定；
* 相对较少强迫物体收缩；
* 但可能使缺失区域的闭合位置不受控制。
Envelope-constrained 重建实验表明，立方体上的 Dirichlet 条件能保证表面在立方体内部闭合，但不能精确控制闭合位置；Neumann 条件甚至不能保证重建一定在立方体内部闭合。使用更符合观测几何的 Dirichlet 包络可以更好地控制缺失区域。([普林斯顿图形组][3])
---
# 十二、关于 PoissonRecon 中的 Free boundary
官方代码列出了：
* `1`: Free；
* `2`: Dirichlet；
* `3`: Neumann。
([GitHub][4])
这里的 **Free** 不建议简单理解成第三种经典 PDE 边界条件。更准确地说，它是有限元基函数在计算域边缘的一种构造策略：不专门要求基函数满足齐次 Dirichlet 或齐次 Neumann 条件。
因此在你自己的代码中，需要区分：
1. 连续 PDE 中想表达什么边界行为；
2. 边界 B-spline 是截断、镜像、重构，还是直接删除；
3. 由该基函数空间实际隐含的边界条件是什么。
特别是简单截断一个无限域 B-spline，并不自动等价于标准齐次 Dirichlet，也不一定等价于标准齐次 Neumann。
---
# 十三、与你当前八叉树代码的直接对应关系
你现在已经有：
* 八叉树基函数；
* 截断基；
* face balance 2:1。
下一步可以按照以下模块实现。
## 13.1 构造向量场 $V$
将每个法向样本 splat 到其附近基函数：
$$
V(x)
= \sum_j v_jB_j(x),
\qquad
v_j\in\mathbb R^3.
$$
样本 $p_s,n_s$ 对附近基函数的贡献可写为
$$
v_j
\mathrel{+}=
w_sB_j(p_s)n_s,
$$
或者使用与你平滑核相匹配的卷积/积分形式。
这里的 $w_s$ 应考虑：
* 局部采样密度；
* 估计面片面积；
* 法向置信度；
* 八叉树层级尺度。
---
## 13.2 组装 Poisson 项
对所有支撑相交的基函数对：
$$
A_{ij}
= \int_\Omega
\nabla B_i\cdot\nabla B_j\,dx.
$$
因为基函数紧支撑，只有支撑重叠时矩阵项非零。
右端项：
$$
b_i
= \int_\Omega
V\cdot\nabla B_i\,dx.
$$
如果 $V$ 也展开在基函数中：
$$
V=\sum_k v_kB_k,
$$
则
$$
b_i
= \sum_k
v_k\cdot
\int_\Omega
B_k\nabla B_i\,dx.
$$
---
## 13.3 加入 screening
遍历每个输入点，只对包含该点的局部基函数组装：
$$
C_{ij}
\mathrel{+}=
\eta_sB_i(p_s)B_j(p_s),
$$
$$
d_i
\mathrel{+}=
\eta_sa_sB_i(p_s).
$$
然后求解：
$$
(A+\lambda C)x=b+\lambda d.
$$
---
## 13.4 处理边界
### 齐次 Dirichlet
保证最终空间满足
$$
B_i|_\Gamma=0.
$$
可以通过：
* 删除越界支撑基；
* 重构边界基；
* 消元固定边界系数。
### Neumann
标准弱形式中 Neumann 是自然条件，不一定需要直接固定边界自由度；但需要确保基函数构造、积分域和边界项与你采用的 Neumann 定义一致。
### 纯 Neumann、无 screening
需要显式处理常数零空间：
$$
\int_\Omega\chi=0,
$$
或固定一个自由度。
---
## 13.5 求解和提取
求得 $x$ 后：
$$
\chi_h(x)=\sum_jx_jB_j(x).
$$
非 screened 可取
$$
\gamma
= \frac{\sum_s\eta_s\chi_h(p_s)}
{\sum_s\eta_s}.
$$
Screened 且目标值为 $0.5$ 时通常取
$$
\gamma=0.5.
$$
最后在叶节点网格上计算角点函数值并执行 Marching Cubes，同时处理不同八叉树深度之间的非一致面，避免裂缝。
---
# 十四、最重要的逻辑链
可以把整个理论压缩为：
$$
\text{有向点云}
$$
$$
\Downarrow
$$
$$
\nabla\chi_M
= n_{\mathrm{in}}\delta_{\partial M}
$$
$$
\Downarrow\quad\text{平滑与离散}
$$
$$
V(x)
= \sum_s w_sF(x-p_s)n_s
$$
$$
\Downarrow
$$
$$
\min_\chi
\int_\Omega
|\nabla\chi-V|^2\,dx
$$
$$
\Downarrow\quad\text{一阶变分}
$$
$$
\int_\Omega
\nabla\chi\cdot\nabla\phi
= \int_\Omega
V\cdot\nabla\phi
$$
$$
\Downarrow\quad\text{Green/Stokes}
$$
$$
\begin{cases}
\Delta\chi=\nabla\cdot V,&\Omega,\\
\partial_n\chi=V\cdot n,&\partial\Omega,
\end{cases}
$$
再加入点约束：
$$
\min_\chi
\int_\Omega|\nabla\chi-V|^2
+
\lambda\sum_s
(\chi(p_s)-a_s)^2,
$$
离散后得到：
$$
\boxed{
(A+\lambda C)x=b+\lambda d.
}
$$
这里：
* Poisson 项恢复与法向一致的全局函数；
* screening 项使表面贴近输入点并固定低频/常数模式；
* 边界条件定义计算域边缘上的延拓方式；
* 八叉树基函数和 2:1 balance 决定有限元空间及稀疏矩阵结构。
最容易混淆的一句话是：
$$
\boxed{
\text{弱形式不是"没有边界条件"，而是边界条件被编码在函数空间和边界项中。}
}
$$
而你看到的唯一离散解 $x$，也不是"Poisson 方程天然唯一"，而是因为边界空间、screening、基函数截断或零空间约束已经替你完成了唯一性限定。
[1]: https://hhoppe.com/poissonrecon.pdf "Poisson surface reconstruction"
[2]: https://www.math.ntnu.no/emner/MA8502/2024h/lectures/html/chapter_01/weak_form_pdes.html "Weak formulation of partial differential equations — MA8502 - Numerical Solutions of Partial Differential Equations"
[3]: https://gfx.cs.princeton.edu/pubs/Kazhdan_2020_PSR/SGP20.pdf "Poisson Surface Reconstruction with Envelope Constraints"
[4]: https://github.com/mkazhdan/PoissonRecon "GitHub - mkazhdan/PoissonRecon: Poisson Surface Reconstruction · GitHub"
[5]: https://www.cs.jhu.edu/~misha/MyPapers/ToG13.pdf "Screened Poisson surface reconstruction"

---

下面给出修复后的完整 Markdown 文本。已将所有行内公式统一为 $...$，所有独立公式块统一为独占一行的 $$...$$；修复了因 ===== 被渲染器误判为标题、因 \ 单反斜杠导致的环境换行失效、以及一些下标和括号损坏等问题，理论与表述保持原样。
对，第一个问题可以直接回答：
$$
\boxed{
\text{如果 Dirichlet 条件已经正确施加，并且 } \Gamma_D \text{ 非空，则通常不需要再加 } x_0=0 \text{ 或 } \sum_i x_i=0。
}
$$
因为 Dirichlet 条件已经把常数零空间去掉了。
一、Dirichlet 情况下为什么不需要再固定 $x_0=0$
Poisson stiffness matrix 是：
$$
A_{ij} = \int_\Omega \nabla B_i\cdot \nabla B_j,dx.
$$
它对应能量：
$$
x^T A x = \int_\Omega
\left|
\nabla \left(
\sum_i x_iB_i
\right)
\right|^2dx.
$$
如果是纯 Neumann / free boundary，常数函数满足：
$$
\nabla c = 0.
$$
所以：
$$
A\mathbf{1}=0.
$$
这就是奇异性的来源。
但是 Dirichlet 条件要求：
$$
\chi|_{\partial\Omega}=0.
$$
如果一个函数同时满足：
$$
\nabla \chi=0
$$
和
$$
\chi|_{\partial\Omega}=0,
$$
那么它只能是：
$$
\chi\equiv 0.
$$
因此零空间消失。
从连续理论讲，这是 Poincaré inequality 的结果：
$$
|\chi|_{L^2(\Omega)}
\le C|\nabla\chi|_{L^2(\Omega)}
\quad
\text{for }
\chi\in H^1_0(\Omega).
$$
也就是说，在 $H^1_0(\Omega)$ 这个 Dirichlet 空间里，梯度范数已经足够控制整个函数。
所以矩阵变成正定：
$$
\boxed{
x^TAx>0
\quad
\forall x\ne 0.
}
$$
1.1 什么时候还可能需要额外约束？
一般不需要，但有几个例外。
情况 A：你实际上没有真正施加 Dirichlet
比如你只是用了“不完整边界基函数”，但没有保证：
$$
\chi|_{\partial\Omega}=0.
$$
那它可能不是严格 Dirichlet，而是某种 hidden boundary treatment。
此时矩阵可能：
仍然奇异；
或者非奇异，但对应的是一个不清楚的隐式边界条件；
或者由于边界截断破坏单位分解，常数零模被数值上“意外去掉”。
第三种最危险：矩阵看起来可解，但 PDE 意义不清楚。
情况 B：只有部分 Dirichlet，且约束区域太弱
如果 Dirichlet 只在很小、退化的边界集合上施加，理论上可能不足以去掉所有零模。
但正常三维计算域中，只要 $\Gamma_D$ 有非零面积，通常就足够。
情况 C：screening 与 Dirichlet 同时存在
系统是：
$$
(A+\lambda C)x=b+\lambda d.
$$
Dirichlet 已经使 $A$ 正定，screening 只是增强数据贴合，不是为了去零空间。
1.2 工程建议
如果你实现的是齐次 Dirichlet：
$$
\chi=0
\quad\text{on }\partial\Omega,
$$
那么推荐做法是：
构造所有自由度；
标记 Dirichlet boundary DOF；
消元或固定这些 DOF；
只在 interior DOF 上求解。
此时不要再额外加：
$$
x_0=0
$$
除非 $x_0$ 本来就是一个边界 DOF，且它的值已经由 Dirichlet 固定。
否则你会多加一个非物理约束，导致解被错误压低或偏移。
二、颜色重建的本质
Poisson 重建的几何部分求的是一个隐式函数：
$$
\chi:\Omega\to\mathbb R.
$$
颜色重建则是求一个属性场：
$$
C:\Omega\to\mathbb R^3,
$$
其中：
$$
C(x)=
\begin{bmatrix}
R(x)\
G(x)\
B(x)
\end{bmatrix}.
$$
最终在提取出来的网格顶点 $v$ 上赋值：
$$
\text{color}(v)=C(v).
$$
所以颜色重建可以理解成：
$$
\boxed{
\text{在同一个八叉树函数空间里，再求一个或多个标量场。}
}
$$
RGB 三个通道只是三个独立的标量场。
三、最常见的颜色场模型：Screened harmonic interpolation
输入有：
$$
(p_s,n_s,c_s),
$$
其中：
$$
c_s\in\mathbb R^3.
$$
希望：
$C(p_s)$ 接近输入颜色 $c_s$；
$C(x)$ 在空间中足够平滑；
最终输出网格上的颜色连续、抗噪。
可以定义能量：
$$
\boxed{
E(C)
= \frac{\alpha}{2}
\int_\Omega
|\nabla C(x)|^2dx
+
\frac{\lambda}{2}
\sum_s
\omega_s
|C(p_s)-c_s|^2.
}
$$
这里：
$\alpha$：平滑强度；
$\lambda$：数据贴合强度；
$\omega_s$：点权重；
$c_s$：输入颜色；
$C$：要恢复的连续颜色场。
因为 RGB 是三维向量，所以：
$$
|\nabla C|^2
|\nabla R|^2
+
|\nabla G|^2
+
|\nabla B|^2.
$$
也就是说，三个通道可以分别求：
$$
E(u)
= \frac{\alpha}{2}
\int_\Omega
|\nabla u|^2dx
+
\frac{\lambda}{2}
\sum_s
\omega_s
(u(p_s)-a_s)^2.
$$
其中 $u$ 是 R/G/B 任意一个通道，$a_s$ 是对应通道值。
3.1 弱形式
取测试函数 $\phi$，一阶变分得到：
$$
\alpha
\int_\Omega
\nabla u\cdot\nabla\phi,dx
+
\lambda
\sum_s
\omega_s
u(p_s)\phi(p_s)
= \lambda
\sum_s
\omega_s
a_s\phi(p_s).
$$
这就是颜色场的 screened Poisson / screened harmonic interpolation。
注意它和几何 screened Poisson 很像，但少了法向产生的右端项：
几何：
$$
\int\nabla\chi\cdot\nabla\phi
+
\lambda\sum_s\chi(p_s)\phi(p_s)
= \int V\cdot\nabla\phi
+
\lambda\sum_sa_s\phi(p_s).
$$
颜色：
$$
\alpha\int\nabla u\cdot\nabla\phi
+
\lambda\sum_su(p_s)\phi(p_s)
= \lambda\sum_sa_s\phi(p_s).
$$
区别是：
$$
\boxed{
\text{几何有 } V,\quad \text{颜色通常没有 } V。
}
$$
颜色只是一个平滑插值问题。
3.2 离散矩阵
设颜色场展开为：
$$
u_h(x)
= \sum_j y_jB_j(x).
$$
代入弱形式，得到：
$$
\boxed{
(\alpha A+\lambda C)y
= \lambda d.
}
$$
其中：
$$
A_{ij}
= \int_\Omega
\nabla B_i\cdot\nabla B_j,dx,
$$
$$
C_{ij}
= \sum_s
\omega_sB_i(p_s)B_j(p_s),
$$
$$
d_i
= \sum_s
\omega_sa_sB_i(p_s).
$$
对于 RGB，矩阵相同，只是右端不同：
$$
(\alpha A+\lambda C)y^R=\lambda d^R,
$$
$$
(\alpha A+\lambda C)y^G=\lambda d^G,
$$
$$
(\alpha A+\lambda C)y^B=\lambda d^B.
$$
所以工程上可以：
组装一次矩阵；
分解或预条件一次；
解三个 RHS。
四、颜色场的另一种更简单方法：normalized splatting
如果你不想解一个 PDE，也可以直接用八叉树基函数做核回归。
定义密度场：
$$
\rho(x)
= \sum_s
\omega_sK_s(x-p_s),
$$
定义颜色累积场：
$$
Q(x)
= \sum_s
\omega_sc_sK_s(x-p_s).
$$
那么颜色为：
$$
\boxed{
C(x)
= \frac{Q(x)}{\rho(x)+\varepsilon}.
}
$$
这叫 normalized convolution / normalized splatting。
如果使用同一套基函数 $B_j$，可以写成：
$$
\rho_j
\mathrel{+}=
\omega_sB_j(p_s),
$$
$$
q_j
\mathrel{+}=
\omega_sc_sB_j(p_s).
$$
然后：
$$
\rho(x)=\sum_j\rho_jB_j(x),
$$
$$
Q(x)=\sum_jq_jB_j(x),
$$
$$
C(x)=\frac{Q(x)}{\rho(x)+\varepsilon}.
$$
这种方法非常便宜：
不需要解线性系统；
局部性强；
和密度估计天然一致。
缺点是：
平滑性不如 PDE 解；
点稀疏处不稳定；
颜色噪声会直接反映到结果上。
五、颜色重建中最容易忽略的问题：颜色在表面上，不在体积里
颜色本质上是定义在表面上的属性：
$$
c:S\to\mathbb R^3.
$$
但上面的方法把它扩展成了体函数：
$$
C:\Omega\to\mathbb R^3.
$$
这会带来一个问题：
如果模型有两片非常接近但颜色不同的表面，三维体积平滑会把两边颜色混在一起。
例如：
衣服两层布料；
近距离平行薄片；
物体内外两侧；
手指之间的缝隙。
因为体积 Laplacian 平滑的是三维空间距离，而不是表面测地距离。
5.1 更稳妥的做法：表面颜色重建
先重建几何，得到网格 $S_h$，再在网格上求颜色：
$$
u:S_h\to\mathbb R.
$$
定义能量：
$$
E_S(u)
= \frac{\alpha}{2}
\int_{S_h}
|\nabla_Su|^2dA
+
\frac{\lambda}{2}
\sum_s
\omega_s
(u(\pi(p_s))-a_s)^2.
$$
其中：
$\nabla_S$：表面梯度；
$\pi(p_s)$：点 $p_s$ 投影到重建表面；
$u$：网格顶点上的颜色通道。
离散后是网格 Laplacian 系统：
$$
(\alpha L+\lambda C_S)y=\lambda d_S.
$$
这种方法：
更适合最终 vertex color；
不容易跨薄结构串色；
可以沿表面平滑，而不是穿过体积平滑。
缺点是需要先有网格，再做属性重建。
六、颜色重建的三种实用路线
路线 A：体积 screened interpolation
适合：
你已经有八叉树 FEM 框架；
想和 PoissonRecon 风格一致；
输入颜色噪声较大；
不追求非常锐利的纹理边界。
系统：
$$
(\alpha A+\lambda C)y=\lambda d.
$$
路线 B：density-normalized splatting
适合：
想快速实现；
点云颜色比较干净；
不想额外解线性系统。
公式：
$$
C(x)=\frac{\sum_s\omega_sc_sK_s(x-p_s)}
{\sum_s\omega_sK_s(x-p_s)+\varepsilon}.
$$
路线 C：重建后在 mesh 上做颜色优化
适合：
薄结构；
颜色边界明显；
高质量 vertex color；
后续要做 texture atlas。
系统：
$$
(\alpha L+\lambda C_S)y=\lambda d_S.
$$
七、density field 到底是什么
Poisson reconstruction 里经常说的 density 其实不是单一概念，至少有三种：
7.1 采样密度 sampling density
这是点云在表面上的点密度：
$$
\rho_{\text{sample}}(p)
\approx
\frac{#{p_s\text{ near }p}}{\text{local surface area}}.
$$
它用于估计每个点代表的面积：
$$
a_s
\approx
\frac{1}{\rho_{\text{sample}}(p_s)}.
$$
在构造法向向量场时，合理的离散近似应该是：
$$
\int_S F(x-p)n(p)dA
\approx
\sum_s
a_sF(x-p_s)n_s.
$$
所以几何向量场应更像：
$$
\boxed{
V(x)
= \sum_s
a_s n_s K_s(x-p_s).
}
$$
其中 $a_s$ 是面积权重。
这个权重非常重要，因为如果某个区域采样特别密，直接相加会让该区域在 Poisson 方程里被过度强调。
7.2 支持密度 / confidence density
这是 SurfaceTrimmer 常用的 density。
它表示：
输出表面某个位置附近有多少输入点支持。
定义可以是：
$$
\rho_{\text{conf}}(x)
= \sum_s
q_sK_s(x-p_s),
$$
其中：
$q_s$：点置信度；
$K_s$：局部核函数；
$x$：空间位置或输出网格顶点位置。
这个密度越高，表示重建表面越可信。
它和 $a_s$ 的关系要注意：
构造 $V$ 时常用 $a_s\approx1/\rho_{\text{sample}}$；
trimming 时常用 $\rho_{\text{conf}}$ 本身。
一个是“面积补偿”，一个是“置信度判断”。
不要把它们混成同一个量。
7.3 screening 权重
Screened Poisson 中的数据项：
$$
\lambda\sum_s\eta_s(\chi(p_s)-a_s)^2.
$$
这里的 $\eta_s$ 也是一种权重。
它可以来自：
采样面积；
法向置信度；
点云质量；
局部密度；
扫描视角；
深度相机置信度。
所以你会看到 density 同时出现在：
法向场构造；
screening；
颜色重建；
trimming；
八叉树 refinement。
但它们的语义不完全一样。
八、八叉树上的 density field 怎么构造
设你有八叉树基函数：
$$
{B_j}.
$$
对于每个输入点 $p_s$，找到所有支撑包含 $p_s$ 的基函数：
$$
\mathcal N(p_s)
= {j:B_j(p_s)\ne0}.
$$
然后累积：
$$
D_j
\mathrel{+}=
q_sB_j(p_s).
$$
最终定义：
$$
\boxed{
D(x)=\sum_jD_jB_j(x).
}
$$
这就是一个八叉树上的平滑 density field。
8.1 如果要 normalized density
有时候还会同时累积权重：
$$
W_j
\mathrel{+}=
B_j(p_s).
$$
然后定义：
$$
D_j
= \frac{\sum_s q_sB_j(p_s)}
{\sum_s B_j(p_s)+\varepsilon}.
$$
但用于 SurfaceTrimmer 时，通常更希望 density 反映“有多少点支持”，因此不一定要归一化到平均值。
8.2 多分辨率 density
八叉树上常见做法不是只在一个分辨率上 splat，而是在与点所在深度相关的尺度上 splat。
如果点 $p_s$ 位于深度 $d_s$，对应 cell size 为：
$$
h_s=2^{-d_s}.
$$
可以使用尺度相关核：
$$
K_s(x)=h_s^{-2}K\left(\frac{x-p_s}{h_s}\right)
$$
如果你估计的是表面采样密度，尺度归一化更接近 $h_s^{-2}$，因为点分布在二维表面上，而不是三维体积里。
如果你只是需要一个相对 confidence，那么常数因子可以省略，只要阈值和它一致即可。
九、density 如何参与 adaptive octree refinement
常见策略是：
$$
\text{refine cell } c
\quad\text{if}\quad
N(c)>\tau_N
$$
或者：
$$
D(c)>\tau_D.
$$
也就是说：
点多的地方细分；
点少的地方保持粗；
法向变化大的地方额外细分；
曲率大的地方额外细分。
更合理的 refinement criterion 可以写成：
$$
\text{refine}(c)
\big[
N(c)>\tau_N
\big]
\lor
\big[
\text{normal variation}(c)>\tau_n
\big]
\lor
\big[
\text{screening residual}(c)>\tau_r
\big].
$$
其中 normal variation 可以用：
$$
1-\left|
\frac{\sum_{p_s\in c}n_s}
{\sum_{p_s\in c}1}
\right|.
$$
如果一个 cell 里的法向高度一致，这个值接近 0；如果法向变化很大，它会变大。
十、SurfaceTrimmer 的本质
Poisson reconstruction 通常会得到一个封闭等值面：
$$
S_h={x:\chi_h(x)=\gamma}.
$$
但它有一个天然问题：
Poisson 方程会在缺失数据区域自动补洞和外推。
这些补出来的部分有时是你想要的，比如扫描小洞；有时是不想要的，比如点云只覆盖半个物体，但 Poisson 强行给你封闭一大片虚假表面。
SurfaceTrimmer 的作用就是：
$$
\boxed{
\text{根据 density field 删除低置信度区域。}
}
$$
最终保留的不是：
$$
\chi_h(x)=\gamma
$$
的全部等值面，而是：
$$
\boxed{
\chi_h(x)=\gamma
\quad\text{and}\quad
D(x)\ge \tau.
}
$$
十一、SurfaceTrimmer 的输入通常是什么
SurfaceTrimmer 不一定直接读八叉树。通常它拿到的是已经提取出的 mesh：
$$
M=(V,F).
$$
每个顶点有一个 scalar density：
$$
d_i=D(v_i).
$$
也就是说，PoissonRecon 输出 mesh 时，不只输出：
position；
normal；
color；
还可以输出：
density/confidence value。
SurfaceTrimmer 就用这个 per-vertex scalar 做裁剪。
十二、SurfaceTrimmer 的三角形裁剪算法
给定阈值：
$$
\tau.
$$
对每个 mesh 顶点：
$$
s_i=d_i-\tau.
$$
如果：
$$
s_i\ge0
$$
说明顶点可信。
如果：
$$
s_i<0
$$
说明顶点低密度。
12.1 一个三角形的分类
三角形有三个顶点：
$$
v_0,v_1,v_2.
$$
对应密度：
$$
d_0,d_1,d_2.
$$
情况 1：三个都高密度
$$
d_0,d_1,d_2\ge\tau.
$$
保留整个三角形。
情况 2：三个都低密度
$$
d_0,d_1,d_2<\tau.
$$
删除整个三角形。
情况 3：一个高密度，两个低密度
保留一个小三角形。
假设：
$$
d_0\ge\tau,\quad d_1<\tau,\quad d_2<\tau.
$$
在边 $(v_0,v_1)$ 上求交点：
$$
t_{01}
= \frac{\tau-d_0}{d_1-d_0}.
$$
$$
q_{01}
= (1-t_{01})v_0+t_{01}v_1.
$$
在边 $(v_0,v_2)$ 上：
$$
t_{02}
= \frac{\tau-d_0}{d_2-d_0}.
$$
$$
q_{02}
= (1-t_{02})v_0+t_{02}v_2.
$$
保留三角形：
$$
(v_0,q_{01},q_{02}).
$$
情况 4：两个高密度，一个低密度
保留一个四边形，通常拆成两个三角形。
假设：
$$
d_0,d_1\ge\tau,\quad d_2<\tau.
$$
边 $(v_0,v_2)$ 交点：
$$
q_{02}
= (1-t_{02})v_0+t_{02}v_2.
$$
边 $(v_1,v_2)$ 交点：
$$
q_{12}
= (1-t_{12})v_1+t_{12}v_2.
$$
保留四边形：
$$
(v_0,v_1,q_{12},q_{02}).
$$
再拆成：
$$
(v_0,v_1,q_{12})
$$
和
$$
(v_0,q_{12},q_{02}).
$$
12.2 其他属性也一起插值
如果顶点有：
normal；
color；
density；
texture coordinate；
confidence；
$\chi$ value；
那么新交点属性也用同样的 $t$ 插值：
$$
a_q
= (1-t)a_i+ta_j.
$$
normal 插值后需要 normalize：
$$
n_q
= \frac{(1-t)n_i+tn_j}
{|(1-t)n_i+tn_j|}.
$$
十三、SurfaceTrimmer 本质上不是重新 Poisson 求解
这一点很重要。
SurfaceTrimmer 通常不是重新求：
$$
\chi
$$
也不是重新解 PDE。
它是在已经提取的网格上做：
$$
D(v)\ge\tau
$$
的 clipping。
所以它会把原本 watertight 的 Poisson 网格裁成 open surface。
这就是为什么 SurfaceTrimmer 常用于：
删除低置信度补洞区域；
从封闭 Poisson 结果中恢复开放扫描表面；
移除 extrapolated caps；
保留真实扫描覆盖区域。
十四、density 阈值怎么选
假设 density 值为 $D(v)$。
常见方法：
方法 1：手动阈值
选择：
$$
\tau = 5,\ 6,\ 7,\ldots
$$
这种常见于 depth-like density。
方法 2：按分位数
例如保留 density 最高的 90% 区域：
$$
\tau=\operatorname{percentile}(D,10%).
$$
方法 3：根据直方图 valley
如果 density 分布有两个峰：
高峰：真实扫描区域；
低峰：Poisson 补洞区域；
可以在两个峰之间取 valley 作为阈值。
方法 4：连通域过滤
先用较低阈值裁剪，然后：
删除小连通分量；
删除面积过小的三角形区域；
保留最大连通块。
十五、density 与 color 的统一离散框架
你可以把所有东西都写成同一个八叉树 FEM 框架：
15.1 几何隐式函数
$$
\chi_h(x)=\sum_jx_jB_j(x).
$$
解：
$$
(A+\lambda C)x=b+\lambda d.
$$
15.2 density field
$$
D_h(x)=\sum_j\rho_jB_j(x).
$$
累积：
$$
\rho_j
\mathrel{+}=
q_sB_j(p_s).
$$
通常不需要解 PDE。
15.3 color numerator field
$$
Q_h(x)=\sum_jq_jB_j(x),
$$
$$
q_j
\mathrel{+}=
q_sc_sB_j(p_s).
$$
然后：
$$
C_h(x)=\frac{Q_h(x)}{D_h(x)+\varepsilon}.
$$
这是 splatting 版本。
15.4 color PDE version
也可以解：
$$
(\alpha A+\lambda C)y=\lambda d.
$$
其中：
$$
C_{ij}
= \sum_s
\omega_sB_i(p_s)B_j(p_s),
$$
$$
d_i
= \sum_s
\omega_sa_sB_i(p_s).
$$
十六、你写代码时可以这样组织
Step 1：建树
根据点云位置、法向变化、密度建 adaptive octree。
Step 2：构造 basis
每个 octree node / grid node 对应一个基函数 $B_j$。
处理：
truncation；
2:1 balance；
boundary type；
support overlap。
Step 3：估计 sampling density
对每个点：
$$
\rho_s
= \sum_{t\in N(s)}
K\left(
\frac{|p_s-p_t|}{h_s}
\right).
$$
面积权重：
$$
a_s=\frac{1}{\rho_s+\varepsilon}.
$$
Step 4：构造几何向量场
$$
V(x)
= \sum_s
a_sn_sK_s(x-p_s).
$$
离散右端：
$$
b_i
= \int_\Omega V\cdot\nabla B_i,dx.
$$
实际可以直接 splat：
$$
b_i
\mathrel{+}=
a_s n_s\cdot \nabla B_i(p_s)
$$
或者用更精确的 cell quadrature：
$$
b_i
= \sum_{\text{cells }c}
\int_c
V\cdot\nabla B_i,dx.
$$
Step 5：screening
$$
C_{ij}
\mathrel{+}=
\eta_sB_i(p_s)B_j(p_s),
$$
$$
d_i
\mathrel{+}=
\eta_sa_s^{\chi}B_i(p_s).
$$
如果目标等值为 0.5：
$$
a_s^\chi=0.5.
$$
Step 6：求解几何
$$
(A+\lambda C)x=b+\lambda d.
$$
Step 7：构造 density field
$$
D_j
\mathrel{+}=
q_sB_j(p_s).
$$
输出网格顶点 $v$ 的密度：
$$
D(v)=\sum_jD_jB_j(v).
$$
Step 8：颜色
简单版：
$$
Q_j
\mathrel{+}=
q_sc_sB_j(p_s),
$$
$$
C(v)=
\frac{\sum_jQ_jB_j(v)}
{\sum_jD_jB_j(v)+\varepsilon}.
$$
高质量版：
$$
(\alpha A+\lambda C)y^R=\lambda d^R,
$$
$$
(\alpha A+\lambda C)y^G=\lambda d^G,
$$
$$
(\alpha A+\lambda C)y^B=\lambda d^B.
$$
Step 9：提取等值面
$$
\chi_h(x)=\gamma.
$$
对每个 MC vertex $v$，同时评估：
$$
D(v),\quad C(v),\quad \nabla\chi(v).
$$
Step 10：Surface trimming
保留：
$$
D(v)\ge\tau
$$
的区域。
对跨阈值三角形做线性裁剪。
十七、一个关键实现建议
如果你的目标是尽快做出稳定版本，我建议顺序是：
先实现 geometry screened Poisson；
再实现 density splatting；
用 density 做 SurfaceTrimmer；
最后实现颜色 normalized splatting；
如果颜色噪声明显，再上颜色 PDE solve。
也就是说，不建议一开始就把颜色也做成 PDE，因为 geometry 和 trimming 更核心。
十八、最重要的总结
Dirichlet：
$$
\boxed{
\chi|_{\partial\Omega}=0
\Rightarrow
A\text{ 通常正定，不需要 }x_0=0.
}
$$
颜色：
$$
\boxed{
\text{颜色重建可以看作属性场的 screened interpolation。}
}
$$
density：
$$
\boxed{
\text{density 是点云对重建表面的支持度，不是 Poisson 隐式函数本身。}
}
$$
SurfaceTrimmer：
$$
\boxed{
\text{不是重新解 PDE，而是在已提取网格上根据 density 裁剪低置信区域。}
}
$$
你现在可以把整个 PoissonRecon 扩展理解成：
$$
\text{geometry field}
+
\text{density field}
+
\text{attribute field}
+
\text{confidence-based extraction}.
$$
