---
title: python笔记
tags: 计算机
categories: 学习笔记
date: 2019-04-11 22:01:36
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});
</script>
<script type="text/javascript" async
  src="https://wujilingfeng.top/MathJax/MathJax.js?config=TeX-AMS_CHTML">
</script>


本文记录python学习笔记

<!--more-->

\__init\__.py使文件夹可被import，比如[这里](https://www.cnblogs.com/BlueSkyyj/p/9415087.html)

python是脚本语言，所以支持一行一运行。

python单双引号，三引号都可以使用，[具体区别](<https://blog.csdn.net/woainishifu/article/details/76105667>)

.py文件可以用`python test.py`或者`python3 test.py`

[这里](https://blog.csdn.net/gordennizaicunzai/article/details/87905618)介绍了python读取二进制文件的方法

| 例子      | 解释                                  |
| --------- | ------------------------------------- |
| a*b       | a乘b                                  |
| a**b      | a的b次方                              |
| a%b       | a取余b                                |
| a/b       | a除b                                  |
| a//b      | a整除b                                |
| ‘f'*3     | 结果是'fff'(字符串也可以做乘法和加法) |
| "df"+"ab" | 结果是"dfab"                          |
|           |                                       |
|           |                                       |



---

[python教程](<http://www.runoob.com/python3/python3-data-type.html>)

`python -m pip install numpy`安装numpy
pip3 install package -i url#url是你要用的镜像地址

`python -m pip install matplotlib`在termux下，可能出现ft2build.h找不到的情况，它在/usr/include/freetype2文件夹下，将这个文件夹下的内容拷贝到/usr/include里
[切片操作](https://www.jianshu.com/p/15715d6f4dad)

实际上切片经常用于改变数组的形状，顺序

#### numpy

对数组进行for .. in .. 循环实际上对行遍历

```python
for i in np.random.randn(3,4):
	print(i,end="libo")
```

对数组进行条件筛选

```python
a=np.random.randd(3,4)
print(a>0)
```

这时输出的是`array([[True...],[False..],[],[]])`

接着上面继续

```python
a[a>0]
```

这时候完成的筛选

对于数组的拼接

```python
np.concatenate(a,b,axis=0)
```

按行(axis=0)拼接

#### 函数

python函数的变量都是是引用，但是对于数字改变时，地址也改变。效果等价于对于函数数字变量是传值。

比如下面的程序展示了python从头到尾的引用

```python
class Student():
    def __init__(self,name):
        self.name=name;
    def get_name(self):
        print(self.name);
def test(stu):
    stu.get_name();
    return stu;

a=Student("libo")
a.get_name()
b=test(a)

print("a:",id(a),id(b))
```



```python
while True:
    str=sys.stdin.readline()
    if not str:#判断eof
        print("not line")
        break;
    if str=='\n':#判断换行
        print(" kong")

```
上面显示了python读取输入的模板(如果是读取文件只需要前面换成`with open("") as f:`,`for l in f.readlines()`)

```python
a=map(int,input().split());
b=list(a)
```
上面显示了python读取一行整数(b代表这一行整数的列表)
函数内部要引用外部变量，需要用global关键字

```python3
a=[0 for i in range(4)]#等价int a[4]
```

python next()迭代器的使用

```python
for it in v_it:
	
```



|函数名|解释|
| ---| ---|
|range()|返回数字序列列表(与numpy的arange相同)|
|np.arange(1,11,1)|返回向量1到11,步长1|
|np.array([1,2,3],dtype=complex)||
|np.random.rand(2,100)|返回2*100随机矩阵|
|os.path.dirname()|返回去掉文件名的路径|
|os.path.abspath()|返回绝对路径(文件名加当前路径)|
|sys.argv[0]|向python脚本传递变量|
|str()|转化为字符串|
|np_obj.transepose(1,0)|将0数轴，1数轴转置|
|np_obj.reshape()|重塑形状，包括(一维向量)转置功能|
|np.tensordot(a,b,axes=([1,0],[0,1]))|a的第1轴元素，和b的第0轴作用，a的第0轴和b的第1轴作用|
|super(class,obj)|调用父类成员|
|for i in rang(0,5)|等价for(int i=0;i<5;i++)（range也可以换成xrange）|
|sys.stdin.read(1)|等价scanf("%c",)|
|sys.stdin.readline()|读取一行字符以"\n"结尾|
|input()|读取一行字符串|
|np.ones((2,3)),np.zeros((3,5)),np.eye(4,6)|np换成torch也可以|
| ord() | 返回一个字符的ACSI码 |
|nump_obj.size numpy_obj.shape | 头一个返回元素个数 |
| np_obj.astype(int)| numpy转化为int形,例如image=image.astype(np.float32) |
| np.append(a,b,axis=0) | 张量的行拼接 |
| |  |
| |  |
| |  |
| |  |
##### 类

[python的类](https://www.runoob.com/python3/python3-class.html)

`if __name__=="__main__":`

语句是文件当作脚本和模块运行的区别,python脚本文件的`__file__`代表该文件命

三种信息标记形式:xml,json,yaml

id()用来获取对象的内存,is比较的内存地址（id()函数返回的值），==比较的是值

三种信息标记形式:xml,json,yaml

如下代码展示读取一张图片并显示
```python
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import numpy as np
lena=mpimg.imread('lena.png')
lena.shape
plt.imshow(lena)
plt.axis('off')
plt.show()
```
|method|meaning|
| --- | ---|
| \_\_init\_\_ | 构造函数 |
| \_\_del\_\_ | 析构函数 |
| \_\_sub\_\_ | 减法重载 |
| \_\_add\_\_ | 加法重载 |
| \_\_mul\_\_ | 乘法重载 |
| | |
[给个链接](https://blog.csdn.net/cn_wk/article/details/76939870)

#### c为python做模块

以下几个连接

https://www.cnblogs.com/pyse/p/8590829.html

https://www.cnblogs.com/xudong-bupt/p/7025728.html

https://www.cnblogs.com/yanzi-meng/p/8066944.html

##### 方法一
`gcc -fPIC -shared fun_name.c -o libfunc_name.so`
把c代码打包
然后在.py文件中import ctypes
```python
from ctypes import cdll
import os

p = os.getcwd() + '/libfunc.so'
f = cdll.LoadLibrary(p)
print f.func(99)
```
##### 方法二
如下方法只需要把源文件(.c或者.cpp)文件包裹，但是需要在setup.py中给出头文件的include_dir变量
[py_test1.h](./py_test1.h),[py_test1.c](./py_test1.c)
py_test1wrapper.c
```c
#define PY_SSIZE_T_CLEAN
#include "Python.h"
#include "py_test1.h"
static PyObject *py_test1_fac(PyObject *self,PyObject* args)
{

int n;
if(!PyArg_ParseTuple(args,"i",&n))
{
return NULL;
}
return (PyObject*)Py_BuildValue("i",fac(n));
}
static PyMethodDef py_test1Methods[]=
{
    {"fac",py_test1_fac,METH_VARARGS},
        {NULL,NULL},


};

static  PyModuleDef exmodule={
PyModuleDef_HEAD_INIT,
"py_test1",
NULL,
-1,
py_test1Methods
};

PyMODINIT_FUNC PyInit_py_test1(void)
{
return PyModule_Create(&exmodule);
}
/*void initpy_test1(void)
{
Py_InitModule("py_test1",py_test1Methods);

}*/
```
setup.py
```python
from distutils.core import setup,Extension
MOD="py_test1"
source=["py_test1.c","py_test1wrapper.c"]
setup(name=MOD,ext_modules=[Extension(MOD,sources=source,include_dirs=["/usr/include/python3.6"])])
```

#### c中调用python
```c++
#include<Python.h>
void mytest();
int main()
{

Py_Initialize();
PyRun_SimpleString("import sys");
PyRun_SimpleString("sys.path.append('./')");
PyRun_SimpleString("print('first hello world ')");
//PyObject* pname=PyLong_FromString("hello");
PyObject *pmodule=PyImport_ImportModule("hello1");
if(!pmodule)
{
printf("cuowu\r\n");
}
PyObject *pfunc=PyObject_GetAttrString(pmodule,"xxprint");
if(!pfunc)
{
printf("cuowu2");
}
//PyObject_CallFunction(pfunc,NULL);
PyEval_CallObject(pfunc,NULL);
PyObject *pdic=PyModule_GetDict(pmodule);
if(!pdic)
{
printf("cuowu\r\n");

}
pfunc=PyDict_GetItemString(pdic,"yprint");
PyObject* pArg=Py_BuildValue("(i,i)",7,8);
PyObject* result=PyEval_CallObject(pfunc,pArg);
int c=0;
PyArg_Parse(result,"i",&c);
PyObject* pclass=PyDict_GetItemString(pdic,"Hello");
if(!pclass)
{
printf("cuowu\r\n");

}
PyObject* pinstance=PyInstanceMethod_New(pclass);
pArg=Py_BuildValue("(s)","libo");
result=PyObject_CallMethod(pinstance,"sayhello","(s,s)","charity","charity");
//char* name;
//PyArg_Parse(result,"s",&name);
//printf("%s",name);
//PyObject *pclass=PyObject_GetAttrString(pmodule,"Hello");
//PyObject *arg=Py_BuildValue("(i)",5);
//PyObject *pinstance=PyObject_Call(pclass,arg,NULL);
//PyObject_CallMethod(pinstance,"print","i",6);
Py_Finalize();
return 0;
}
void mytest()
{
int a=3;

}
```
```python
class Hello:
    def __init__(self,x):
        self.a=x
    def hprint(self,x=None):
        print(x)
    def sayhello(self,name):
        
        print("hello,nihao "+name)
        return name
def xxprint
    print("111hello world")
def yprint(a,b):
    print(a+b)
if __name__=="__main__":
    xxprint()
    h=Hello(5)
    h.print("dafds")
    yprint(5,9)
```

### Tensorflow

| functon                        | meaning                      |
| ------------------------------ | ---------------------------- |
| tf.assign(variable.name,value) | tf.assign(x,[1,2])给变量赋值 |
| tf.squared_difference(x,y)     | 返回张量x-y各元素平方        |
| tf.multiply(a,b)               | 标量相乘                     |
| tf.matmul(a,b)                 | 矩阵相乘                     |
|                                |                              |
|                                |                              |
|                                |                              |
|                                |                              |
|                                |                              |
如下展示使用tensorboard

```python

import tensorflow as tf
import os


######################################
######### Necessary Flags ############
# ####################################

# The default path for saving event files is the same folder of this python file.
tf.app.flags.DEFINE_string(
    'log_dir', os.path.dirname(os.path.abspath(__file__)) + '/logs',
    'Directory where event logs are written to.')

# Store all elemnts in FLAG structure!
FLAGS = tf.app.flags.FLAGS

################################################
################# handling errors!##############
################################################

# The user is prompted to input an absolute path.
# os.path.expanduser is leveraged to transform '~' sign to the corresponding path indicator.
#       Example: '~/logs' equals to '/home/username/logs'
if not os.path.isabs(os.path.expanduser(FLAGS.log_dir)):
    raise ValueError('You must assign absolute path for --log_dir')


# Defining some constant values
a = tf.constant(5.0, name="a")
b = tf.constant(10.0, name="b")

# Some basic operations
x = tf.add(a, b, name="add")
y = tf.div(a, b, name="divide")

# Run the session
with tf.Session() as sess:
    writer = tf.summary.FileWriter(os.path.expanduser(FLAGS.log_dir), sess.graph)
    print("a =", sess.run(a))
    print("b =", sess.run(b))
    print("a + b =", sess.run(x))
    print("a/b =", sess.run(y))

# Closing the writer.
writer.close()
sess.close()
```
在终端执行`python3 py_name.py`,*tensorboard --logdir= \` pwd\`/logs*

