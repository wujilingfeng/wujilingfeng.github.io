+++
author = 'libo'
date = '2026-04-12T10:50:58+08:00'
math= true
draft = false
title = '泊松重建'
+++



下面给出一个尽量“数学化、简洁、按理论—算法分层”的说明。范围限定：只讲泊松重建/Screened Poisson 重建的连续模型、离散有限元/样条基表示、自适应八叉树上的方程构造与求解；不讲隐函数如何再经 marching cubes 提取三角网格。

目录


问题设定与基本思想

经典泊松重建的连续理论
2.1 指示函数与法向场
2.2 变分形式与泊松方程
2.3 边界条件的意义


Screened Poisson 的连续理论
3.1 screened 项的由来
3.2 连续能量泛函
3.3 与经典泊松模型的差异


自适应八叉树上的离散化
4.1 八叉树函数空间
4.2 基函数如何定义
4.3 不同分辨率节点的支撑半径与影响范围
4.4 相邻节点积分内积如何写
4.5 右端项如何由点云法向构造


你的疑问 1：自适应八叉树中基函数、半径、积分内积的本质
5.1 基函数不是“拍脑袋选半径”，而是由层级有限元空间决定
5.2 不同尺度节点如何兼容
5.3 内积矩阵为何仍然稀疏


你的疑问 2：点云权重如何影响重建
6.1 在经典泊松中的影响
6.2 在 screened poisson 中的影响
6.3 权重对几何效果的具体作用


你的疑问 3：Neumann 与 Dirichlet 边界条件在新版 screened poisson 中的作用
7.1 它们不是“仅在无基函数区域给初值”
7.2 它们改变的是算子定义、零空间与解的全局行为
7.3 两类边界条件在重建中的几何后果


从理论到算法：完整流程
8.1 输入与预处理
8.2 八叉树构建
8.3 法向 splat 到层级网格
8.4 装配线性系统
8.5 多重网格/层级求解


公式级总结



1. 问题设定与基本思想
   输入为带法向的点云
   $\mathcal P=\{(p_i,n_i)\}_{i=1}^N,\qquad p_i\in\mathbb R^3,\ n_i\in\mathbb R^3.$
   通常假设 $n_i$ 近似指向物体外侧，且已定向。
   目标不是直接拟合参数曲面，而是求一个标量函数
   $\chi:\Omega\subset\mathbb R^3\to\mathbb R,$
   使其等值面 $\chi=c$ 逼近目标曲面。经典泊松重建中，$\chi$ 被解释为指示函数（indicator function）或其平滑近似：物体内部约为 1，外部约为 0，界面附近有跳变。
   核心思想：


曲面的法向信息可看作指示函数梯度的分布式信息；


由点法向先构造一个向量场 $V(x)$；


再求解
$\nabla \chi \approx V$
的最小二乘问题；


Euler–Lagrange 方程即泊松型椭圆方程。



2. 经典泊松重建的连续理论
   2.1 指示函数与法向场
   设 $M\subset \Omega$ 是闭合曲面，$I_M(x)$ 是其内部区域的指示函数：
   $I_M(x)=
   \begin{cases}
   1,& x\in \text{inside}(M),\\
   0,& x\in \text{outside}(M).
   \end{cases}$
   严格地说，$I_M$ 不可微；其梯度是支撑在曲面上的向量值分布。形式上有
   $\nabla I_M = -\,\mathbf n\,\delta_M,$
   其中 $\mathbf n$ 为外法向，$\delta_M$ 为曲面 Dirac 测度。
   点云给出的是对该分布的离散采样。因此可构造平滑后的向量场 $V$，使
   $V \approx \nabla \chi.$
   2.2 变分形式与泊松方程
   经典泊松重建最小化能量
   $E(\chi)=\int_\Omega \|\nabla \chi(x)-V(x)\|^2\,dx.$
   对任意测试函数 $\phi$ 求变分，得
   $\delta E(\chi)[\phi]
   =2\int_\Omega \langle \nabla \chi -V,\nabla \phi\rangle\,dx.$
   令其对任意 $\phi$ 为零，则弱形式为
   $\int_\Omega \langle \nabla \chi,\nabla \phi\rangle\,dx
   =
   \int_\Omega \langle V,\nabla \phi\rangle\,dx.$
   对右端分部积分可得强形式
   $\Delta \chi = \nabla\cdot V$
   （符号约定不同可能写成 $-\Delta\chi=-\nabla\cdot V$，本质一致）。
   因此泊松重建本质上是：
   由法向估计散度，再解一个椭圆方程恢复标量场。
   2.3 边界条件的意义
   泊松方程若只给
   $\Delta\chi=\nabla\cdot V$
   则必须配合边界条件才是完备问题。
   Neumann 边界
   $\frac{\partial \chi}{\partial n}=0 \quad \text{on }\partial\Omega.$
   表示边界法向方向上没有通量变化。此时常数函数属于 Laplace 算子的零空间，因此解只确定到一个常数：
   $\chi \sim \chi + c.$
   在重建中意味着：绝对函数值不定，只能从相对变化恢复形状。
   Dirichlet 边界
   $\chi=g \quad \text{on }\partial\Omega.$
   例如取 $g=0$。此时解唯一。它将外边界“钉住”为某个固定值，从而影响全局偏置。

3. Screened Poisson 的连续理论
   3.1 screened 项的由来
   经典泊松只拟合梯度
   $\nabla\chi \approx V.$
   它对低频偏置控制弱，且在稀疏、不均匀采样时会产生过度平滑、偏移。Screened Poisson 额外加入“函数值约束”，使 $\chi$ 在采样点附近也尽量接近某些目标值。
   设对每个采样点 $p_i$，有一个目标值 $f_i$（例如由局部内外判断、等值面约束、或将目标等值面设定在某常数附近）。则考虑
   $E(\chi)=\int_\Omega \|\nabla\chi -V\|^2\,dx
   +\lambda \sum_i w_i\,(\chi(p_i)-f_i)^2.$
   这就是“screening”：在梯度约束之外加入点值约束。
   3.2 连续能量泛函
   更一般地可写成
   $E(\chi)=\int_\Omega \|\nabla\chi -V\|^2\,dx
   +\lambda \int_\Omega \sigma(x)\,(\chi(x)-\chi_0(x))^2\,dx,$
   其中 $\sigma$ 是采样诱导的权函数，$\chi_0$ 是目标场。
   其 Euler–Lagrange 方程为
   $-\Delta\chi + \lambda \sigma(x)\chi
   =
   -\nabla\cdot V + \lambda \sigma(x)\chi_0(x).$
   这就是 screened Poisson 方程。离散点情形可视为 $\sigma$ 是若干局部核函数或离散测度的组合。
   3.3 与经典泊松模型的差异
   经典泊松：
   $-\Delta \chi = -\nabla\cdot V.$
   screened 泊松：
   $(-\Delta + \lambda \sigma)\chi = -\nabla\cdot V + \lambda \sigma \chi_0.$
   差别：


多了零阶项 $\lambda \sigma \chi$；


使系统从“纯梯度控制”变为“梯度 + 点值控制”；


在 Neumann 条件下，screening 往往也能削弱常数零空间问题，因为零阶项会固定整体偏置（若 $\sigma\not\equiv 0$）。



4. 自适应八叉树上的离散化
   下面进入核心：如何在不同分辨率八叉树上定义基函数与方程系数。
   4.1 八叉树函数空间
   设 $\mathcal T$ 为包围盒 $\Omega$ 上的自适应八叉树。每个节点 $o\in\mathcal T$ 对应一个立方体单元，边长记为
   $h_o.$
   离散未知量不是“每个体素一个常数”，而通常是某个层级样条/有限元空间中的系数。设基函数族为
   $\{B_\alpha(x)\}_{\alpha\in \mathcal I},$
   则
   $\chi_h(x)=\sum_{\alpha\in\mathcal I} x_\alpha B_\alpha(x).$
   在 Kazhdan 系列算法中，常用的是tensor-product B-spline / 分片多项式基，定义在八叉树诱导的层级网格上。关键不是“节点中心放一个高斯球”，而是层级有限元基函数。
   4.2 基函数如何定义
   最常见理解方式：
   在每个轴上取一维 B-spline 基 $b(t)$，三维基函数为张量积
   $B_\alpha(x,y,z)=b_{\alpha_x}(x)\,b_{\alpha_y}(y)\,b_{\alpha_z}(z).$
   若在均匀网格层级 $\ell$ 上，则尺度为
   $h_\ell = 2^{-\ell} h_0.$
   相应一维基可写为缩放平移形式
   $b_{\ell,k}(x)=b\!\left(\frac{x-kh_\ell}{h_\ell}\right),$
   故其支撑长度与 $h_\ell$ 成正比。三维时
   $B_{\ell,\mathbf k}(x)=
   b_{\ell,k_x}(x_1)\,b_{\ell,k_y}(x_2)\,b_{\ell,k_z}(x_3).$
   在自适应八叉树中
   不是所有层级所有基都保留，而是只保留与自适应树兼容的那部分自由度。通常要求树满足 2:1 balance 或类似层级一致性约束，使相邻单元层级差不大，从而基函数之间的耦合保持局部且可控。
   因此：


基函数的“半径”不是单独指定的参数；


它由该基所在层级 $\ell$ 的网格尺度 $h_\ell$ 与基函数模板 $b$ 的支撑宽度共同决定；


例如若一维 $b$ 支撑在区间长度 $m h_\ell$ 上，则三维支撑盒尺度就是 $O(m h_\ell)$。


4.3 不同分辨率节点的支撑半径与影响范围
若基函数定义在层级 $\ell$，则其影响范围（support）满足
$\operatorname{diam}(\operatorname{supp} B_{\ell,\mathbf k}) \asymp h_\ell.$
更精确地，若一维模板 $b$ 支撑宽度是 $s$ 个网格间隔，则
$\operatorname{supp}(B_{\ell,\mathbf k})
\subset
[k_x h_\ell,(k_x+s)h_\ell]\times[k_y h_\ell,(k_y+s)h_\ell]\times[k_z h_\ell,(k_z+s)h_\ell].$
因此：


粗层基函数支撑大，表示低频/全局成分；


细层基函数支撑小，表示高频/局部细节；


自适应树中并不需要人为给每个节点单独调半径，半径 = 层级尺度 $\times$ 固定模板宽度。


4.4 相邻节点积分内积如何写
把弱形式
$\int_\Omega \langle \nabla \chi_h,\nabla \phi_h\rangle\,dx
=
\int_\Omega \langle V,\nabla \phi_h\rangle\,dx$
代入
$\chi_h=\sum_\alpha x_\alpha B_\alpha,\qquad \phi_h=B_\beta,$
得线性系统
$\sum_\alpha
\underbrace{\int_\Omega \nabla B_\alpha\cdot \nabla B_\beta\,dx}_{A_{\beta\alpha}}
x_\alpha
=
\underbrace{\int_\Omega V\cdot \nabla B_\beta\,dx}_{b_\beta}.$
所以矩阵元素是
$A_{\alpha\beta}
=
\int_\Omega \nabla B_\alpha(x)\cdot \nabla B_\beta(x)\,dx.$
关键点 1：只有支撑相交时才非零
若
$\operatorname{supp}(B_\alpha)\cap \operatorname{supp}(B_\beta)=\emptyset,$
则
$A_{\alpha\beta}=0.$
因此矩阵稀疏。
关键点 2：不同层级之间照样按同一公式积分
设 $B_\alpha$ 在粗层 $\ell$，$B_\beta$ 在细层 $m$，则
$A_{\alpha\beta}=\int_{\operatorname{supp} B_\alpha\cap \operatorname{supp} B_\beta}
\nabla B_\alpha\cdot\nabla B_\beta\,dx.$
不存在“相邻不同分辨率节点要另写一种公式”；公式相同，只是两个函数尺度不同。
因为 B-spline 是张量积，所以
$\nabla B_\alpha\cdot\nabla B_\beta
=
(\partial_x B_\alpha)(\partial_x B_\beta)
+(\partial_y B_\alpha)(\partial_y B_\beta)
+(\partial_z B_\alpha)(\partial_z B_\beta).$
每一项都分解为一维积分乘积。例如
$\int_\Omega (\partial_x B_\alpha)(\partial_x B_\beta)\,dx
=
\left(\int b'_{\alpha_x}(x)b'_{\beta_x}(x)\,dx\right)
\left(\int b_{\alpha_y}(y)b_{\beta_y}(y)\,dy\right)
\left(\int b_{\alpha_z}(z)b_{\beta_z}(z)\,dz\right).$
其余两项同理。
关键点 3：尺度律
若 $B_\ell(x)=b(x/h_\ell)$ 型，则
$\nabla B_\ell = O(h_\ell^{-1}),
\qquad
dx = O(h_\ell^3)$
（严格地说对同尺度函数如此；异尺度时由交叠区域的细尺度主导）。所以
$A_{\alpha\beta}$
的量级可从“导数尺度 × 重叠体积”估计。这解释了为何粗细层耦合是局部且量级稳定的。
4.5 右端项如何由点云法向构造
给定离散点法向 $(p_i,n_i)$，可把向量场写成核和形式
$V(x)=\sum_i w_i\,n_i\,K_i(x),$
其中 $K_i$ 是 splat 核，局部支撑，常取与当前八叉树尺度适配的 B-spline/box/平滑核。
则
$b_\beta = \int_\Omega V\cdot\nabla B_\beta\,dx
=
\sum_i w_i \int_\Omega K_i(x)\, n_i\cdot\nabla B_\beta(x)\,dx.$
若 $K_i$ 近似 Dirac，则形式上
$b_\beta \approx \sum_i w_i\, n_i\cdot \nabla B_\beta(p_i).$
实际实现中常把点法向先散射到八叉树节点/单元上，得到分层向量场系数，再与基函数梯度做局部内积。

5. 你的疑问 1：自适应八叉树中基函数、半径、积分内积的本质
   5.1 基函数不是“拍脑袋选半径”，而是由层级有限元空间决定
   你问：“八叉树不同分辨率，基函数半径和影响范围不同，如何确定每个八叉树节点的基函数？”
   严格回答：


先选定一个母基函数 $b$（如一维 B-spline）；


通过缩放和平移得到各层级基：
$b_{\ell,k}(x)=b\!\left(\frac{x-kh_\ell}{h_\ell}\right);$


三维用张量积；


自适应八叉树只是选择保留哪些层级位置的基函数，并通过平衡条件保证空间相容。


因此，每个节点的基函数由“层级 + 平移位置 + 母基模板”唯一决定。
“半径”就是支撑集直径，自动与 $h_\ell$ 成比例。
5.2 不同尺度节点如何兼容
若直接把不同层级基混在一起，容易线性相关或不稳定。所以实际会采用层级样条/截断样条/受限自由度，只保留一组相容基。核心原则：


粗层覆盖全局；


细层只在需要细节区域激活；


细层在局部修正粗层，而不是完全独立复制粗层功能。


所以自适应并非“每个八叉树单元独立放一个基函数”这么简单，而是一个层级嵌套函数空间
$V_0\subset V_1\subset \cdots \subset V_L.$
自适应空间是其中若干局部子空间的组合。
5.3 内积矩阵为何仍然稀疏
虽然有粗细耦合，但只要基函数局部支撑，矩阵依旧稀疏：
$A_{\alpha\beta}\neq 0
\iff
\operatorname{supp}(B_\alpha)\cap \operatorname{supp}(B_\beta)\neq\emptyset.$
由于 2:1 balance，相邻层级差受限，因此每个基函数只与有限个邻近基耦合，非零数与自由度数近似线性相关。

6. 你的疑问 2：点云权重如何影响重建
   权重可以出现在两个层面。
   6.1 在经典泊松中的影响
   若向量场由
   $V(x)=\sum_i w_i\,n_i\,K_i(x)$
   构造，则权重 $w_i$ 直接改变右端
   $b_\beta = \int V\cdot\nabla B_\beta.$
   因此权重大意味着该点对局部散度/梯度约束贡献更强。
   物理理解
   泊松重建本质拟合
   $\nabla\chi \approx V.$
   所以 $w_i$ 大，相当于要求在 $p_i$ 附近更强地满足“梯度沿 $n_i$ 方向变化”。
   几何效果


高权重点更能“拉动”隐函数；


稠密区域若不归一化，会对解产生偏置；


法向噪声大的点若权重过大，会引入伪结构；


低权重点对应局部表面更容易被周围点“覆盖”或抹平。


6.2 在 screened poisson 中的影响
screened 模型通常既有法向权重，也有点值权重。可写成
$E(\chi)=
\int \|\nabla\chi-V\|^2dx
+
\lambda\sum_i \mu_i(\chi(p_i)-f_i)^2.$
其中：


$w_i$ 控制法向场构造；


$\mu_i$ 控制点值约束强度。


离散后矩阵变为
$(A+\lambda S)x = b+\lambda t,$
其中
$S_{\alpha\beta}=\sum_i \mu_i B_\alpha(p_i)B_\beta(p_i),\qquad
t_\beta=\sum_i \mu_i f_i B_\beta(p_i).$
因此 screened 场景下权重有两种影响：


通过 $b$ 影响梯度拟合；


通过 $S,t$ 影响函数值锚定。


6.3 权重对几何效果的具体作用
(a) 采样密度补偿
若某区域采样极密，直接累加会导致该区域约束过强。常设
$w_i \propto \frac{1}{\rho_i},$
其中 $\rho_i$ 是局部密度估计。这样可以近似把离散和变成连续积分的数值求积，避免“谁点多谁说了算”。
(b) 置信度建模
若点 $p_i$ 的法向可信度低，则取较小 $w_i$。这会减小噪声法向对局部拓扑的干扰。
(c) 尖锐细节与平滑的平衡
高权重会加强局部拟合，但若法向本身噪声大，则会造成振荡；低权重则更平滑、更偏全局平均。
(d) 拓扑闭合趋势
经典泊松有天然的全局平滑和闭合倾向。若某些边缘/薄片区域权重不足，则它们更容易被全局场“填平”或闭合掉。提高这些区域权重可在一定程度上保留结构，但不能完全消除泊松闭合偏置。

7. 你的疑问 3：Neumann 与 Dirichlet 边界条件在新版 screened poisson 中的作用
   你提到：“似乎只是在默认没有基函数作用的区间提供不同的初始值。”
   这不准确。边界条件不是“初始值填充规则”，而是PDE 闭合条件，它改变问题的函数空间、解的唯一性、零空间和全局形状偏置。
   7.1 它们不是“仅在无基函数区域给初值”
   在弱形式中，边界条件体现在允许的测试空间与边界项处理中。
   对 Neumann
   变分仍在 $H^1(\Omega)$ 上进行：
   $\int_\Omega \nabla\chi\cdot\nabla\phi\,dx
   =
   \int_\Omega V\cdot\nabla\phi\,dx,
   \quad \forall \phi\in H^1(\Omega).$
   解只差一个常数。
   对 Dirichlet
   若 $\chi=g$ on $\partial\Omega$，则测试函数需满足
   $\phi|_{\partial\Omega}=0.$
   这不是“初始化”；而是把 admissible space 改成了带边界约束的子空间。
   7.2 它们改变的是算子定义、零空间与解的全局行为
   Neumann 情况
   Laplace 算子存在零空间
   $\ker(-\Delta)=\{\text{constants}\}.$
   经典泊松重建里，这意味着 $\chi$ 的绝对水平不定，最终取哪个等值面要靠后处理（如平均值、样本插值统计等）确定。
   若加 screened 项
   $(-\Delta+\lambda\sigma)\chi = \cdots$
   且 $\sigma\not\equiv 0$，零空间往往被破坏，解更稳定。但边界仍会影响“远离数据区时 $\chi$ 的延拓方式”。
   Dirichlet 情况
   若规定
   $\chi=0 \quad \text{on }\partial\Omega,$
   则边界上函数值被固定，解会倾向于朝该值回落。这会改变整个场的低频行为，尤其在数据远离边界不够远时，影响明显。
   7.3 两类边界条件在重建中的几何后果
   Neumann 边界


边界外法向导数为零；


场在盒子边界附近更“自然延拓”；


但经典泊松下常数偏置不定；


更适合让边界“不主动施加内外标签”。


Dirichlet 边界


边界值固定，例如设为外部值 0；


更明确地区分外部区域；


但若包围盒离物体不够远，会把场强行拉向 0，影响大尺度形状；


在 screened poisson 中可能使外部更稳定，但也更有边界偏置。


因此它们绝非只是“在无基函数区给默认值”，而是在整个解空间层面决定了解如何全局传播。

8. 从理论到算法：完整流程
   下面按实现顺序写。
   8.1 输入与预处理
   输入：
   $\{(p_i,n_i,w_i)\}_{i=1}^N.$
   预处理通常包括：


法向定向一致化；


坐标归一化到包围盒 $\Omega$；


局部密度估计 $\rho_i$；


设置权重，如
$w_i = \frac{c_i}{\rho_i}$
或其他置信度模型。



8.2 八叉树构建
根据点分布递归细分立方体。常见准则：


单元中点数超过阈值则细分；


到达最大深度停止；


再做 2:1 balance。


得到自适应树 $\mathcal T$。
数学意义
树不是最终离散未知量本身，而是定义函数空间 $V_h$ 与局部积分区域的几何骨架。

8.3 法向 splat 到层级网格
定义局部核 $K_i(x)$，构造
$V_h(x)=\sum_i w_i n_i K_i(x).$
核可选择与局部单元尺度匹配。若点 $p_i$ 位于深度 $\ell_i$ 的叶单元，则 $K_i$ 的支撑常与 $h_{\ell_i}$ 同阶。
更离散一点，可以把向量场投影到某个向量值基空间
$V_h(x)=\sum_\gamma v_\gamma \Psi_\gamma(x).$
这样右端项变成
$b_\beta
=
\int_\Omega V_h\cdot \nabla B_\beta\,dx
=
\sum_\gamma v_\gamma \int_\Omega \Psi_\gamma\cdot\nabla B_\beta\,dx.$

8.4 装配线性系统
8.4.1 经典泊松
取
$\chi_h=\sum_\alpha x_\alpha B_\alpha.$
则
$A x = b,$
其中
$A_{\alpha\beta}=\int_\Omega \nabla B_\alpha\cdot\nabla B_\beta\,dx,$
$b_\beta=\int_\Omega V_h\cdot \nabla B_\beta\,dx.$
若写成散度形式
也可先计算
$d_\beta = \int_\Omega (\nabla\cdot V_h) B_\beta\,dx,$
然后
$A x = d.$
两者在弱形式下等价（边界项按边界条件处理）。
8.4.2 Screened Poisson
加入样本点值项后，系统为
$(A+\lambda S)x = b + \lambda t,$
其中
$S_{\alpha\beta}=\sum_i \mu_i B_\alpha(p_i)B_\beta(p_i),$
$t_\beta=\sum_i \mu_i f_i B_\beta(p_i).$
如果 $f_i\equiv c$，则相当于鼓励样本点附近 $\chi\approx c$，于是最终直接取等值面 $c$ 或附近值。

8.5 多重网格/层级求解
由于 $A$ 源自椭圆算子，适合多重网格。
层级结构
八叉树天然提供层级：
$V_0\subset V_1\subset \cdots \subset V_L.$
粗层处理低频误差，细层处理高频误差。
典型步骤


预平滑（Gauss–Seidel/Jacobi）；


计算残差
$r=b-Ax;$


限制到粗层；


在粗层解修正；


prolongation 回细层；


后平滑。


自适应层级中，限制/插值算子由基函数嵌套关系给出，不是随意插值。

9. 公式级总结
   下面把最核心的公式集中列出。

   9.1 经典泊松重建
   连续能量
   $E(\chi)=\int_\Omega \|\nabla\chi -V\|^2 dx.$
   弱形式
   $\int_\Omega \nabla\chi\cdot\nabla\phi\,dx
   =
   \int_\Omega V\cdot\nabla\phi\,dx.$
   强形式
   $\Delta\chi=\nabla\cdot V$
   （配边界条件）。
   离散系统
   $A x=b,$
   $A_{\alpha\beta}=\int_\Omega \nabla B_\alpha\cdot\nabla B_\beta\,dx,
   \qquad
   b_\beta=\int_\Omega V_h\cdot\nabla B_\beta\,dx.$

   9.2 Screened Poisson
   连续能量
   $E(\chi)=
   \int_\Omega \|\nabla\chi-V\|^2 dx
   +
   \lambda\sum_i \mu_i(\chi(p_i)-f_i)^2.$
   离散系统
   $(A+\lambda S)x=b+\lambda t,$
   $S_{\alpha\beta}=\sum_i \mu_i B_\alpha(p_i)B_\beta(p_i),
   \qquad
   t_\beta=\sum_i \mu_i f_i B_\beta(p_i).$

   9.3 关于你的三个问题的最简结论
   问题 1：自适应八叉树中基函数与内积


基函数由母样条 + 层级尺度 + 平移位置确定；


支撑半径 $\asymp h_\ell$，不是人工额外指定；


相邻粗细节点的矩阵元统一写成
$A_{\alpha\beta}=\int \nabla B_\alpha\cdot\nabla B_\beta,$
只在支撑相交时非零；


张量积样条使积分可分解为一维积分乘积。


问题 2：点云权重


经典泊松中通过 $V$ 改变右端；


screened 中既影响梯度约束，也可影响点值约束；


本质上改变各采样对解的“发言权”；


常见作用：密度补偿、置信度抑噪、局部细节加强或削弱。


问题 3：Neumann / Dirichlet


它们不是“默认初始值”；


它们决定 PDE 的边界闭合方式、零空间、解的唯一性与全局偏置；


Neumann 更自然延拓但经典泊松有常数不定；


Dirichlet 把边界值钉住，能固定外部背景，但会引入边界偏置；


screened 项则进一步从内部样本处锚定函数值。
