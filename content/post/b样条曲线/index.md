+++
author = 'libo'
date = '2026-01-24T11:45:01+08:00'
math= true
draft = false
title = 'B样条曲线'
image = "wuyun.png"
+++

b样条曲线的卷积连续形式推导（下面的$B_0$ 默认都是定义在初始区间的）:

$ B_0\left(x\right)=1 ,0\le x \le 1 $

$B_d(x)=\int B_{d-1}\left(y\right)B_0\left(x-y\right)dy=\int_{x-1}^{x}B_{d-1}\left(y\right)B_0\left(x-y\right)dy$

$B_d\left(x\right)=\int_{x-1}^{x}B_{d-1}\left(y\right)dy=\int_{x-1}^{0}B_{d-1}\left(y\right)dy + \int_{0}^{x}B_{d-1}\left(y\right)dy$

$=\int_{x}^{1}B_{d-1}^{i+1}\left(y\right)dy + \int_{0}^{x}B_{d-1}^{i}\left(y\right)dy$

b样条曲线不同阶的基函数递推公式：

![b样条](b.png)

在信号处理和数学中，**门函数**（通常也称为矩形函数）是构建各种复杂信号的基础。为了给出最通用且严谨的公式，我们先定义基础门函数，然后再推导二次和三次卷积。

### 1. 基础门函数定义

假设门函数的高度为 $A$，宽度为 $T$，且关于原点对称，其公式为 $g_1(t)$：
$
g_1(t) = A \cdot \text{rect}\left(\frac{t}{T}\right) = 
\begin{cases} 
A, & |t| \le \frac{T}{2} \\ 
0, & \text{其他} 
\end{cases}
$

*(注：如果你使用的是单位门函数，只需在后续公式中令 $A=1, T=1$ 即可)*

---

### 2. 门函数的二次卷积 $g_2(t)$

门函数与自身卷积一次，会得到一个**三角形函数**。其底边宽度会翻倍变成 $2T$，峰值为原来面积 $A \times T$ 乘以 $A$，即 $A^2 T$。
$
g_2(t) = g_1(t) * g_1(t) = 
\begin{cases} 
A^2 (t + T), & -T \le t \le 0 \\ 
A^2 (-t + T), & 0 < t \le T \\ 
0, & \text{其他} 
\end{cases}
$
**用标准三角形函数表示为：**
$ g_2(t) = A^2 T \cdot \Lambda\left(\frac{t}{T}\right) $
*(其中 $\Lambda(x) = \max(1 - |x|, 0)$ 是标准三角形函数)*

---

### 3. 门函数的三次卷积 $g_3(t)$

门函数与自身卷积两次（即三角形函数再与门函数卷积），会得到一个**分段二次函数**（二次样条曲线）。这是图像处理中“三次卷积插值”的核心基底函数。
其底边宽度变为 $3T$（从 $-1.5T$ 到 $1.5T$），峰值为 $g_2$ 的峰值面积乘以 $A$，即 $\frac{3}{4} A^3 T^2$。
$
g_3(t) = g_2(t) * g_1(t) = 
\begin{cases} 
A^3 \left( \frac{1}{2}t^2 + \frac{3}{2}Tt + \frac{9}{8}T^2 \right), & -\frac{3T}{2} \le t \le -\frac{T}{2} \\ 
A^3 \left( -t^2 + \frac{3}{4}T^2 \right), & -\frac{T}{2} < t \le \frac{T}{2} \\ 
A^3 \left( \frac{1}{2}t^2 - \frac{3}{2}Tt + \frac{9}{8}T^2 \right), & \frac{T}{2} < t \le \frac{3T}{2} \\ 
0, & \text{其他} 
\end{cases}
$

---

### 💡 补充：如果你需要的是“单位门函数” ($A=1, T=1$)

很多教材直接使用宽度为2（从-1到1）的单位门函数 $rect(t)$，此时公式会大大简化：
**一次（原函数）：**
$ g_1(t) = \begin{cases} 1, & |t| \le 1 \\ 0, & \text{其他} \end{cases} $
**二次卷积：**
$ g_2(t) = \begin{cases} t + 1, & -1 \le t \le 0 \\ -t + 1, & 0 < t \le 1 \\ 0, & \text{其他} \end{cases} $
**三次卷积：**
$
g_3(t) = 
\begin{cases} 
\frac{1}{2}t^2 + \frac{3}{2}t + \frac{9}{8}, & -\frac{3}{2} \le t \le -\frac{1}{2} \\ 
-t^2 + \frac{3}{4}, & -\frac{1}{2} < t \le \frac{1}{2} \\ 
\frac{1}{2}t^2 - \frac{3}{2}t + \frac{9}{8}, & \frac{1}{2} < t \le \frac{3}{2} \\ 
0, & \text{其他} 
\end{cases}
$

### 🔍 规律与性质总结

1. **平滑性递增**：门函数（0阶导数连续） $\rightarrow$ 二次卷积（1阶导数连续，呈三角尖峰） $\rightarrow$ 三次卷积（2阶导数连续，呈光滑钟形）。
2. **支撑区间**：每次卷积，非零区间的宽度都会增加一个原门函数的宽度 $T$。
3. **逼近高斯函数**：根据中心极限定理，如果无限次地将门函数与自身卷积，其波形最终会趋近于完美的**高斯函数（正态分布曲线）**。三次卷积已经是高斯函数的一个相当不错的近似。
