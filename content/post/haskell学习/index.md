+++
author = 'libo'
date = '2025-04-29T10:58:01+08:00'
draft = false
title = 'Haskell学习'
image = 'img.png'
+++

 [![Join the chat at https://gitter.im/autumnai/leaf](https://img.shields.io/badge/gitter-join%20chat-brightgreen.svg)](https://gitter.im/autumnai/leaf?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) 



haskell一种基于算子思想（functional）编程语言,以前我也设想过一种基于算子思想的编程语言，因为数学中所有空间集合的作用都可以理解为算子



学习haskell要避免工程繁杂概念的弊端，有时努力回想以前的数学概念代替工程概念是有好处的，首先工程概念名词繁杂不长久，而数学是所有学科(除了哲学)最长久的学科。(这种长久性是“知识成立”的时间)

比如手机cpu的架构和勾股定理，勾股定理在欧式几何中成立，之后发现在其他几何中不成立，而手机cpu的架构只是工程架构，几个月后就发生改变或者优化。所以勾股定理比c语言，计算机，鸿霥，甚至牛顿力学还要长久，那么为什么不学习寿命更长久的知识而要学习繁杂短暂的知识?

可以说未来属于算子类型语言cop,haskell，而不是工程类语言c,c++,java,python...

<!--more-->

使用haskell不应关注效率，而是思想。计算机专业大量人士进入haskell语言领域，它们给haskell语言带来了实践能力的同时也给haskell语言带来了计算机工程行业的弊端:行业术语的工程化，繁杂化，不严谨化。本文是用数学的概念统一解释haskell的概念，希望给数学专业的人免去繁杂和不严谨的工程概念。

*万物皆算子*，这样就不用记什么高阶函数，数据结构，递归数据结构，柯里化之类的概念。



自带的算子

| 算子          | 含义                                                         |
| ------------- | ------------------------------------------------------------ |
| :t a          | a的类型                                                      |
| ==            | 是否等于，返回True False                                     |
| /=            | 是否不等于                                                   |
| :l hello      | 加载hello.hs文件                                             |
| a ^ b         | 返回a的b次方                                                 |
| <=            |                                                              |
| >=            |                                                              |
| mod           | 取余                                                         |
| div           | 整除                                                         |
| even a        | a是否是偶数                                                  |
| odd a         | a是否是奇数                                                  |
| .和$          | ($) :: (a -> b) -> a -> b 和(.) :: (b -> c) -> (a -> b) -> a -> c，详细解释见下 |
|               | 取出列表的前n个元素                                          |
| map a [1,2..] | 一种经典用法 map (*) [1,2..]                                 |
| \             | lambda算子,比如(\xs -> length xs > 15),xs是参数，length xs > 15是body |
| 3             | 数字3也是算子，它是常量算子                                  |
| &&            |                                                              |
| \|\|          |                                                              |
| not           |                                                              |
| cos           |                                                              |
| sin           |                                                              |
| acos          |                                                              |
| asin          |                                                              |
|               |                                                              |
|               |                                                              |
|               |                                                              |
|               |                                                              |
|               |                                                              |
|               |                                                              |

有些算子有歧义可以类似如下调用

```haskell
read "5" :: Int
read "5" :: Integer
read "3.01" :: Float
```

由于-号也是算子,所以-1.0尽量加括号，变成(-1.0)

函数本身也是算子
```haskell
map f []=[]
map f (x:_)=f x:map f _

```
上面的map函数也叫“高阶函数”，但是从万物皆算子的角度看，并不要这种多余概念。

lambda算子举例`\(a,b,c)-> a+b-c`

##### 两个内建的类型

列表:

```haskell
[1,2,3,4]
--还有更简单的表示形式
[1..4]
```

```haskell
head [1..4]
last [1..4]
length [1..4]
maxmum [1..4]
minmum [1..4]
tail [1..4]
[1..4]!!2
```

元组:

```haskell
[(a,b,c) | a<-[1..100],b<-[1..a],c<[1..b],c^2+b^2==a^2]
```

#### 逻辑

```haskell
if var 2==2 then
	putStrLn "oK"
else
	putStrLn "not"
```



#### 模式匹配

模式匹配用来泛化算子的表示能力

```haskell
addVectors ::(Num a)=> (a,a)->(a,a)->(a,a)
addVectors (x1,y1) (x2,y2)=(x1+x2,y1+y2)

---作用在列表的算子
head' :: [a]->a
head' [] =error "cant "
head' (x:x_)=x


```

```haskell
--String也属于列表,其实代码是 type String=[Char],type类似c语言的typedef
capital :: String -> String
capital "" = "empty string"
capital (x:xs) = "the first letter of " ++ x:xs ++ " is " ++ [x]
```



在上面的head'算子定义你肯定觉得haskell是有“潜规则”的，否则它是如何匹配返回列表头部算子的？所以你只能默认并记住这种列表匹配的规则。(也就是在模式匹配中(x:_)表示列表)。

以下算子表示也比较隐蔽

```haskell
--x算子表示：x为常量1
x=1
--- 分别定义了x,y,z:算子，他们是常量
(x,y,z)=(0.1,2,-0.9)
```

上面看到Haskell的模式匹配条件相当松散。当算子定义合适时，如果输入类型不同的参数，它还是能正常运作。

但是当参数的类型差异较大时，模式匹配不能分辨参数的类型，也自然无法使得算子定义可以接受不同类型的参数。这时我们需要针对不同的类型写不同的算子。这样的坏处是算子名不能统一。

针对这种问题，haskell提出类型类的概念（见下）。

haskell的分段函数（类似c语言的case switch）

```haskell
bmiTell weight height 
	| bmi <= 18.5 = "you"
	| bim <= 25.0 = "my"
	| otherwise = "d"
	where bim = weight/height^2
```

如果把条件语句放到后面就更像数学分段函数的表示

分段函数还可以直接用在算子的表达式中

```haskell
fn a= let b |a==1 =0
			| otherwise =1
		in b
```

#### let .. in ..(其中..等于..)

数学中常用的语句 “其中..等于..”。它的表示用来解释in单词后面的式子

#### ... Where ...(其中..等于..)

数学中常用的语句 “其中..等于..”。它的表示用来解释单词where前的式子。

where必须换行并回车，并且where之前的式子必须要是等式

```haskell
[let sq x=x*x in (sq 3,sq 4,sq 5)]
--返回(9,16,25)
let sq x=x*x in [sq 1,sq 2,sq 3]
```

```haskell
a=[sq 3,sq 4,sq 5]
	where sq x=x*

```

where的多个定义使用分号

```haskell
let {a x=g
	where 
		g= p x x;
		p a b =a+b

}
```

如果换a x=g为g,那么编译失败。



##### 两个简单的复合算子

foldr f a [a1,a2...]

上面的算子f是某个算子，如果记这个算子为*,那么结果就是 `a1 * a2 *a3 .... *an * a`

有人翻译成右折叠，这增加了名词学习成本,比较恶心

foldl f a [a1,a2 ...]

上面的算子f是某个算子，如果记这个算子为*,那么结果就是 `a * a1 * a2 *a3 .... *an `

有人翻译成左折叠，这增加了名词学习成本，比较恶心

#### 类型类--算子类

如果你需要一些算子，它能接受的参数是多种类型的。那么你需要定义一个”类型类“（建议改名"函数类"或者“算子类”，因为它的主要作用就是扩展函数或算子的表达力）。



比如我需要==算子，他需要能接受Float,Interger,Char等类型(或者输出为多种类型)。我那么我可以定义Myeq的类型类。

```haskell
data Node a= Cons a (Node a) | NULL 
    deriving (Show)
class Myeq a where
    iseq :: a->a->Bool
instance (Eq a)=>Myeq (Node a) where
--iseq :: (Eq x)=> (Cons x _)->(Cons x _)->Bool
    iseq (Cons x _) (Cons y _)=(x==y)
data Shape= Circle | Rectangle
instance Myeq Shape where
	iseq Circle Rectangle=False
	iseq Rectangle Circle =False
	iseq Circle Circle=True
	iseq Rectangle Rectangle=True


```

故而类型类是为了拓展函数（算子）的泛化能力而存在的。它的核心含义是其下声明的函数(算子)。

#### Module

import qualified Data.Map as M

这是python是一样的

#### 自定义算子类型

```haskell
data Mybool = True | False
```

True是算子，False也是算子，他们都是没有参数的，所以都是常量。Mybool是这两个算子所属的类型。

```haskell
data Shape=Circle Float Float | Rectangel Float Float Float Float
```

上面的Circle和Rectangel是两个算子，Circle作用两个参数,且这两个参数分属Float 类型。Shape则是两个算子所属的类型。

上面虽然讲Haskell秉承万物皆算子，但是上面的Shape和Mybool却不是算子，实际上类型都不是算子，比如Integer（haskell没有把它看作算子，但是却看成函子，详细见下）。

带参数的类型,这个参数表示的是类型。

```haskell
data Node a =Cons a (Node a)
```

这只有一个算子，那就是Cons 。它作用于两个参数,这两个参数属于类型 a和 (Node a)。系统找不到类型a的定义，自然表明它是任何类型，Node a则是引用了自身的定义。

Node a是Cons算子属于的类型.

上面讲Haskell没有把Shape等视为算子，但是Haskell却把Shape 和Node a等视为函子。因为它是类型到类型的映射，比如Shape 是常量 ,而Node  则是把类型a映射为 Node,即a->Node a。Node a也是函子，只不过它是常量。

所有类型都视为函子。

https://www.cnblogs.com/livewithnorest/archive/2012/08/02/2620718.html)

#### 范畴和函子

这里是[范畴和函子定义](https://en.wikipedia.org/wiki/Functor)

##### 范畴

* 范畴C包含"物件"，记为obj(C)(比如拓扑空间的开集就是Hausdoff空间的物件)
* 范畴C包含态射或者箭头，改态射将物件a映射为物件b,记为$Hom_C \left(a,b\right)$
* 范畴C,态射之间存在"作用"或者二元运算，称作态射的复合，这样的态射构成"幺半群（满足结合律和单位元）"。[^1]

[^2]: 加引号是因为复合这个作用并不能作用在所有态射上，而群是要求所有元素都可作用。

##### 函子

设C和D为范畴，函子F是C到D的映射，满足

* 将C的每个物件$X\in C$映射至$F\left(X\right)\in D$上
* 将C的每个态射$f\in Hom_C\left(a,b\right)$映射至$F\left(f\right)\in Hom_D\left(F\left(a\right),F\left(b\right)\right)$
* 将C的态射的单位元映射到D的态射单位元
* 对”态射构成的幺半群“是“同态”。[^2]

[^2]: 同态是群上的定义，幺半群加引号，同态也要加引号。

按照定义范畴有一堆集合，和箭头。

{% asset_img cate.png 范畴 %}

函子是范畴和范畴之间集合的箭头

{% asset_img functor.png 函子 %}

如上图，假设A,B是范畴1的集合，C,D是范畴2的集合，A到C的箭头是函子，B到D的箭头是函子，那么从A到B的箭头可以诱导C到D的箭头。

注意上面讲：类型类主要用来让函数（算子）接受不同类型的参数。

数学上函子不但联系了两个范畴的对象，还将两个范畴的箭头进行联系。而Haskell的类型系统只是完成了两个范畴对象的对应(没有给出映射)。

比如`[Int]`联系了集合Int 和 [Int],并没有映射，它们之间也没有映射。

haskell有个类型类Functor,这里的Functor主要解决两个对应类型之间的诱导映射。每一个类型都联系了两个类型（比如Int类型联系了Int到自身），这里的Functor（它的核心是算子fmap）主要解决类型诱导的映射问题。



你已经注意到这里我说的函子都是数学上严格定义的函子，haskell的Functor虽然名字叫函子，它并非严格意义的函子，上面也说了：它是主要是解决类型诱导的映射。

```haskell
class Functor f where
	fmap:: (a->a)->f a->f a
instance Functor [] where
    fmap = map
```



#### 单子

设有范畴C,T是$C\to C$的函子，u是$c\to TC$的函子，v是$TTC\to TC$的函子，如果u，v满足$vTu=vuT=id$和$uTu=uuT:T^3C\to TC$,那么称$\left(T,u,v\right)$是C的单子。

haskell语言单子与数学上单子不同，主要体现在不严谨性，比如现在的haskell 的Monad的return函数在$TC$上没有定义,整个函数也没有定义在$TTC$...,而且函数式编程语言的定义:自函子上的幺半群并非数学上的定义，应该是编程语言自己加的结构。



#### 总结

总结来说，haskell的重要概念都是围绕两个元素服务的1:算子，2:函子。

其中函子(数学上的严格定义)在haskell表现为:

* 定义新的类型 --- 将范畴映射为另一范畴。（函子）
* "算子类"---函子诱导的映射（不论是haskell的Functor,Manod都属于这一概念）。

本文也有弊端，一方面本文试图从数学角度统一解释，但是文章叙述确实参杂各种工程术语，并且文章也叙述了很细小的工程细节，希望以后能够修改本文。

像haskell这一类语言简直是数学专业的神器，懊悔发现这门语言太晚！

[Parallel and Concurrent Programming in Haskell[Book]](https://www.oreilly.com/library/view/parallel-and-concurrent/9781449335939/)
