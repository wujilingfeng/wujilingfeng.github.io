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

关于法向量的推导，(x,y,f(x,y)),有(dx,0,fxdx),(0,dy,fydy),作叉乘，然后有dx=dy=eps的关系,

opengl先跟据vertex shader 画的element决定那些像素会绘制，再根据frag shader的描述绘制像素。

glfwSet*的回调函数应放在glfwMakeContexCurrent之后

glfw鼠标移动的回调函数，应当是鼠标点击之后才触发。

opengl默认视角是在原点位置，望向z的负轴。

投影透视阵的[推导](https://www.cnblogs.com/bluebean/p/5276111.html),但他的公式有错误