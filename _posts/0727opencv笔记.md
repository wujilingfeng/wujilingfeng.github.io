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