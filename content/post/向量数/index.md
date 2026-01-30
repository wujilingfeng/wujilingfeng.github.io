+++
author = 'libo'
date = '2026-01-29T09:25:51+08:00'
math= true
draft = false
title = '向量数'
image = 'yangtai.png'
+++

下面介绍一种向量进制的数据表示方式。比如N向量数，设集合为$B$是自然数的集合，那么N向量空间设为$C=B .. \times B$,也就是C中元素表示为$\left(t_0.. t_{N-1}\right) \in C$,  那么M深度的N向量数表示$D={s_0..s_m}$  其中$s_l\in C$，

。 

对于任意的M深度N向量数$d\in D,d=s_0..s_m$都有$0..0s_0..s_m$,其中0表示$\left(0,0,0 \right)$, 和d都不相等，因为表示的深度不一样。

现在定义进制的等价关系，对于给定的正整数P。 

对于 $d\in D,d=s_0..s_m$，都有$d=s_0..\alpha_i\left(s_{l+1}\right)\beta_i\left(s_l\right)..s_m$, 其中$\alpha_i$表示对向量的第i个分量加1，$\beta_i$表示对向量的第i个分量减P。

满足上面定义的等价关系叫M深度N向量P进制数。

八叉树的节点和根节点的关系（或者路径）都可以用3向量2进制数表示，它的邻接关系也一目了然。

在zig语言中直接用`ArrayList([3]u1)`表示。

这样我完全不用像传统方式表示八叉树，也就是有parent和children指针，我完全可以申请一块内存即可,`const Oc_Node=struct{ArrayList([3]u1),isize};constr Octree=struct{octree:ArrayList(Oc_Node),octree_prop:ArrayList(T)}`,其中usize是指向Octree_Prop的索引，如果没有属性值，置为-1。

一般为了提高效率，节省内存，令`const Oc_Node=struct{[M][3]u1,isize}`;

如果要计算M深度N向量的id，可以按照P进制进行排列计算数值，但是该数值对于同一层深度的向量数具有唯一性，不同深度时id可能重复，因为上述表示法对于$0s$和$s$不具有唯一性。

如果想让M深度N向量数在不同深度都有唯一id表示，可以在上述表示法基础上加上,$TotalNodes(M-1) = 1 + P^N + (P^N)^2 + ... + (P^N)^(M-1)$
