+++
author = 'libo'
date = '2026-05-12T23:35:57+08:00'
math= true
draft = false
title = 'Qem算法'
+++

qem在merge边为点时,创建的一组三角形可能出现折叠.先统计并维护其中出现折叠的边, 然后通过折耳朵多边形来减少折叠的边.

注意每次折耳朵会消失两个边,创建一个边.对于新创建的边要判断是否和merge的顶点折叠.如果折叠就加入维护的容器.知道容器清空.

网格简化中的 **QEM（Quadric Error Metrics，二次误差度量）** 算法由 Garland & Heckbert 于 1997 年提出。你提到的“拟合点”和“能量更新”正是该算法的数学核心。下面从原理到实现逐步拆解：

---

### 🔷 一、拟合点（最优收缩目标点）是如何计算的？

#### 1. 平面距离的二次型表示

对于三角形面片所在的平面方程 $ax + by + cz + d = 0$，设法向量已单位化（$a^2+b^2+c^2=1$），记平面参数向量为 $\mathbf{p} = [a, b, c, d]^\top$。  
齐次坐标下的点 $\mathbf{v} = [x, y, z, 1]^\top$ 到该平面的**有符号距离**为 $\mathbf{p}^\top \mathbf{v}$，**距离平方**为：
$$
(\mathbf{p}^\top \mathbf{v})^2 = \mathbf{v}^\top (\mathbf{p}\mathbf{p}^\top) \mathbf{v}
$$
定义该平面的**基础二次型矩阵**为 $K_\mathbf{p} = \mathbf{p}\mathbf{p}^\top$（$4\times4$ 对称半正定矩阵）。

#### 2. 顶点的 Quadric 矩阵

对每个顶点 $v$，将其所有相邻面片的 $K_\mathbf{p}$ 累加：
$$
Q_v = \sum_{f \in \text{adj}(v)} K_{\mathbf{p}_f}
$$
$Q_v$ 隐含了该顶点周围局部几何的“平面约束集合”。

#### 3. 边收缩的最优目标点

当收缩边 $(v_1, v_2)$ 时，新顶点 $\bar{v}$ 的 Quadric 矩阵为：
$$
Q = Q_{v_1} + Q_{v_2}
$$
收缩代价（即“能量”）定义为 $\bar{v}$ 到所有相关平面距离平方和：
$$
E(\bar{v}) = \bar{v}^\top Q \bar{v}
$$
将 $Q$ 分块为：
$$
Q = \begin{bmatrix}
A & \mathbf{b} \\
\mathbf{b}^\top & c
\end{bmatrix}, \quad
\bar{v} = \begin{bmatrix} \mathbf{x} \\ 1 \end{bmatrix}, \quad \mathbf{x}=[x,y,z]^\top
$$
代入得标量函数：
$$
E(\mathbf{x}) = \mathbf{x}^\top A \mathbf{x} + 2\mathbf{b}^\top \mathbf{x} + c
$$
对 $\mathbf{x}$ 求梯度并令为零：
$$
\nabla E = 2A\mathbf{x} + 2\mathbf{b} = 0 \quad \Rightarrow \quad A\mathbf{x} = -\mathbf{b}
$$
✅ **这就是你提到的最小二乘问题**：  
$A\mathbf{x} = -\mathbf{b}$ 实际上是超定平面方程组 $\mathbf{p}_i^\top \mathbf{v} \approx 0$ 的**正规方程（Normal Equations）**。求解该 $3\times3$ 线性系统即可得到使距离平方和最小的最优位置 $\mathbf{x}^*$。

#### 4. 奇异情况处理

- 若 $A$ 可逆：$\mathbf{x}^* = -A^{-1}\mathbf{b}$
- 若 $A$ 奇异（如共面区域、退化网格）：原论文采用回退策略，比较 $\{v_1, v_2, \frac{v_1+v_2}{2}\}$ 三者的 $E(\cdot)$，取最小者作为收缩目标。工程中也常用 SVD 或 Moore-Penrose 伪逆。

---

### 🔷 二、“能量”是如何更新的？

QEM 中**没有独立存储的“能量标量”**，能量完全由 $Q$ 矩阵隐式定义。更新机制的核心是 **矩阵的可加性**：

#### 1. 初始化

- 遍历所有面片，计算 $K_\mathbf{p}$，累加到三个顶点的 $Q_v$。
- 对每条边 $(v_i, v_j)$，计算 $Q_{ij} = Q_{v_i} + Q_{v_j}$，求解最优 $\bar{v}$ 并计算代价 $E = \bar{v}^\top Q_{ij} \bar{v}$。
- 将所有边按代价插入最小堆（优先队列）。

#### 2. 边收缩时的更新

当弹出代价最小的边 $(v_1, v_2) \to \bar{v}$ 时：

1. **矩阵相加**：$Q_{\bar{v}} = Q_{v_1} + Q_{v_2}$（$O(1)$ 操作，仅 10 个独立元素相加）
2. **拓扑更新**：删除 $v_1, v_2$ 及其关联面/边，将邻接点全部重连到 $\bar{v}$
3. **邻边代价刷新**：对 $\bar{v}$ 的每条新邻边 $(\bar{v}, u)$：
   - 计算 $Q_{\text{new}} = Q_{\bar{v}} + Q_u$
   - 重新求解 $A\mathbf{x}=-\mathbf{b}$ 得新目标点
   - 计算新代价 $E = \bar{v}_{\text{opt}}^\top Q_{\text{new}} \bar{v}_{\text{opt}}$
   - 更新优先队列中的对应边（删除旧条目，插入新条目）

✅ **关键点**：  

- “能量更新”本质是 **$Q$ 矩阵的累加 + 局部重新求解最小二乘**。  
- 由于 $Q$ 矩阵具有可加性，无需重新遍历面片，每次收缩仅需更新一阶邻域，复杂度极低。

---

### 🔷 三、工程实现注意事项

| 问题      | 常见处理方案                                                  |
| ------- | ------------------------------------------------------- |
| 数值稳定性   | $A$ 条件数大时加微小正则项 $\epsilon I$，或用 LDLT/Cholesky 分解        |
| 边界保护    | 边界边赋予极大权重，或单独维护边界顶点 $Q$ 矩阵                              |
| 面积/曲率加权 | $K_\mathbf{p}$ 累加时乘面片面积或曲率估计值                           |
| 法向翻转检测  | 收缩后检查邻面法向一致性，若翻转则拒绝该收缩                                  |
| 优先队列更新  | 使用 `std::priority_queue` 需惰性删除；推荐 `boost::heap` 或手写可更新堆 |

---

### 📚 原始文献与参考实现

- Garland, M., & Heckbert, P. S. (1997). *Surface Simplification Using Quadric Error Metrics*. SIGGRAPH.
- 开源实现参考：`libigl::decimate`、`OpenMesh::Mod_QEM`、`MeshLab` 的 Quadric Edge Collapse Decimation
- 数学细节推导可参见：[QEM 详细笔记（含代码）](https://www.cs.cmu.edu/~garland/Papers/quadrics.pdf)

若你需要具体代码片段（如 $3\times3$ 系统求解、优先队列更新逻辑、或奇异回退实现），可告知使用语言（C++/Python），我可直接给出可运行示例。
