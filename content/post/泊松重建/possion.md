## 目录

一、1∶2平衡先答疑
二、泊松重建的连续理论
三、自适应八叉树上的基函数
四、不同分辨率节点之间的积分内积
五、点云权重如何进入方程并影响结果
六、screened poisson重建与边界条件
七、完整算法流程，不含marching cubes

---

# 一、1∶2平衡先答疑

你的两个理解中，**第二个是正确的**：

$\text{相邻叶子节点的深度差不超过}1$

等价地，若两个相邻叶子单元为(K_i,K_j)，边长分别为(h_i,h_j)，则

$\frac{\max(h_i,h_j)}{\min(h_i,h_j)}\leq 2$

因为八叉树中

$h=2^{-d}$

所以边长比不超过(2)，等价于深度差不超过(1)：

$|d_i-d_j|\leq 1$

这里的相邻一般指**共享面**，有些实现会扩大到共享边、共享点，具体取决于有限元构造或dual contouring拓扑连接的要求。有限元文献中，2∶1平衡通常表述为几何相邻单元最多相差一个细化层级，用来限制悬挂节点复杂度；有的定义还会根据面、边、点的相邻类型区分不同强度的平衡条件。

**第一个理解不对。**

第一个理解是：

$\max_{K\in\mathcal T}d(K)-\min_{K\in\mathcal T}d(K)\leq 1$

这会导致整个八叉树几乎变成半均匀网格，基本失去自适应意义。泊松重建和dual contouring中的1∶2平衡，不要求所有叶子节点深度接近，只要求**局部过渡不能太剧烈**。

例如可以有：

$d=3\rightarrow4\rightarrow5\rightarrow6\rightarrow7$

这样的逐级过渡，但不允许某个深度(3)的叶子单元直接贴着深度(7)的叶子单元。

---

# 二、泊松重建的连续理论

给定有向点云：

$P={(p_s,n_s)}_{s=1}^{N}$

其中$p_s\in\mathbb R^3$，$n_s$为一致定向法向。泊松重建的基本思想是：若实体区域为$M$，其指示函数为

$$\chi(x)=
\begin{cases}
1,&x\in M,\
0,&x\notin M
\end{cases}$$

则(\chi)在区域内部和外部几乎处处为常数，只有在边界(\partial M)附近发生跃迁。因此(\nabla\chi)只在曲面附近非零，并与曲面法向相关。Kazhdan等人的原始泊松重建正是把有向点云看作指示函数梯度场的离散采样，然后求一个标量函数(\chi)，使其梯度尽量逼近由法向点云构造出的向量场(V)。([Hugues Hoppe][1])

连续变分问题可写为：

$\min_{\chi}\int_{\Omega}|\nabla \chi(x)-V(x)|^2,dx$

其中$\Omega$是包含点云的有限计算区域，通常取归一化后的包围立方体。

对$\chi$取一阶变分。令扰动函数为(\delta\chi)，则有：

$$0=\frac{d}{d\epsilon}
\int_{\Omega}|\nabla(\chi+\epsilon\delta\chi)-V|^2dx
\bigg|_{\epsilon=0}$$

即

$\int_{\Omega}(\nabla\chi-V)\cdot\nabla\delta\chi,dx=0$

若边界项按相应边界条件消去，则得到弱形式：

$$\int_{\Omega}\nabla\chi\cdot\nabla\delta\chi,dx=\int_{\Omega}V\cdot\nabla\delta\chi,dx$$

对应强形式为泊松方程：

$\Delta\chi=\nabla\cdot V$

原始论文也将该问题解释为由$\nabla\chi\approx V$转化为$\Delta\chi=\nabla\cdot V$的空间泊松问题。([Hugues Hoppe][1])

注意：一般由点云法向构造出的(V)并不严格可积，即未必存在某个精确的$\chi$满足

$\nabla\chi=V$

所以泊松重建求的是最小二乘意义下的全局最优标量场。

---

# 三、自适应八叉树上的基函数

设八叉树节点为$o$，其中心为$c_o$，边长为$h_o$，深度为$d_o$，则

$h_o=2^{-d_o}$

泊松重建不是直接给每个点一个径向基函数，而是给八叉树空间中的节点定义局部支撑基函数。原始论文中，对每个八叉树节点(o)定义一个由固定基函数平移、缩放得到的节点函数：

$F_o(q)=\frac{1}{h_o^3}F\left(\frac{q-c_o}{h_o}\right)$

其中$F:\mathbb R^3\rightarrow\mathbb R$是单位积分的紧支撑基函数。原始论文将这类节点函数作为函数空间的基，并利用八叉树的多分辨率结构提高近曲面区域的表达精度。([Hugues Hoppe][1])

若(F)采用三维张量积形式：

$F(x,y,z)=\beta(x)\beta(y)\beta(z)$

则

$F_o(q)=\frac{1}{h_o^3}
\beta\left(\frac{x-c_{o,x}}{h_o}\right)
\beta\left(\frac{y-c_{o,y}}{h_o}\right)
\beta\left(\frac{z-c_{o,z}}{h_o}\right)$

这里的(h_o^{-3})保证：

$\int_{\mathbb R^3}F_o(q)dq=1$

所以不同深度节点的基函数不是同一个半径，而是随八叉树尺度自适应变化：

$\operatorname{supp}(F_o)\sim h_o$

深层节点：$h_o$小，基函数支撑范围小，能表达细节。
浅层节点：$h_o$大，基函数支撑范围大，表达低频、平滑成分。

原始实现中，基函数通常取近似高斯的紧支撑函数，例如由box filter卷积得到的分段多项式函数。论文中提到使用分段二次近似，支撑区域约为([-1.5,1.5]^3)，因此同一深度下一个基函数只与有限数量邻近基函数重叠，矩阵因而稀疏。([Hugues Hoppe][1])

---

# 四、不同分辨率节点之间的积分内积

设离散解为

$\chi_h(q)=\sum_{j}x_jF_j(q)$

代入弱形式：

$$\int_{\Omega}\nabla\chi_h\cdot\nabla F_i,dq=\int_{\Omega}V\cdot\nabla F_i,dq$$

得到线性系统：

$Ax=b$

其中

$A_{ij}=\int_{\Omega}\nabla F_j(q)\cdot\nabla F_i(q),dq$

$b_i=\int_{\Omega}V(q)\cdot\nabla F_i(q),dq$

如果采用强形式投影，也可写成：

$L_{ij}=\langle \Delta F_j,F_i\rangle$

$v_i=\langle \nabla\cdot V,F_i\rangle$

在边界项为零时，有：

$$\langle \Delta F_j,F_i\rangle=-\langle \nabla F_j,\nabla F_i\rangle$$

所以两种写法只差符号和边界项处理。原始论文中正是通过将拉普拉斯项与基函数做内积，构造稀疏对称线性系统。([Hugues Hoppe][1])

现在看不同深度节点之间的积分。设节点(i,j)的尺度分别为(h_i,h_j)，中心分别为(c_i,c_j)。若

$F_i(q)=\frac{1}{h_i^3}F\left(\frac{q-c_i}{h_i}\right)$

$F_j(q)=\frac{1}{h_j^3}F\left(\frac{q-c_j}{h_j}\right)$

则刚度矩阵元素为：

$$A_{ij}=\sum_{\alpha\in{x,y,z}}
\int_{\Omega}
\frac{\partial F_i}{\partial \alpha}
\frac{\partial F_j}{\partial \alpha}
dq$$

以(x)方向为例：

$$\frac{\partial F_i}{\partial x}=\frac{1}{h_i^4}
\frac{\partial F}{\partial x}
\left(\frac{q-c_i}{h_i}\right)$$

因此

$$A_{ij}^{x}=\int_{\Omega}
\frac{1}{h_i^4}
F_x'\left(\frac{q-c_i}{h_i}\right)
\frac{1}{h_j^4}
F_x'\left(\frac{q-c_j}{h_j}\right)
dq$$

若(F)是张量积基函数，则三维积分可以拆成三个一维积分。定义：

$$J_{\alpha}^{mn}(i,j)=\int
\beta^{(m)}
\left(\frac{t-c_{i,\alpha}}{h_i}\right)
\beta^{(n)}
\left(\frac{t-c_{j,\alpha}}{h_j}\right)
dt$$

其中$m,n\in{0,1}$。则

$$A_{ij}=h_i^{-4}h_j^{-4}
J_x^{11}J_y^{00}J_z^{00}
+
h_i^{-4}h_j^{-4}
J_x^{00}J_y^{11}J_z^{00}
+
h_i^{-4}h_j^{-4}
J_x^{00}J_y^{00}J_z^{11}$$

这就是不同尺度基函数之间的积分内积形式。

如果两个基函数支撑集不相交，则

$A_{ij}=0$

因此矩阵稀疏。若基函数支撑半径为(r h)，则非零条件大致为：

$$|c_{i,\alpha}-c_{j,\alpha}|
\leq r(h_i+h_j)
\quad
\alpha=x,y,z$$

这说明所谓相邻节点积分，不只是面邻接，而是**支撑集有重叠的基函数之间才产生非零矩阵元素**。

1∶2平衡在这里的作用是：使局部相邻节点的尺度比只可能是

$1:1,\quad1:2,\quad2:1$

因此跨层积分的组合类型有限，可以预计算不同相对位置和尺度比下的积分模板。否则，若一个很粗的节点直接邻接极细节点，局部支撑交互会复杂得多，矩阵模板和悬挂节点处理都会变困难。

---

# 五、点云权重如何进入方程并影响结果

点云权重主要以三种方式进入泊松重建。

## 5.1面积权重，也就是密度补偿

点云通常非均匀采样。若某区域点很多，不加处理会使该区域在全局能量中占据过大权重。经典处理是估计局部采样密度(\rho_s)，然后令每个点代表的面积为：

$a_s\approx \frac{1}{\rho_s}$

于是向量场可写为：

$V(q)=
\sum_s a_s n_s K_s(q-p_s)$

其中$K_s$是局部核函数或由八叉树基函数组合得到的滤波核。原始论文在非均匀采样部分明确使用密度估计，并令点贡献与其代表的表面积成正比，即与采样密度成反比。([Hugues Hoppe][1])

效果是：

$\text{密集区域不会因点数多而过度支配整体方程}$

若不做密度补偿，重建曲面会更容易被高密度扫描区域吸引。

## 5.2法向置信度权重

若每个点有置信度$\eta_s$，可以写成：

$V(q)=
\sum_s \eta_s a_s n_s K_s(q-p_s)$

或者将法向长度编码为权重：

$\tilde n_s=\eta_s n_s$

高置信度点更强地影响梯度场；低置信度点影响较弱。PoissonRecon官方实现中也提供了使用normal length作为样本贡献权重的选项。([GitHub][2])

其效果是：

$$\eta_s\uparrow
\Rightarrow
\text{局部法向约束增强}$$

$\eta_s\downarrow
\Rightarrow
\text{该点对曲面形状影响减弱}$

如果噪声点权重过高，会产生局部鼓包、褶皱或错误闭合。

## 5.3screening点位置权重

screened poisson在原始梯度拟合项之外加入点位置约束。一般可写为：

$$E(\chi)=\int_{\Omega}|\nabla\chi-V|^2dq
+
\lambda
\sum_s w_s
\left(\chi(p_s)-\tau_s\right)^2$$

若采用零水平集记号，通常取：

$\tau_s=0$

即希望输入点落在隐式曲面的零水平附近：

$\chi(p_s)\approx0$

若采用指示函数记号，也可以把$\tau_s$理解为待抽取等值面对应的常值。二者本质上只差一个常数平移。

离散后，screening项给线性系统增加：

$C_{ij}=\sum_s w_sF_i(p_s)F_j(p_s)$

$d_i=\sum_s w_s\tau_sF_i(p_s)$

于是总系统为：

$(A+\lambda C)x=b+\lambda d$

如果$\tau_s=0$，则

$d_i=0$

此时screening只增加矩阵项：

$A+\lambda C$

$\lambda$或$w_s$越大，曲面越贴近输入点；越小，越接近原始泊松重建的平滑全局结果。官方PoissonRecon中，`--pointWeight`就是控制点样本插值约束在screened poisson方程中的重要性；设为(0)即可退化为原始unscreened泊松重建。([GitHub][2])

效果可以概括为：

$$\lambda\downarrow
\Rightarrow
\text{更平滑，更能补洞，但细节可能被抹平}$$

$$\lambda\uparrow
\Rightarrow
\text{更贴合点云，细节更锐，但更容易过拟合噪声}$$

screened poisson论文也说明，其扩展核心是显式加入点插值约束，并仍保留有限元离散和多重网格求解结构。([SciSpace][3])

---

# 六、screened poisson重建与边界条件

泊松重建实际是在有限计算域$\Omega$上求解：

$\Delta\chi=\nabla\cdot V$

而不是在整个(\mathbb R^3)上求解。因此必须处理边界(\partial\Omega)。

从弱形式看：

$$\int_{\Omega}\nabla\chi\cdot\nabla\phi,dq=\int_{\Omega}V\cdot\nabla\phi,dq$$

若做分部积分，会出现边界项：

$$\int_{\partial\Omega}\phi
\left(\frac{\partial\chi}{\partial n}-V\cdot n
\right)dS$$

不同边界条件本质上就是对这个边界项或函数空间施加不同限制。

## 6.1Neumann边界条件

齐次Neumann边界一般写为：

$$\frac{\partial\chi}{\partial n}=0
\quad\text{on }\partial\Omega$$

含义是：在包围盒边界法向方向上，隐函数不再发生变化。

如果边界附近没有点云，通常$V\approx0$，则自然边界条件可近似理解为：

$\nabla\chi\cdot n=0$

这会允许(\chi)在边界处取非零常数。纯Neumann问题存在常数零空间，即：

$\chi \quad\text{和}\quad \chi+C$

具有相同梯度。因此unscreened情形下需要通过平均值、等值面选择或额外约束固定常数。screening项存在时，点值约束会部分消除这种自由度。

## 6.2Dirichlet边界条件

齐次Dirichlet边界写为：

$\chi=0
\quad\text{on }\partial\Omega$

含义是：在计算域边界上直接钉住隐函数值。有限元实现中，这通常表现为：

$\phi_i|_{\partial\Omega}=0$

也就是选取或修改基函数，使试探函数空间满足边界值约束。

它不是简单给无基函数区域设置初始值，而是改变了可 admissible 的函数空间：

$$X_h^{D}={\chi_h\in X_h:\chi_h|_{\partial\Omega}=0}$$

因此靠近边界的矩阵元素会改变。

## 6.3Free边界条件

PoissonRecon新版中还提供free、Dirichlet、Neumann三种有限元边界类型。官方参数说明中，`--bType`的有效值包括free、Dirichlet和Neumann，默认实现中常见默认值为Neumann。([GitHub][2])

free边界可以理解为不强制函数值为零，也不强制普通的齐次Neumann形式，而是在有限元基函数构造中允许边界自由延拓。它通常减少边界钉死造成的偏差，但也可能让边界附近的隐函数更自由。

## 6.4对你疑问的直接回答

你说：

> 似乎只是在默认没有基函数作用的区间提供不同的初始值。

这个理解不准确。

更准确地说：

$\text{边界条件改变的是函数空间、边界项和靠边界的矩阵元素}$

不是简单改变初始值。

不过，如果某个基函数支撑集完全远离边界，则它的矩阵元素不受边界条件影响。边界条件主要影响：

$\operatorname{supp}(F_i)\cap\partial\Omega\neq\varnothing$

的那些基函数。

所以可以这样理解：

$\text{远离边界：Dirichlet、Neumann差别很小}$

$\text{靠近边界：差别明显}$

---

# 七、完整算法流程，不含marching cubes

## 7.1输入

输入有向点云：

$P={(p_s,n_s)}_{s=1}^{N}$

要求法向方向基本一致。若法向混乱，则(V)会相互抵消或产生错误散度，泊松解会失败。

## 7.2归一化计算域

取点云包围盒，扩展一定比例，映射到立方体：

$\Omega=[0,1]^3$

扩展比例用于避免曲面贴近边界。PoissonRecon中也有类似`--scale`参数控制重建立方体相对点云包围盒的大小。([GitHub][2])

## 7.3构建自适应八叉树

基本规则：

一、在点云附近细化；
二、点密集或曲率细节丰富处可更细；
三、远离点云区域保持较粗；
四、必要时执行1∶2平衡。

原始论文中，八叉树由点样本位置决定，并在近曲面区域提供高分辨率函数空间。([Hugues Hoppe][1])

现代实现中还常用`samplesPerNode`控制细化强度。较小值允许更深细化，适合低噪声数据；较大值会让每个节点包含更多点，结果更平滑，更适合噪声点云。PoissonRecon官方说明也指出，噪声较大时可使用更大的`samplesPerNode`以获得更平滑的重建。([GitHub][2])

## 7.4为八叉树节点定义基函数

对每个活动节点$o$，定义：

$F_o(q)=\frac{1}{h_o^3}F\left(\frac{q-c_o}{h_o}\right)$

形成有限维空间：

$X_h=\operatorname{span}{F_o:o\in\mathcal O}$

这里的$\mathcal O$不是所有均匀网格节点，而是自适应八叉树中的活动节点集合。

## 7.5构造向量场

均匀采样时，可写为：

$V(q)=
\sum_s
\sum_{o\in N_D(p_s)}
\alpha_{o,s}F_o(q)n_s$

其中$N_D(p_s)$表示点$p_s$附近的若干深度$D$节点，$\alpha_{o,s}$是三线性插值权重。原始论文使用三线性插值将样本分配到邻近节点，从而避免直接把样本钳制到单元中心造成的位置误差。([Hugues Hoppe][1])

非均匀采样时，加入密度补偿：

$$V(q)=
\sum_s
\frac{1}{\rho_s}
\sum_{o\in N_D(p_s)}
\alpha_{o,s}F_o(q)n_s$$

若有置信度：

$$V(q)=
\sum_s
\eta_s\frac{1}{\rho_s}
\sum_{o\in N_D(p_s)}
\alpha_{o,s}F_o(q)n_s$$

## 7.6组装泊松线性系统

对每个基函数(F_i)，写弱形式：

$$\sum_j x_j\int_{\Omega}\nabla F_j\cdot\nabla F_i,dq=\int_{\Omega}V\cdot\nabla F_i,dq$$

即：

$Ax=b$

其中：

$$A_{ij}=\int_{\Omega}\nabla F_j\cdot\nabla F_i,dq$$

$b_i=
\int_{\Omega}V\cdot\nabla F_i,dq$

由于$F_i,F_j$紧支撑，只有支撑重叠时：

$A_{ij}\neq0$

所以系统稀疏。

## 7.7加入screening项

若使用screened poisson，则组装：

$(A+\lambda C)x=b+\lambda d$

其中：

$C_{ij}=\sum_s w_sF_i(p_s)F_j(p_s)$

$d_i=\sum_s w_s\tau_sF_i(p_s)$

若采用零水平集约束：

$\tau_s=0$

则：

$d_i=0$

screening项本质是点值约束，不是法向约束；它控制的是曲面是否经过点附近，而泊松项控制的是隐函数梯度是否符合点云法向场。

## 7.8求解

由于矩阵稀疏、对称，并具有多分辨率结构，通常使用多重网格、Gauss-Seidel、共轭梯度或它们的组合求解。PoissonRecon代码库也说明其实现已经发展为支持自适应有限元、多种B样条阶数、点约束和积分约束的多重网格框架。([GitHub][2])

求得系数：

$x={x_j}$

于是得到隐函数：

$\chi_h(q)=\sum_jx_jF_j(q)$

到这里为止，泊松重建的核心数学问题已经完成。之后才是从$\chi_h$中提取等值面，这一步你暂时不需要展开。

---

## 最简总结

泊松重建的核心方程是：

$\min_{\chi}\int_{\Omega}|\nabla\chi-V|^2dq$

离散后是：

$Ax=b$

screened poisson是：

$$\min_{\chi}
\int_{\Omega}|\nabla\chi-V|^2dq
+
\lambda\sum_sw_s(\chi(p_s)-\tau_s)^2$$

离散后是：

$(A+\lambda C)x=b+\lambda d$

八叉树不同深度的基函数不是同半径，而是：

$F_o(q)=h_o^{-3}F\left(\frac{q-c_o}{h_o}\right)$

节点越深，$h_o$越小，基函数越局部。

1∶2平衡的正确含义是：

$\text{相邻叶子节点深度差不超过}1$

不是所有叶子节点深度差不超过(1)。

[1]: https://hhoppe.com/poissonrecon.pdf "Poisson surface reconstruction"
[2]: https://github.com/mkazhdan/PoissonRecon "GitHub - mkazhdan/PoissonRecon: Poisson Surface Reconstruction · GitHub"
[3]: https://scispace.com/papers/screened-poisson-surface-reconstruction-1qtztseo1f "(PDF) Screened poisson surface reconstruction (2013) | Michael Kazhdan | 2355 Citations"

-----

下面按你的问题重新讲。重点放在三个地方：**1∶2平衡到底怎么定义；泊松重建到底选哪些基函数；不同边界条件怎样真正改变离散系统**。

---

# 1. 1∶2 balance 中“相邻”是什么意思？

严格说，八叉树叶子单元之间有三种邻接：

设两个叶子单元为 $K_i,K_j$。

如果

$\dim(\overline K_i\cap \overline K_j)=2$

则它们**共享面**，称为 face-neighbor。

如果

$\dim(\overline K_i\cap \overline K_j)=1$

则它们共享边，称为 edge-neighbor。

如果

$\dim(\overline K_i\cap \overline K_j)=0$

则它们共享顶点，称为 vertex-neighbor。

最常见的 1∶2 balance 指的是：

$K_i,K_j \text{ face-neighbor}
\quad\Longrightarrow\quad
|d_i-d_j|\leq 1$

也就是**共享面的叶子节点深度差不超过 1**。

等价地：

$\frac{\max(h_i,h_j)}{\min(h_i,h_j)}\leq 2$

其中

$h_i=2^{-d_i},\qquad h_j=2^{-d_j}$

所以你的理解应该改成：

$\boxed{
\text{1∶2 balance 通常指局部相邻叶子单元深度差不超过 1，而不是全局所有叶子深度差不超过 1。}
}$

不过要注意：在不同算法中，“相邻”范围可能不同。

对于 dual contouring，很多实现至少要求**共享面**的叶子单元满足 1∶2 balance，这样可以避免粗细单元交界处出现裂缝。

对于有限元泊松重建，严格说矩阵相邻不是“共享面”，而是：

$\operatorname{supp}(B_i)\cap \operatorname{supp}(B_j)\neq\varnothing$

也就是两个基函数支撑域有重叠。

如果基函数是高阶 B-spline，它的支撑范围可能跨过面邻接、边邻接甚至点邻接。因此泊松重建中实际更重要的是：

$\boxed{
\text{所有会发生积分耦合的基函数，其尺度差不能过大。}
}$

所以工程实现中可能使用比“共享面”更强的平衡，例如 face + edge + vertex 的全邻域平衡，或者在基函数支撑范围内额外补节点。

---

# 2. 泊松重建只选叶子节点上的基函数吗？

结论：

$\boxed{
\text{不是。经典泊松重建和现代 screened poisson 都不是简单只选叶子节点基函数。}
}$

2006 年原始泊松重建中，给定八叉树 $\mathcal O$，作者为树中每个节点 $o\in\mathcal O$ 定义一个 node function，而不是只给叶子节点定义基函数。论文中明确写到：对于每个八叉树节点 (o)，定义以节点中心为中心、按节点宽度缩放的单位积分函数 $F_o$。([Hugues Hoppe][1])

其形式为：

$$F_o(q)=\frac{1}{w_o^3}
F\left(
\frac{q-c_o}{w_o}
\right)$$

其中：

$c_o=\text{节点中心}$

$w_o=\text{节点宽度}$

因此，深层节点对应小支撑基函数，浅层节点对应大支撑基函数：

$$d_o\uparrow
\quad\Longrightarrow\quad
w_o\downarrow
\quad\Longrightarrow\quad
\operatorname{supp}(F_o)\downarrow$$

这正是多分辨率表示。

如果只使用叶子节点基函数，会有几个问题：

第一，低频部分缺少粗尺度表达。
第二，粗细过渡区域的函数空间不稳定。
第三，矩阵条件数可能变差。
第四，基函数和为 1 的性质不容易保持。
第五，多重网格求解时，粗层到细层的 prolongation / restriction 结构会被破坏。

现代 PoissonRecon 实现已经发展为一般的自适应有限元框架，支持任意维度、不同阶有限元、点约束和积分约束。官方 README 也说明其采用有限元系统，并支持不同 B-spline degree。([GitHub][2])

screened poisson 的较新描述中，隐函数空间通常由适配点云的八叉树上的 B-spline 基函数离散，并最终得到一个稀疏对称正定线性系统，用多重网格求解。([Hugues Hoppe][3])

所以更准确的说法是：

$$\boxed{
\text{基函数不是按“叶子单元”简单选取，而是按八叉树层级构造一个自适应层次函数空间。}
}$$

---

# 3. 为什么需要“截断基函数”？

你提到的“为了满足单位分解性，需要对基函数截断”，这个说法对应的是**层次 B-spline / truncated hierarchical B-spline** 一类思想。

先从普通均匀网格说起。

在均匀网格上，B-spline 基函数满足：

$\sum_i B_i(x)=1$

这叫 partition of unity，即单位分解性。

三维张量积情况下：

$B_{ijk}(x,y,z)=B_i(x)B_j(y)B_k(z)$

也有：

$\sum_{i,j,k}B_{ijk}(x,y,z)=1$

这个性质很重要，因为它保证常数函数可以被精确表示：

$c=\sum_i cB_i(x)$

如果基函数不满足单位分解性，那么即便是常数场也可能无法稳定表示，低频误差会进入泊松解。

---

# 4. 普通层次 B-spline 为什么会破坏单位分解？

设有两层网格：

粗层：

$\mathcal B^0={B_i^0}$

细层：

$\mathcal B^1={B_j^1}$

在各自完整网格上都有：

$\sum_i B_i^0(x)=1$

$\sum_j B_j^1(x)=1$

现在假设某个局部区域被细化，记细化区域为：

$\Omega^1\subset\Omega^0$

如果简单地在粗层保留部分基函数，同时在细化区域加入细层基函数，那么在细化区域中可能出现：

$\sum_{B_i^0\in A^0}B_i^0(x)
+
\sum_{B_j^1\in A^1}B_j^1(x)
\neq 1$

因为粗层基函数仍然覆盖细化区域，而细层基函数也覆盖细化区域，二者发生重复贡献。

直观上就是：

$\text{粗层没有退出，细层又进来了}$

所以局部基函数总和可能大于 1，也可能在过渡区出现畸变。

---

# 5. 截断基函数的数学形式

B-spline 有 refinement relation。也就是说，粗层基函数可以表示为细层基函数的线性组合：

$$B_i^\ell=\sum_j c_{ij}^{\ell+1}B_j^{\ell+1}$$

其中 $c_{ij}^{\ell+1}$是 refinement 系数。

如果区域 $\Omega^{\ell+1}$被细化，那么粗层基函数在该区域内的贡献应当被细层基函数替代。

因此定义截断算子：

$$\operatorname{trunc}^{\ell+1}(B_i^\ell)=\sum_{j:\operatorname{supp}(B_j^{\ell+1})\not\subset \Omega^{\ell+1}}
c_{ij}^{\ell+1}B_j^{\ell+1}$$

也就是：把粗层基函数展开到细层后，删除那些完全落入细化区域的细层分量。

被删除的部分由细层 active basis 来表示。

递归截断后得到：

$$T(B_i^\ell)=\operatorname{trunc}^{L}
\circ\cdots\circ
\operatorname{trunc}^{\ell+1}(B_i^\ell)$$

于是自适应基函数集合变为：

$$\mathcal T={T(B):B\in\mathcal H}$$

其中 $\mathcal H$是普通 hierarchical basis，$\mathcal T$ 是 truncated hierarchical basis。

截断的作用是：

$\boxed{
\text{在细化区域内削去粗基函数的贡献，使细基函数接管局部表达。}
}$

它带来三个结果：

$\sum_{B\in\mathcal T}B(x)=1$

$\operatorname{supp}(T(B_i^\ell))\subseteq \operatorname{supp}(B_i^\ell)$

$\text{矩阵更稀疏，粗细过渡更稳定}$

THB-spline 文献也指出，普通 hierarchical construction 不保持 partition of unity，而 truncated hierarchical B-spline 可以形成凸的单位分解，并具有更好的稳定性和近似性质。([Angewandte Geometrie][4])

---

# 6. 泊松重建中的“截断”有两类，不要混淆

你看到的“截断”可能指两种不同事情。

## 6.1 自适应层次基函数的截断

这是上一节讲的 THB-spline 类型截断。

目标是：

$\sum_i B_i(x)=1$

并减少粗层基函数在细化区域的重复贡献。

## 6.2 边界约束下的基函数截断或重塑

这是 Dirichlet 边界条件相关的问题。

例如在带 envelope constraints 的 screened poisson 中，为了保证重建曲面不跑到 envelope 外面，作者要求隐函数在外部区域为零，因此需要修改函数空间，使基函数支撑不进入外部区域。论文中明确说：为了施加 Dirichlet 约束，需要保证 B-spline 的支撑不与外部叶子节点重叠；可以直接删除这些基函数，也可以 reshape，使其支撑不再覆盖外部节点。([Hugues Hoppe][3])

也就是说，边界情况下的处理不是为了普通意义上的单位分解，而是为了满足：

$\chi=0
\quad\text{on exterior / boundary}$

在这种情况下，基函数处理方式可能是：

$B_i \text{ removed}$

或者

$B_i \text{ reshaped / truncated}$

使得：

$\operatorname{supp}(B_i)\cap \Omega_{\text{exterior}}=\varnothing$

这和 THB-spline 的“粗细层截断”是相关但不同的问题。

---

# 7. 泊松重建的离散系统

设输入为有向点云：

$P={(p_s,n_s)}_{s=1}^N$

泊松重建的连续能量为：

$$E(\chi)=\int_\Omega
|\nabla\chi(x)-V(x)|^2dx$$

screened poisson 加入点值约束：

$$E(\chi)=\int_\Omega
|\nabla\chi(x)-V(x)|^2dx
+
\lambda
\sum_{s=1}^N
w_s
\left(\chi(p_s)-\tau_s\right)^2$$

如果采用指示函数约定，则输入点位于曲面附近，常用：

$\tau_s=\frac12$

因为最后提取的是：

$\chi^{-1}\left(\frac12\right)$

screened poisson 的综述描述中也明确写到，它要求 $\chi$ 的梯度匹配向量场 $V$，并使输入点处的函数值接近 (0.5)。([Hugues Hoppe][3])

设离散函数空间为：

$X_h=\operatorname{span}{B_i}_{i=1}^M$

离散解写成：

$\chi_h(x)=\sum_{j=1}^M x_jB_j(x)$

取测试函数：

$\phi=B_i$

对能量求一阶变分，得到：

$$\int_\Omega
\nabla \chi_h\cdot\nabla B_i dx
+
\lambda
\sum_s w_s\chi_h(p_s)B_i(p_s)=\int_\Omega
V\cdot\nabla B_i dx
+
\lambda
\sum_s w_s\tau_sB_i(p_s)$$

代入：

$\chi_h=\sum_jx_jB_j$

得到线性系统：

$(A+\lambda C)x=b+\lambda d$

其中：

[
A_{ij}
======

\int_\Omega
\nabla B_j\cdot\nabla B_i,dx
]

[
C_{ij}
======

\sum_s
w_sB_j(p_s)B_i(p_s)
]

[
b_i
===

\int_\Omega
V\cdot\nabla B_i,dx
]

[
d_i
===

\sum_s
w_s\tau_sB_i(p_s)
]

如果不使用 screening，则：

[
\lambda=0
]

系统退化为：

[
Ax=b
]

PoissonRecon 官方说明中，`pointWeight` 控制 screened poisson 中点样本插值的重要性；设为 0 可得到原始 unscreened Poisson reconstruction。([GitHub][2])

---

# 8. 不同分辨率基函数之间如何积分？

假设三维基函数为张量积：

$$B_i(x,y,z)=N_{i_x}^{\ell_i}(x)
N_{i_y}^{\ell_i}(y)
N_{i_z}^{\ell_i}(z)$$

其中层级为 $\ell_i$，网格宽度：

$h_i=2^{-\ell_i}$

一维 B-spline 可写作：

$$N_i^\ell(x)=N\left(\frac{x-i h_\ell}{h_\ell}\right)$$

对于另一个基函数 $B_j$，刚度矩阵元素为：

[
A_{ij}
======

\int_\Omega
\nabla B_i\cdot\nabla B_j,dx
]

展开为：

$$A_{ij}=\int_\Omega
\frac{\partial B_i}{\partial x}
\frac{\partial B_j}{\partial x}dx
+
\int_\Omega
\frac{\partial B_i}{\partial y}
\frac{\partial B_j}{\partial y}dx
+
\int_\Omega
\frac{\partial B_i}{\partial z}
\frac{\partial B_j}{\partial z}dx$$

因为 (B_i) 是张量积，所以例如第一项可以拆成：

$$\int
N_{i_x}'(x)N_{j_x}'(x)dx
\cdot
\int
N_{i_y}(y)N_{j_y}(y)dy
\cdot
\int
N_{i_z}(z)N_{j_z}(z)dz$$

不同层级时，积分仍然成立，只是两个一维函数的尺度不同：

$N_i^{\ell_i}(x)=N\left(\frac{x-c_i}{h_i}\right)$

$N_j^{\ell_j}(x)=N\left(\frac{x-c_j}{h_j}\right)$

若：

$\operatorname{supp}(B_i)\cap\operatorname{supp}(B_j)=\varnothing$

则：

$A_{ij}=0$

若支撑有交集，则进行积分。

在实际算法中通常不直接对每对基函数全局积分，而是按叶子单元 (K) 做局部装配：

$$A_{ij}=\sum_{K}
\int_K
\nabla B_i\cdot\nabla B_j,dx$$

其中只考虑：

$B_i|_K\neq0,\qquad B_j|_K\neq0$

这种写法适用于不同层级基函数、截断基函数、边界重塑基函数。

---

# 9. 边界条件如何影响系统？

这是你问得最关键的地方。

泊松重建的弱形式是：

$$\int_\Omega
\nabla\chi\cdot\nabla\phi,dx=\int_\Omega
V\cdot\nabla\phi,dx$$

screened 形式是：

$$\int_\Omega
\nabla\chi\cdot\nabla\phi,dx
+
\lambda\sum_sw_s\chi(p_s)\phi(p_s)=\int_\Omega
V\cdot\nabla\phi,dx
+
\lambda\sum_sw_s\tau_s\phi(p_s)$$

边界条件不是简单改变初始值，而是改变以下内容：

$\boxed{
\text{函数空间 }X_h
}$

$\boxed{
\text{基函数是否保留、截断、重塑}
}$

$\boxed{
\text{矩阵行列是否删除或修改}
}$

$\boxed{
\text{右端项是否加入边界积分}
}$

PoissonRecon 官方参数中，`bType` 支持 Free、Dirichlet、Neumann 三类边界条件；官方说明也指出 B-spline degree 会影响有限元系统阶数和矩阵稠密度。([GitHub][2])

下面分别讲。

---

# 10. Dirichlet 边界条件下的离散算法

Dirichlet 条件为：

$\chi=g
\quad\text{on }\partial\Omega$

最常见是齐次 Dirichlet：

$\chi=0
\quad\text{on }\partial\Omega$

此时函数空间变为：

$$X_h^D={\phi_h\in X_h:\phi_h|_{\partial\Omega}=0}$$

也就是说，测试函数必须满足：

$\phi|_{\partial\Omega}=0$

离散时有两种做法。

---

## 10.1 做法一：删除边界自由度

把所有自由度分成内部自由度和边界自由度：

$$x=
\begin{bmatrix}
x_I\
x_B
\end{bmatrix}$$

系统为：

$$\begin{bmatrix}
A_{II}&A_{IB}\\
A_{BI}&A_{BB}
\end{bmatrix}
\begin{bmatrix}
x_I\\
x_B
\end{bmatrix}=\begin{bmatrix}
b_I\\
b_B
\end{bmatrix}$$

Dirichlet 给定：

$x_B=g_B$

因此只求：

$$A_{II}x_I=b_I-A_{IB}g_B$$

如果是齐次 Dirichlet：

$g_B=0$

则：

$A_{II}x_I=b_I$

这时边界自由度不参与未知量求解。

---

## 10.2 做法二：直接选择满足边界条件的基函数

构造基函数时只保留：

$B_i|_{\partial\Omega}=0$

或者只保留支撑完全位于内部的基函数：

$\operatorname{supp}(B_i)\subset\Omega$

此时：

$\chi_h=\sum_{i\in I}x_iB_i$

天然满足：

$\chi_h|_{\partial\Omega}=0$

---

## 10.3 Dirichlet 对矩阵的影响

Dirichlet 不是改变初始值，而是把原来的系统：

$Ax=b$

改成：

$A_{II}x_I=b_I-A_{IB}g_B$

或者直接把函数空间改成：

$X_h\rightarrow X_h^D$

因此：

$$A_{ij}=\int_\Omega
\nabla B_j\cdot\nabla B_i dx$$

中的 $B_i,B_j$ 本身已经不同。

在 envelope constraints 中，作者就是通过重新定义函数空间，让 B-spline 的支撑完全位于 envelope 内部，从而让外部区域的函数值为零。([Hugues Hoppe][3])

---

# 11. Neumann 边界条件下的离散算法

Neumann 条件指定法向导数：

$$\frac{\partial \chi}{\partial n}=g_N
\quad\text{on }\partial\Omega$$

从强形式：

$\Delta\chi=\nabla\cdot V$

出发，乘以测试函数 (\phi)，并分部积分：

$$\int_\Omega \nabla\chi\cdot\nabla\phi,dx=\int_\Omega
V\cdot\nabla\phi,dx
+
\int_{\partial\Omega}
(g_N-V\cdot n)\phi,dS$$

因此 Neumann 边界下右端项为：

$$b_i=\int_\Omega
V\cdot\nabla B_i,dx
+
\int_{\partial\Omega}
(g_N-V\cdot n)B_i,dS$$

如果采用自然边界：

$g_N=V\cdot n$

则边界项消失：

$$b_i=\int_\Omega
V\cdot\nabla B_i,dx$$

如果 (V) 的支撑远离边界，那么在边界附近：

$V\cdot n\approx0$

此时齐次 Neumann：

$g_N=0$

和自然边界差别很小。

---

## 11.1 Neumann 对矩阵的影响

Neumann 条件下，不删除边界自由度。

所以未知量仍为：

$x=(x_1,\dots,x_M)^T$

矩阵仍然是：

$$A_{ij}=\int_\Omega
\nabla B_j\cdot\nabla B_i,dx$$

但右端项可能包含边界积分：

$\int_{\partial\Omega}
(g_N-V\cdot n)B_i,dS$

如果是自然边界，则没有额外边界项。

---

## 11.2 Neumann 的零空间问题

纯泊松 + 齐次 Neumann 有常数零空间。

因为：

$\nabla(\chi+C)=\nabla\chi$

所以：

$A\mathbf 1=0$

这会导致矩阵奇异。

处理方法有三种：

第一，加入 screening 项：

$\lambda C$

如果点约束足够，常数自由度会被固定。

第二，增加均值约束：

$\int_\Omega \chi,dx = c$

第三，求解后通过样本点平均值选择等值面，而不是依赖绝对常数。

泊松重建中常见做法是求出 (\chi) 后，用样本点处的函数值平均确定等值面：

$$\tau=\frac{1}{N}
\sum_s\chi(p_s)$$

screened poisson 中由于点值约束已经给定 (\tau_s\approx 0.5)，这个问题弱很多。

---

# 12. Free 边界条件下的离散含义

Free boundary 在不同实现中的精确定义会依赖有限元基函数构造。

在 PoissonRecon 里，Free、Dirichlet、Neumann 是有限元基函数类型的一部分；官方 README 把它们列为 `bType` 的三种可选边界类型。([GitHub][2])

从算法角度理解，Free boundary 的核心是：

$\text{不强制 }\chi=0$
也不显式钉住：
$\frac{\partial\chi}{\partial n}=0$
而是允许边界处的基函数自由参与拟合。
它对系统的影响主要体现在：
$$\boxed{
\text{边界附近 B-spline 的形状、支撑和索引集合不同}
}$$

但装配公式仍是：

$$A_{ij}=\int_\Omega
\nabla B_j\cdot\nabla B_i,dx$$

$$b_i=\int_\Omega
V\cdot\nabla B_i,dx$$

区别在于：

$B_i$

的边界形态不同。

---

# 13. 按边界条件构造系统的完整算法

下面给一个更接近实现的流程。

---

## Step 1：输入与归一化

输入：

$P={(p_s,n_s,w_s)}_{s=1}^N$

其中：

$p_s\in\mathbb R^3$

$n_s\in\mathbb S^2$

$w_s>0$

构造包围立方体：

$\Omega=[0,1]^3$

或扩大后的立方体。

PoissonRecon 中 `scale` 参数控制重建立方体相对点云包围盒的大小，官方说明默认值常见为 1.1。([GitHub][2])

---

## Step 2：构建自适应八叉树

设最大深度为：

$D_{\max}$

树节点宽度：

$h_\ell=2^{-\ell}$

构造规则：

$\text{点云附近细化}$

$\text{远离点云区域保持粗}$

$\text{必要时补齐 support neighborhood}$

$\text{执行 1∶2 balance}$

PoissonRecon 中 `depth` 是最大重建深度，`samplesPerNode` 控制一个八叉树节点中所需的最小采样数；噪声大时可取更大值以获得更平滑结果。([GitHub][2])

执行 balance 时：

$$K_i,K_j \text{ face-neighbor}
\Rightarrow
|d_i-d_j|\leq 1$$

如果使用高阶 B-spline，可扩展为：

$$K_j\in \mathcal N_{\operatorname{supp}}(K_i)
\Rightarrow
|d_i-d_j|\leq 1$$

其中 $\mathcal N_{\operatorname{supp}}$是基函数支撑邻域。

---

## Step 3：构造基函数集合

在每个层级 $\ell$上构造一维 B-spline：

$N_i^\ell(x)$

三维张量积基函数：

$$B_{ijk}^\ell(x,y,z)=N_i^\ell(x)N_j^\ell(y)N_k^\ell(z)$$

然后根据自适应八叉树选择 active basis。

不是只选择叶子节点，而是构造：

$$\mathcal B_h=\bigcup_{\ell=0}^{D_{\max}}
\mathcal B_h^\ell$$

其中每一层只保留与该层活动区域相关的基函数。

如果使用普通 hierarchical basis：

$$\mathcal H={B_i^\ell:
\operatorname{supp}(B_i^\ell)\subset \Omega^\ell,
\operatorname{supp}(B_i^\ell)\not\subset\Omega^{\ell+1}
}$$

如果使用 truncated hierarchical basis：

$$\mathcal T={T(B_i^\ell):B_i^\ell\in\mathcal H}$$

其中：

$$T(B_i^\ell)=\operatorname{trunc}^{L}
\circ\cdots\circ
\operatorname{trunc}^{\ell+1}
(B_i^\ell)$$

最后令：

$X_h=\operatorname{span}\mathcal T$

或：

$X_h=\operatorname{span}\mathcal H$

具体取决于实现。

---

## Step 4：根据边界条件修改基函数空间

### Dirichlet

若：

$$\chi=0
\quad\text{on }\partial\Omega$$

则只保留满足边界条件的基函数：

$B_i|_{\partial\Omega}=0$

或者删除 / reshape 支撑越界的基函数：

$\operatorname{supp}(B_i)\cap\Omega_{\text{outside}}=\varnothing$

此时：

$X_h\rightarrow X_h^D$

### Neumann

保留边界基函数：

$X_h^N=X_h$

不删除边界自由度。

必要时添加边界积分：

$\int_{\partial\Omega}
(g_N-V\cdot n)B_i,dS$

### Free

保留边界附近自由基函数，但使用 Free 类型的有限元边界基函数。

此时：

$X_h^F=X_h$

但边界处 $B_i$的形态与 Dirichlet / Neumann 不同。

---

## Step 5：构造向量场 $V$

将点法向扩散到函数空间。

可写为：

$$V(x)=\sum_s
a_sw_s n_s
\sum_{i\in\mathcal N(p_s)}
B_i(p_s)B_i(x)$$

其中：

$a_s$

是面积权重或密度补偿权重。

若点云局部密度为 $\rho_s$，可取：

$a_s\approx\frac1{\rho_s}$

如果使用 normal length 作为置信度，则：

$w_s=|n_s|$

PoissonRecon 官方说明中，`confidence` 选项会使用 normal length 作为样本贡献权重。([GitHub][2])

---

## Step 6：装配泊松刚度矩阵

对每个叶子单元 $K$，找出在该单元非零的基函数集合：

$I(K)={i:B_i|_K\neq0}$

局部装配：

$$A_{ij}^{K}=\int_K
\nabla B_i\cdot\nabla B_j,dx$$

全局累加：

$$A_{ij}=\sum_KA_{ij}^{K}$$

即：

$$A_{ij}=\sum_K
\int_K
\nabla B_i\cdot\nabla B_j,dx$$

如果 $B_i,B_j$ 是截断后的基函数，则直接使用：

$T(B_i),T(B_j)$

即：

$$A_{ij}=\sum_K
\int_K
\nabla T(B_i)\cdot\nabla T(B_j),dx$$

---

## Step 7：装配泊松右端项

若 $V$ 已经用基函数表示为：

$V(x)=\sum_m v_mB_m(x)$

则：

$$b_i=
\int_\Omega
V\cdot\nabla B_i,dx=$$

$$\sum_m
v_m\cdot
\int_\Omega
B_m\nabla B_i,dx$$

按单元装配：

$$b_i=
\sum_K
\int_K
V\cdot\nabla B_i,dx$$

若有 Neumann 边界：

$$b_i
\leftarrow
b_i+
\int_{\partial\Omega}
(g_N-V\cdot n)B_i,dS$$

Dirichlet 情况下没有这个边界项，因为测试函数满足：

$B_i|_{\partial\Omega}=0$

---

## Step 8：装配 screening 项

对每个点 $p_s$，找出非零基函数：

$I(p_s)={i:B_i(p_s)\neq0}$

累加：

$C_{ij}
\mathrel{+}=
w_sB_i(p_s)B_j(p_s)$

$d_i
\mathrel{+}=
w_s\tau_sB_i(p_s)$

最终系统：

$(A+\lambda C)x=b+\lambda d$

其中：

$\tau_s=\frac12$

或根据你的隐函数约定取 (0)。

---

## Step 9：根据 Dirichlet 消元

如果是 Dirichlet，且采用边界自由度消元：

$$x=
\begin{bmatrix}
x_I\\
x_B
\end{bmatrix}$$

$x_B=g_B$

则：

$$(A_{II}+\lambda C_{II})x_I=b_I+\lambda d_I=(A_{IB}+\lambda C_{IB})g_B$$

若 $g_B=0$，则：

$$(A_{II}+\lambda C_{II})x_I=b_I+\lambda d_I$$

---

## Step 10：处理 Neumann 零空间

如果是 unscreened Neumann：

$\lambda=0$

则需要处理常数零空间。

可加约束：

$\int_\Omega\chi_h dx=0$

离散为：

$m^Tx=0$

其中：

$m_i=\int_\Omega B_i dx$

可以求增广系统：

$$\begin{bmatrix}
A&m\\
m^T&0
\end{bmatrix}
\begin{bmatrix}
x\\
\mu
\end{bmatrix}=\begin{bmatrix}
b\\
0
\end{bmatrix}$$

如果使用 screened poisson，通常：

$A+\lambda C$

已经消除了常数自由度。

---

# 14. 最核心的修正结论

你现在可以这样理解：

$$\boxed{
\text{1∶2 balance 通常是共享面叶子单元深度差不超过 1。}
}$$

但在泊松有限元中，更准确的是：

$\boxed{
\text{基函数支撑域发生耦合的邻域内，尺度差不能过大。}
}$

基函数选择不是：$\text{只选叶子节点基函数}$

而是：

$$\boxed{
\text{从八叉树多层级中选 active basis，形成层次有限元空间。}
}$$

如果使用截断基函数，则核心是：

$$\boxed{
\text{粗基函数在细化区域内被截断，由细基函数接管局部表达。}
}$$

它的作用是保持：

$\sum_iB_i(x)=1$

并改善稀疏性与稳定性。

边界条件不是初始值问题，而是：

$\boxed{
\text{改变函数空间、基函数形状、未知量集合、矩阵和右端项。}
}$

Dirichlet：

$\chi=g\text{ on }\partial\Omega$

通过删除、固定、截断或重塑边界基函数实现。

Neumann：

$\frac{\partial\chi}{\partial n}=g_N$

通过保留边界自由度，并在右端加入边界积分实现；自然边界时边界项可消失。

Free：

$\text{不钉住函数值，也不显式钉住法向导数}$

主要体现为边界处有限元基函数类型不同。

[1]: https://hhoppe.com/poissonrecon.pdf "Poisson surface reconstruction"
[2]: https://github.com/mkazhdan/PoissonRecon "GitHub - mkazhdan/PoissonRecon: Poisson Surface Reconstruction · GitHub"
[3]: https://hhoppe.com/envelope.pdf "Poisson Surface Reconstruction with Envelope Constraints"
[4]: https://www.ag.jku.at/pubs/2016gjkmss.pdf?utm_source=chatgpt.com "THB-splines: An Effective Mathematical Technology for ..."

---

可以这样理解，但要改成更精确的版本：

$$\boxed{
\Omega^{\ell+1}\text{ 不是某个细层基函数的支撑集，而是第 }\ell+1\text{ 层细化区域。}
}$$

也就是说，它是一个**物理区域**，表示“从第 $\ell$层开始，这一块区域要交给更细的第 $\ell+1$层基函数来表达”。

------

# 1. 先修正你的整体理解

你说：

> 对于一个已经 balanced 的八叉树，对于每个节点选择它的相应普通基函数，然后每个基进行递归截断。

更准确地说应该是：

$$\boxed{
\text{在 balanced 八叉树对应的层次网格上，选择一组 active hierarchical basis，然后对其中的粗层 active basis 做递归截断。}
}$$

注意两个区别。

第一，不一定是“每个八叉树节点都选一个基函数”。
第二，截断主要作用在**粗层基函数**上，最细层基函数没有更细层可替代，一般不再截断。

如果是 THB-spline 框架，基函数选择不是：

$\text{所有节点全部选}$

而是：

$\text{每一层只选 active basis}$

即：

$\mathcal H=\bigcup_{\ell=0}^{L}\mathcal H^\ell$

其中：

$$\mathcal H^\ell={
B_i^\ell:
\operatorname{supp}(B_i^\ell)\subset \Omega^\ell,
\quad
\operatorname{supp}(B_i^\ell)\not\subset \Omega^{\ell+1}}$$

这里 $L$是最大深度，也就是 max depth。

------

# 2. $\Omega^\ell$到底是什么意思？

定义一组嵌套区域：

$\Omega^0\supseteq \Omega^1\supseteq \cdots \supseteq \Omega^L$

其中：

$\Omega^0=\Omega$

表示整个计算区域。

而：

$\Omega^\ell$

表示**需要用第 $\ell$ 层或更细层基函数表达的区域**。

更直观地说：

$$\Omega^{\ell+1}=\text{从第 }\ell\text{ 层继续细化到第 }\ell+1\text{ 层的区域}$$

它通常是若干个八叉树单元的并集。

例如：

$\Omega^{3}$

表示“已经细化到第 3 层及更深层的区域”。

$\Omega^{4}$

表示“需要由第 4 层及更深层接管的区域”。

因此：

$\boxed{
\Omega^{\ell+1}\text{ 是细化区域，不是第 }\ell+1\text{ 层截断后基函数的支撑集。}
}$

------

# 3. 为什么 active basis 要用这个条件？

第 $\ell$ 层普通 B-spline 基函数记为：

$B_i^\ell$

若：

$\operatorname{supp}(B_i^\ell)\subset \Omega^\ell$

说明这个基函数属于第 (\ell) 层允许工作的区域。

但如果进一步有：

$\operatorname{supp}(B_i^\ell)\subset \Omega^{\ell+1}$

说明它整个支撑都落在更细层区域里。

这时它应该被细层基函数替代，所以不应作为 active basis 保留。

因此第 (\ell) 层 active basis 是：

$$\mathcal H^\ell={
B_i^\ell:
\operatorname{supp}(B_i^\ell)\subset \Omega^\ell,
\quad
\operatorname{supp}(B_i^\ell)\not\subset \Omega^{\ell+1}}$$

含义是：

$\boxed{
\text{第 }\ell\text{ 层基函数只在没有被更细层完全接管的地方保留。}
}$

最细层 (L) 没有下一层，所以可定义：

$\Omega^{L+1}=\varnothing$

于是：

$$\mathcal H^L={B_i^L:
\operatorname{supp}(B_i^L)\subset \Omega^L}$$
最细层基函数直接保留。

------

# 4. 截断公式重新解释

粗层基函数可以由细层基函数线性表示：

$B_i^\ell=\sum_j c_{ij}^{\ell+1}B_j^{\ell+1}$

这叫 refinement relation。

现在第 $\ell+1$层的细化区域是：

$\Omega^{\ell+1}$

那么单步截断定义为：

$$\operatorname{trunc}^{\ell+1}(B_i^\ell)=\sum_{\operatorname{supp}(B_j^{\ell+1})\not\subset \Omega^{\ell+1}}
c_{ij}^{\ell+1}B_j^{\ell+1}$$

也就是说，先把粗基函数 (B_i^\ell) 展开成细层基函数：

$B_i^\ell=\sum_j c_{ij}^{\ell+1}B_j^{\ell+1}$

然后删除那些满足：

$\operatorname{supp}(B_j^{\ell+1})\subset \Omega^{\ell+1}$

的细层成分。

这些被删除的细层成分，正好落在被细化区域内部。

所以含义是：

$\boxed{
\text{粗基函数在细化区域内部的贡献被削掉，由细层 active basis 接管。}
}$

不是删除整个粗基函数，而是删除它在细化区域内可由细层基函数表示的那一部分。

------

# 5. 你的“从 max depth 往上截断”的理解基本正确，但要加三个限定

你说：

> 截断过程应该是先固定 max_depth 层的最细基函数，然后对 max_depth-1 层的基函数截断，依次类推。

这个理解作为实现直觉是可以的，但要改成：

$\boxed{
\text{先确定最细层 active basis，然后对更粗层 active basis 逐层向细层递归截断。}
}$

三个限定如下。

------

## 5.1 不是固定 max depth 的所有基函数

不是把第 $L$ 层全局均匀网格上的所有基函数都固定。

而是只选：

$$\mathcal H^L = {B_i^L:
\operatorname{supp}(B_i^L)\subset \Omega^L} $$

也就是只选最细细化区域里的 active basis。

否则会退化成全局细网格，失去自适应意义。

------

## 5.2 第 $L-1$层只对落入 $\Omega^L$ 的成分截断

对某个：

$B_i^{L-1}$

先写成第 (L) 层基函数：

$B_i^{L-1}=\sum_j c_{ij}^{L}B_j^{L}$

然后删除：

$\operatorname{supp}(B_j^L)\subset\Omega^L$

的成分。

得到：

$$ T(B_i^{L-1})=\sum_{\operatorname{supp}(B_j^L)\not\subset\Omega^L}
c_{ij}^{L}B_j^L$$

意思是：

$\text{第 }L\text{ 层细化区域内部不再由 }B_i^{L-1}\text{ 负责。}$

------

## 5.3 更粗层要递归经过所有更细层

对第 (\ell) 层基函数：

$B_i^\ell$

不是只截断一次，而是递归截断：

$$ T(B_i^\ell)=\operatorname{trunc}^{L}
\circ
\operatorname{trunc}^{L-1}
\circ
\cdots
\circ
\operatorname{trunc}^{\ell+1}
(B_i^\ell)$$

例如对第 (L-2) 层基函数，要先相对于 $\Omega^{L-1}$截断，再相对于 $\Omega^{L}$截断。

所以：

$$B_i^{L-2}
\rightarrow
\operatorname{trunc}^{L-1}(B_i^{L-2})
\rightarrow
\operatorname{trunc}^{L}\left(
\operatorname{trunc}^{L-1}(B_i^{L-2})
\right)$$

最终得到：

$T(B_i^{L-2})$

------

# 6. 一个简单的一维示意

为了避免三维八叉树太抽象，先看一维。

假设：

$\Omega^0=[0,1]$

其中中间区域被细化：


$\Omega^1=[0.25,0.75]$

粗层基函数为：

$B_i^0$

细层基函数为：

$B_j^1$

粗层基函数可以写成细层基函数组合：

$B_i^0=\sum_j c_{ij}B_j^1$

如果某些细层基函数满足：

$\operatorname{supp}(B_j^1)\subset[0.25,0.75]$

这些成分就被删除。

于是：

$$ \operatorname{trunc}^{1}(B_i^0)=\sum_{\operatorname{supp}(B_j^1)\not\subset[0.25,0.75]}
c_{ij}B_j^1$$

也就是：

$B_i^0$在中间细化区域内部的贡献被切掉，留下靠近未细化区域和过渡区的部分。

中间区域由第 1 层细基函数负责。

------

# 7. 为什么这样能保持单位分解性？

普通均匀 B-spline 满足：

$\sum_i B_i^\ell(x)=1$

但层次细化后，如果粗层基函数不截断，会出现：

$$\sum_{\text{粗层 active}}B_i^\ell(x)
+
\sum_{\text{细层 active}}B_j^{\ell+1}(x)>1$$

因为粗层和细层在细化区域重复覆盖。

截断之后，粗层在细化区域内部的贡献被删除：

$\operatorname{trunc}^{\ell+1}(B_i^\ell)$

只留下没有被细层完全接管的部分。

因此总和重新满足：

$\sum_{B\in\mathcal T}B(x)=1$

其中：

 $$ \mathcal T={T(B):B\in\mathcal H}$$

这就是 THB-spline 的核心意义。

------

# 8. 对八叉树情形的对应关系

在三维八叉树中：

$\Omega^\ell$

可以理解为：

$$\Omega^\ell=\bigcup_{\text{深度}\geq \ell\text{ 的区域}}K$$

也就是所有被细化到第 $\ell$层或更深层的空间区域的并集。

叶子节点深度可能不同，例如：

$d=4,5,6,7$

那么：

$\Omega^4$

包含所有深度至少为 4 的区域。

$\Omega^5$

包含所有继续细化到 5 层及更深的区域。

$\Omega^6$

包含所有继续细化到 6 层及更深的区域。

$\Omega^7$

包含最细化到第 7 层的区域。

所以对一个第 4 层基函数 $B_i^4$，如果它部分覆盖了第 5、6、7 层细化区域，那么它需要递归截断：

$$ T(B_i^4)=
\operatorname{trunc}^{7}
\operatorname{trunc}^{6}
\operatorname{trunc}^{5}
(B_i^4)$$

含义是：

$\text{它在第 5 层细化区内让出一部分；在第 6 层细化区内继续让出；在第 7 层细化区内再让出。}$

------

# 9. 你可以采用的准确表述

你原来的理解可以改写成下面这一版：

> 对于一个已经 balanced 的八叉树，先由八叉树定义一组嵌套细化区域 $\Omega^0\supseteq\Omega^1\supseteq\cdots\supseteq\Omega^L$ 其中 (\Omega^\ell) 表示需要由第 $\ell$ 层或更细层表示的区域。然后在每一层上选择 active basis： $$ \mathcal H^\ell{B_i^\ell:
>\operatorname{supp}(B_i^\ell)\subset\Omega^\ell,
> \operatorname{supp}(B_i^\ell)\not\subset\Omega^{\ell+1}}$$
> 对这些 active basis 中的粗层基函数，利用 refinement relation 展开到下一层，并删除支撑完全落在下一层细化区域 $\Omega^{\ell+1}$内的细层成分。该操作递归进行直到最大深度 $L$。最细层 active basis 不再截断。这样得到的 truncated hierarchical basis 保持单位分解性，并避免粗层和细层在细化区域重复贡献。

这个表述是对的。

------

# 10. 最后再强调一个容易混淆的点
$$
\Omega^{\ell+1}
\neq
\bigcup_j\operatorname{supp}(B_j^{\ell+1})
$$

它不是所有第 $\ell+1$ 层基函数支撑的并集。

而是：

$$ \boxed{ \Omega^{\ell+1}=\text{由八叉树细化结构决定的第 }\ell+1\text{ 层细化区域}
}$$

只有那些满足：

$\operatorname{supp}(B_j^{\ell+1})\subset\Omega^{\ell+1}$

的第 $\ell+1$ 层基函数成分，才会在截断粗基函数时被删除。

如果一个细层基函数只是部分进入 (\Omega^{\ell+1})，即：

$\operatorname{supp}(B_j^{\ell+1})\cap\Omega^{\ell+1}\neq\varnothing$

但：

$\operatorname{supp}(B_j^{\ell+1})\not\subset\Omega^{\ell+1}$

那么它通常不会被删掉，因为它跨越了粗细过渡区，需要保留来维持连续性和单位分解性。
