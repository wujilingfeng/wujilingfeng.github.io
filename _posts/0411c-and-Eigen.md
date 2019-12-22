---
title: c++and Eigen
tags: 数学
categories: 学习笔记
date: 2019-04-11 22:01:23
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});
</script>
<script type="text/javascript" async
  src="https://wujilingfeng.top/MathJax/MathJax.js?config=TeX-AMS_CHTML">
</script>


本文记录c++学习笔记

<!--more-->

### C++

c++语言工程性极强，语言极不自然，就好像一个繁杂装满补丁的机器。框架缺乏统一，更缺乏自然的哲学。

for循环，先执行初始化和判断（第一次)

string类类似stl

父类和子类有几乎相同的函数，那么子类实例点明调用父类函数1，而这个函数1内部会优先调用父类函数。

##### STL

| 常用函数     | 意义 |适用|
| :--- | :------- |:---|
| .push_back |          ||
| .find(key) | 返回等于key的迭代器 |set，map|
| == | 逻辑判断操作符 |vector|
| .erase(key\|\|iterator) |          |map|
| string.substr(pos,len) | 对string类截取pos位置以后len个字符串(字符串有len个元素) |string类|
| string.append(size,char) | 对string追加size个char ||
| int (*a)[4]=new int[n] [4] | 括号不能少，第二个维度要确定 ||
| string(size,char) | string的构造函数(size个char字符) ||
|  | ||

```c
unsigned int l=0;
double a=0;
if(a<(l-1))
{
	printf("shi");
}
```
上面代码显示了一个奇怪的现象，输出竟让是 "shi",这是usigned值的比较问题。
更隐蔽的是string,vector,list,等的size()函数返回的就是unsigned值所以编程时非常容易出错。
```
int a[3]={0};
```
上述代码不能保证a的每个值初始化为0;
写程序应考虑特殊情况（尤其在笔试时候）


stl中的set map 的iterator 是const的

###### remove和erase

remove形参为值，erase的形参为位置。vector的remove是将等于value元素放到末尾，并不影响size。

erase会销毁指针使用时请注意。

###### ++

前++表示先自身++再传递自身值，后++表示自身++完后，传递没++之前的值。

如下两个例子，一个b值为2，一个为3.

```bash
int a=2,b=a++;
int a=2,b=++a;
```

delete 释放new分配的单个对象指针指向的内存
delete[] 释放new分配的对象数组指针指向的内存

模板函数的参数是不能赋予默认初值的，只能在声明时给default值

#### CSTL

在linux需要配置动态库cstl.so文件的环境变量，可以考虑修改ld.so.conf文件。

cstl的类是靠申请永久内存存在的，所以返回指针，类似new和malloc.

cstl 的迭代器不是const

``` c
#define pair_second(i) pair_second((pair_t*)iterator_get_pointer(i))
#define pair_first(i) pair_first((pair_t*)iterator_get_pointer(i))
vector_t* pv=create_vector(vector_t<void *>);
vector_t*t=create_vector(void *);
int *v=(int*)malloc(sizeof(int));
*v=4;
vector_init(pv);
vector_init(t);
vector_push_back(t,(void*)v);
vector_push_back(pv,t);
vector_destroy(t);
iterator_t iter=vector_begin(pv);
//printf("%lu  %lu\r\n",t,iterator_get_pointer(iter));
iterator_t iter1=vector_begin((vector_t*)iterator_get_pointer(iter));
printf("%d\r\n",(*(template_v**)vector_at(((vector_t*)vector_at(pv,0)),0))->id);
printf("%d\r\n",(*(template_v**)iterator_get_pointer(iter1))->id);
if(pm==NULL)
{
printf("shibai\r\n");
}

```

``` c
map_t *pm=create_map(vector_t<void *>,int);
vector_t*t=create_vector(void *);
int *v=(int*)malloc(sizeof(int));
v->id=10;
vector_push_back(t,(void*)v);
map_init(pm);
*(int*)map_at(pm,t)=3;
vector_destroy(t);
iterator_t iter=map_begin(pm);
//iterator_t iter1=map_begin((vector_t*)pair_first((pair_t*)iterator_get_pointer(iter)));
iterator_t iter1=vector_begin((vector_t*)pair_first((pair_t*)iterator_get_pointer(iter)));
//printf("value %d\r\n",((template_v*)pair_first(iterator_get_pointer(iter)))->id);
printf("%lu %lu\r\n",t,pair_first((pair_t*)iterator_get_pointer(iter)));

printf("%d\r\n",(*(template_v**)iterator_get_pointer(iter1))->id);


```

但是cstl速度不如stl快，我想这也是它落寞的原因．

##### 继承

子类的构造函数会默认调用父类无参构造函数

##### const

类的函数后面加const,表示此函数不会修改成员变量。

一个加了const的变量，其调用的函数必须加const,调用其的函数亦是如此。

const_cast了解一下。

模板函数最好声明时就定义,或者#include<.cpp>
### C

```c
int* a=(int*)malloc(sizeof(int)*0);//返回一个NULL或者无法访问的指针
```



c语言的二维数组其实内部是以一维数组存在的。函数在传递二维数组要指明列数

getchar() scanf("%c",)会读取' ' '\n'
而scanf("%d",)会忽略空格和换行来读取数字
`scanf("%d ",&N)`不但会读取一个整数，并吸收一个空格，还可以吸收 回车。
函数参数的引用在c中不支持(如:void test(int &a)),这是c++的特性
#include相当于复制粘贴作用，（python的import或许也是如此）

static修饰的函数表示此函数只在本文件可用。

malloc 和free是一对的

c语言只有_Bool类

程序的内存有栈和堆的概念，变量在栈，new和malloc在堆．malloc中不能用new．

写一个库最快的方法就是用最简单的想法，工具实现问题（尽量少依赖别的库）,一个函数做的事尽可能少（如果追求高效）
不同类型指针++移动不同步长
c语言EOF在linux用`ctrl + d`

c语言0是false,1是true.
```c
' ' #空格符
'\n' #换行符，也可用来判断空行
```
```c
	double a=14;
    double tempn=a/10.0;
    int tempi=tempn;
    int re=((tempn-tempi)*10);
    printf("%d\r\n",re);
```
上面代码展示了c语言精度问题

```c
char c='10'
int a=c-'0';
```
上面展示了如何把字符转化为整数

```c
char c='A';
char c1=c+4;
```

|常用函数|解释|
| --- | --- |
| getchar() | 从终端输入的键盘缓冲区读入一个字符(主要作用是等待键盘输入) |
| putchar() | 在终端显示一个字符 |
| fscanf() | 是从文本读取字符(返回读取个数，-1代表eof) |
| scanf() | 从终端读取字符(返回读取的个数，-1代表eof) |
| printf() | 打印字符到终端 |
| gets() | 读取一行(已经被弃用)（建议用fgets） |
| sscanf() | 从字符串中格式化读取 |
| fgets(char*,int n,stream) | 当stream是file*读取文件流，为stdin是终端 |
| sprintf(char*,char\* format,) | 产生一个字符串 |
| fprintf(FILE*,"") |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
```c
char c='1';
int a[20];
int i=0;
while(c!='\n')
{
	scanf("%d",&a[i]);
	i++;
	c=getchar();
}

```
上面展示了实现读取一行整数的功能
```c
# include <malloc.h>
# define MALLOC(NUM, TYPE) (TYPE *)malloc(NUM * sizeof(TYPE))  //宏在传参时是可以传入类型的
 
int max = 0;
max = Max(x, int, y, int);  //error 函数在传参时是不可以传入数据类型的
```
c函数指针引用的函数如果又调用了某个函数指针，那么应该注意这两个函数定义的顺序。



#### Eigen

.rows()=.rows()赋值操作必须保证列数相等

Eigen::MatrixXd a;a.data();//data函数返回数据内存的首地址，便于和其他数据交流
Eigen的data()是按每列遍历的

| 函数                                                         | 意义     |
| ------------------------------------------------------------ | -------- |
| .setOnes()                                                   |          |
| .setZero()                                                   |          |
| .transpose()                                                 |          |
| .adjoint()                                                   | 伴随矩阵 |
| .inverse()                                                   |          |
|                                                              |          |
| tripletlist.push_back(Eigen::Triplet<float>(i, j, A(i, j))); |          |
|                                                              |          |
|                                                              |          |

[这里](https://blog.csdn.net/u012541187/article/details/53420432)

#### png格式

[这里](<https://blog.csdn.net/hherima/article/details/45848171>)

竞赛注意事项

格式错误注意观察题目格式，\r\n和\n也是不同的

注意题目是否要任意输入，然后任意次输出