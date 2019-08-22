---
title: opencv笔记
tags: 算法
categories: 学习笔记
date: 2019-07-27 21:42:00
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});
</script>
<script type="text/javascript" async
  src="https://wujilingfeng.top/MathJax/MathJax.js?config=TeX-AMS_CHTML">
</script>
opencv笔记


<!--more-->

读取并显示一张图片

```python
import cv2 as cv
src=cv.imread('E:\imageload\example.png')       
cv.namedWindow('input_image', cv.WINDOW_AUTOSIZE)
cv.imshow('input_image', src)
cv.waitKey(0)
cv.destroyAllWindows()
```

这与matplotlib.img显示图片所用函数大概是一样的

| 函数名                     | 参数意义                             | 备注 |
| -------------------------- | ------------------------------------ | ---- |
| cv.imread("",-1\|\|0\|\|1) | -1代表自动，0代表灰度，1代表三个通道 |      |
|                            |                                      |      |
|                            |                                      |      |
|                            |                                      |      |
|                            |                                      |      |
|                            |                                      |      |
|                            |                                      |      |
|                            |                                      |      |
|                            |                                      |      |

对数变化，对每个像素点的值v,$v\to v^\gamma$

直方图均衡化

我们想要一个映射$v\to f(v)$v是像素值，f(v)也是像素值，
* 它是保测度的(测度是这个像素值上的像素数目,用h(v)表示)，
* 我们还要求$\overline{h}\left(f\left(v\right)\right)==\frac{num\_p}{max\_v}$,  ($\overline(h())$是f(v)上的测度，num_p是像素总数，max_v是像素值的最大值)

那么这两个条件可以写成
$\int_{0}^{v}h\left(v\right)dv=\int_{0}^{f\left(v\right)}\overline{h}\left(f\left(v\right)\right)df\left(v\right)$
$\sum h\left(v_i\right)=\frac{num\\_p}{max\\_v}*f\left(v\right)$
$f\left(v\right)=\frac{max\_v}{num\_p}\sum h\left(v_i\right)$