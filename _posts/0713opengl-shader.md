---
title: opengl_shader
tags: 数学
categories: 学习笔记
date: 2019-07-13 20:22:54
---

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});
</script>
<script type="text/javascript" async
  src="https://wujilingfeng.top/MathJax/MathJax.js?config=TeX-AMS_CHTML">
</script>



<!--more-->

#### Opengl

GLSL着色器语言

gl是核心库，glu是实用库，glut是实用工具库

[这里](<https://blog.csdn.net/z_dmsd/article/details/70949102>)有关于opengl有用的解释
一个纹理单元其实可以同时绑定多个纹理对象，只要这些纹理对象的类型不同
glext.h是各个厂家写的扩展库

[这里](<https://www.jianshu.com/p/f34fea694300?utm_source=oschina-app>)介绍了opengl的安装

[上下文](<https://www.cnblogs.com/Liuwq/p/5444641.html>)

gl3w和glad的作用应该是一样的。



*opengl的流程应该分为以下几步：*

- 首先做一些环境准备（glfwinit(),glad来辅助....）
- 创建一些点的集合，这些点有一个名字(opengl管他叫VAO)，这个名字代表了这些点的集合，这个集合还附带了其他一些东西:这些点（位置）的数据储存在了GPU内存(glCreateBuffers,glBufferStorage),这些点后续关联一些操作（程序），opengl管它叫着色器(shader)
- 如此以来，一个点集合的名字（VAO）就代表了以上东西。当我们需要用一个(VAO)画东西时，直接绑定一个VAO，然后调用glDrawElements即可。
- char是一个字节，byte也是一个字节，网上误人子弟，以讹传讹。有些图片三个字节表示一个像素值(RGB),或者4个字节表示一个像素值(什么狗屁一个像素值取值0-255，乱七八糟！)
  stdi_load函数返回的像素大小通过height*width*nchannel获得（这个函数的参数），这个函数最后一个参数应该是控制输出通道的个数(rgb或者rgba)

##### ubuntu安装glfw

```bash
sudo apt-get install cmake xorg-dev libgl1-mesa-dev
```

glfw的作用相当与glut,glew作用可以使得代码不需在运行时确定函数。

gl_frontfacing是内置变量，会根据三角形顶点的顺序给出opengl自己的判断

glDetachShader

glUseProgram(0)

##### mac安装glfw

```bash
mkdir build
cd build
cmake ../
make

```

##### glad入门

[这里](https://blog.csdn.net/zjz520yy/article/details/83000096),还描述了Opengl的绘制

##### 向shader传数组

uniform float v[10];

可以这样设置
GLfloat v[10] = {...};

glUniform1fv(glGetUniformLocation(program, "v"), 10, v);

```c
const int NUM_STEPS = 8;
const float PI	 	= 3.1415;
const float EPSILON	= 1e-3;
float EPSILON_NRM	= 0.1 / iResolution.x;

// sea
const int ITER_GEOMETRY = 3;
const int ITER_FRAGMENT = 5;
const float SEA_HEIGHT = 0.6;
const float SEA_CHOPPY = 4.0;
const float SEA_SPEED = 0.8;
const float SEA_FREQ = 0.16;
const vec3 SEA_BASE = vec3(0.1,0.19,0.22);
const vec3 SEA_WATER_COLOR = vec3(0.8,0.9,0.6);
float SEA_TIME = iGlobalTime * SEA_SPEED;

mat2 octave_m = mat2(1.6,1.2,-1.2,1.6);

// math
// 返回一个三维旋转矩阵(分别环绕x，y,z轴转动”ang“角度)(可以不要这个)
mat3 fromEuler(vec3 ang) {
	mat3 m1=(1.0,0.0,0.0,
	0.0,cos(ang.x),-sin(ang.x),
	0.0,sin(ang.x),cos(ang.x));
	mat3 m2=(cos(ang.y),0.0,sin(ang.y),
	0.0,1.0,0.0,
	-sin(ang.y),0.0,cos(ang.y));
	mat3 m3=(cos(ang.z),-sin(ang.z),0,
	sin(ang.z),cos(ang.z),0,
	0.0,0.0,1.0);
	return m1*m2*m3;
}

// 返回一个取值(0,1)的不规则数（但不是随机数，因为他是确定的输入输出）
float hash( vec2 p ) {
    float h = dotp,vec2(127.1,311.7));	
    return fract(sin(h)*43758.5453123);
}
//对于每个由整数分割的格子的四个定点，有由hash函数确定它的值，然后对于里面的点进行插值取值
//u=sin(f*PI/2.0）使得它不是线性插值
float noise( in vec2 p ) {
    vec2 i = floor( p );
    vec2 f = fract( p );
    vec2 coner1=hash(i+vec2(0.0,0.0));
    vec2 coner2=hash(i+vec2(1.0,0.0));
    vec2 coner3=hash(i+vec2(0.0,1.0));
    vec2 coner4=hash(i+vec2(1.0,1.0));
    vec2 u = sin(f*PI/2.0);
    return -1.0+2.0*mix( mix( coner1, coner2, u.x),mix( coner3, coner4,u.x),u.y);
}
//接下来的函数使我们有一个规则的"水波"地图
//picture1是它的图像，你也可以给出你的水波地图
float water_wave_base(vec2 uv)
{
vec2 wv = 1.0-abs(sin(uv)); 
    vec2 swv = abs(cos(uv));  
    wv = mix(wv,swv,wv);
    return pow(1.0-pow(wv.x * wv.y,0.65),4);
}
//noise函数是连续函数，uv+=noise(uv),相当于把地图(稍微)揉褶皱（因为上面的水波是规则的）
float water_wave(vec2 uv, float choppy) {
    uv += noise(uv);
    return sea_wave_base(vec2 uv);
}
//上面的水波依然不够褶皱，但却是连续的曲面，接下来再揉一下（这个方法具有创新性，而且曲面是连续的)
float water_wave_final(vec3 p) {
    float freq = SEA_FREQ;
    float amp = SEA_HEIGHT;
    float choppy = SEA_CHOPPY;
    vec2 uv = p.xy; 
    float d, h = 0.0;    
    for(int i = 0; i < ITER_FRAGMENT; i++) {
       
    	d = sea_octave((uv+SEA_TIME)*freq,choppy);
    	d += sea_octave((uv-SEA_TIME)*freq,choppy);
        
        h += d * amp; 
    	uv *= octave_m;
        
        freq *= 1.9; 
        amp *= 0.22; 
        choppy = mix(choppy,1.0,0.2);
    }
    return p.y - h;
}
//上面总结来看就是先增加noise数，再狠狠揉一下，得到水波地图
//接下来算法相向量
vec3 getNormal(vec3 p, float eps) {
  
    float h=water_wave_final(p);
    float h1=water_wave_final(vec3(p.x+eps,p.y,p.z));
    float h2=water_wave_final(vec3(p.x,p.y+eps,p.z));
    vec3 n=vec3(h1-h,h2-h,eps*eps);
    return normalize(n);
}


```

{% asset_img water_wave.png picture1 %}

关于法向量的推导，(x,y,f(x,y)),有$\left(dx,0,f_xdx\right)$,$\left(0,dy,f_ydy\right)$,作叉乘，然后有dx=dy=eps的关系,

opengl先跟据vertex shader 画的element决定那些像素会绘制，再根据frag shader的描述绘制像素。具体过程如下：
* 顶点着色器的输出坐标是眼睛(相机画面)坐标位置(中间可能给一个三维世界坐标，通过Projection投影坐标转换到眼睛的位置)
* 这些坐标又通过glviewpoint()放到（电视）视窗中，这样才轮到像素级别的操作，也就是片元着色器


glfwSet*的回调函数应放在glfwMakeContexCurrent之后

~~glfw鼠标移动的回调函数，应当是鼠标点击之后才触发~~(这句话不对)。

opengl shader默认视角是在原点位置，望向z的正轴。

投影透视阵的[推导](https://www.cnblogs.com/bluebean/p/5276111.html),但他的公式有错误

纹理坐标关于y轴对称

gl_vertexID

DrawElementsOneInstance

直接拿gl_position.z当深度不得了

https://www.cnblogs.com/nmgxbc/p/3802547.html