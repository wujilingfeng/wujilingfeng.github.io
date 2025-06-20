+++
author = 'libo'
date = '2025-06-20T10:36:14+08:00'
draft = false
title = 'Zig实战'

image = "nature.png"

+++







如果zig语言想要实现类型类，只需要写个满足类型类约束的comptime函数，也就是在编译期进行类型检查是否有某些方法的判断，然后在需要添加类型类约束的函数上添加这个编译期函数判断即可。



