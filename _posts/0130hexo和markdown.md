---
title: hexo和markdown学习
date: 2019-01-30 19:32:56
tags: [代码, 博客]
categories: 计算机
---

本文介绍hexo及其配置和意义

<!--more-->

不管是hexo和markdown语法，在关键词（语法词）后都要有个空格，以免出错。

#### hexo

---

hexo是一个博客框架，具体的我没有足够的知识介绍。

---

#### hexo的配置

---

关于hexo文件夹下_config.yml的配置[官网](https://hexo.io/zh-cn/docs/configuration.html)有非常好的解释（其他博客均无创新之处，拾人牙慧）。

---

#### hexo命令

---

``` bash
hexo init#如同git init，将某文件夹搭建好框架
hexo d
hexo g
hexo s
hexo clean
```

---

#### markdown

---

markdown应为写博客的一种脚本语言，兼容html语言。markdown简便功能并不完整，html功能完善却不易书写文章，具体语法见[这里](http://www.markdown.cn/)，因为语言简便，并无难处。

---

如果要引用图片，建议在*_config.yml*将new_post_name设置为true,把源图片放到*source/_posts/生成的同名文件夹*下，引用时采用如下格式

*\{  %  asset_img 图片名 标题 %\}*。

---

markdown自动转换网址为超链接，如果你想让网址以文本形式出现, \` ... \` 将网址替换...即可。

#### 关于公式问题

---

可以使用mathjax引擎渲染公式，只需要在网页加入一句(参考[官网](https://docs.mathjax.org/en/latest/start.html))
```
<script type="text/x-mathjax-config">
  MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});
</script>
<script type="text/javascript" async
  src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/latest.js?config=TeX-AMS_CHTML">
</script>
```

便可以时的网页支持latex公式。但是这样网页需要访问cdn.amthjax.org服务器，会有缓慢情况，建议将mathjax下载到服务器，再将`cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/latest.js` 替换为`服务器/MathJax/MathJax.js`

行内公式默认时`\\( ...\\)` ...换成你的latex。

此时网页还会访问google获取ajax库,网页加载缓慢(被墙)。

你需要修改主题目录下source/css/_bass/variables.styl,注释掉@import url("//fonts.googleapis.com/css?family=Open+Sans:400,700");

再修改主题目录下`layout\ _partial\after_footer.ejs` ,将`<script src="//ajax.googleapis.com/ajax/libs/jquery/2.0.3/jquery.min.js"></script>`替换为

`<script src="//lib.sinaapp.com/js/jquery/1.8.3/jquery.min.js"></script>`

#### latex语法

---

见[这里](http://www.mohu.org/info/symbols/symbols.htm)