+++
author = 'libo'
date = '2026-01-24T11:45:01+08:00'
math= true
draft = false
title = 'B样条曲线'
image = "wuyun.png"
+++

b样条曲线的连续形式推导:

$B_0\left(x\right)=1 ,0\le x \le 1$

$B_d(x)=\int B_{d-1}\left(y\right)B_0\left(x-y\right)dy=\int_{x-1}^{x}B_{d-1}\left(y\right)B_0\left(x-y\right)dy$

$B_d\left(x\right)=\int_{x-1}^{x}B_{d-1}\left(y\right)dy=\int_{x-1}^{0}B_{d-1}\left(y\right)dy + \int_{0}^{x}B_{d-1}\left(y\right)dy$

$=\int_{x}^{1}B_{d-1}^{i+1}\left(y\right)dy + \int_{0}^{x}B_{d-1}^{i}\left(y\right)dy$

b样条曲线不同阶的基函数递推公式：

![b样条](b.png)
