---
title: pytorch教程
tags: 数学
categories: 学习笔记
date: 2019-09-10 13:47:55
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});
</script>
<script type="text/javascript" async
  src="https://wujilingfeng.top/MathJax/MathJax.js?config=TeX-AMS_CHTML">
</script>

pytorch学习笔记

<!--more-->

因为反向传播或者自动求导需要引用函数，所以每个函数不能重复作用，所以最好使用如下方式

`nn.Relu()(a)`,这样可以保证函数最多使用一次,尤其是Function类

### Pytorch

| 函数                               | 意义                                                         |
| ---------------------------------- | ------------------------------------------------------------ |
| torch.from_numpy()                 | 传入一个numpy对象，返回torch的tensor                         |
| tensor_obj.numpy()                 | 将torch的tensor转化为numpy对象，并返回                       |
| tensor_obj.matmul(tensor_obj1)     | tensor_obj和tensor_obj1的张量乘法（torch.mm只能是矩阵）(最后两个维度) |
| torch.nn.Conv1d()                  | 返回1维卷积算子                                              |
| tensor_obj.permute()               | 类似numpy的transpose                                         |
| torch.nn.Conv1d(m,n,p)             | inchannel=m,outchannel=n,卷积p个元素                         |
| torch.nn.Conv2d(m,n,(p,q))         | inchannel=m,outchannel=n,卷积是(p,q)                         |
| tensor_name.grad_fn                | 生成此张量的函数(引用此函数)                                 |
| tensor_name.grad                   | 某函数对此张量的梯度                                         |
| tensor_name.view()                 | 和numpy的reshape一样，（为什么函数名不用reshape?增加学习成本） |
| tensor_name.float()                | 相当于astype,例如image=image.float()                         |
| tensor_name.grad.data.zero_()      | 梯度清零                                                     |
| .register_buffer                   | 被设置的量不会被trained(修改)                                |
| torch.zeros(3,3),torch.ones(3,4,5) | 构造3*3的0矩阵,1张量。torch也可以换成numpy                   |
| tensor_name.norm()                 | 返回模长                                                     |
| tensor_name**2                     | 元素的平方                                                   |
| tensor.name.sum()                  | 元素求和                                                     |
|                                    |                                                              |
|                                    |                                                              |
*支持对于高维的Tensor（dim>2），定义其矩阵乘法仅在最后的两个维度上，要求前面的维度必须保持一致，就像矩阵的索引一样并且运算操只有torch.matmul()。*

[pytorchtest1.py](./pytorchtest1.py)展示了卷积的操作，通过查看卷积的参数可以知道：卷积有bias项

[backward()参数含义](https://www.cnblogs.com/JeasonIsCoding/p/10164948.html)

机器学习最重要的是反向传播和框架，机器学习神经元图从左到右违反矩阵乘法，导致torch.nn.Linear()与矩阵乘法向左

[nn.CrossEntropyLoss](https://blog.csdn.net/tmk_01/article/details/80839810)
[nn.MSELoss](https://blog.csdn.net/hao5335156/article/details/81029791)

参数的[初始化](https://blog.csdn.net/qq_36338754/article/details/97756378)

#### opencl安装

* 安装nvidia驱动，cuda
* 安装opencl

[禁用nouveau](https://blog.csdn.net/qq805934132/article/details/82909759)

在命令行(init 3)安装nvidia驱动（为了禁用x-window）

sudo ubuntu-drivers autoinstall

接下来安装cuda

官网下载.run文件

https://blog.csdn.net/jsjason1/article/details/88087414

https://www.cnblogs.com/vactor/p/9286425.html

openCL.so 和CL.h都在cuda里，

gcc opencl_hello.c -L /usr/local/cuda-10.1/lib64/ -lOpenCL

配置好cuda后pytorch就可以使用gpu了