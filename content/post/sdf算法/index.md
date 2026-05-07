+++
author = 'libo'
date = '2026-05-05T18:00:46+08:00'
math= true
draft = false
title = 'Sdf算法'
+++

可以“顺带实现”的原因是：**Dual Contouring 本身就需要一个隐式标量场**，而 SDF 正好就是最常用、最稳定的一种隐式场。

你现在已经有八叉树了，所以 SDF 的实现重点不是再写一个全新的重建算法，而是给八叉树的采样点补一个函数：

```cpp
float sdf(Vec3 x);
Vec3  sdfGradient(Vec3 x);
```

然后 Dual Contouring 和后面的 Poisson / Marching Cubes 都可以围绕这个隐式场工作。

------

# 1. SDF 是什么

SDF 全称是 **Signed Distance Field，有符号距离场**。

对空间中任意一点 `x`，SDF 给出它到表面 `S` 的最近距离，并且带有正负号：

```text
φ(x) = signed distance from x to surface
```

常见约定：

```text
φ(x) < 0 ：点在物体内部
φ(x) = 0 ：点在物体表面
φ(x) > 0 ：点在物体外部
```

例如一个半径为 `r`、中心在原点的球体：

```cpp
float sdfSphere(Vec3 p, float r) {
    return length(p) - r;
}
```

当：

```text
length(p) < r  → φ(p) < 0，球内
length(p) = r  → φ(p) = 0，球面
length(p) > r  → φ(p) > 0，球外
```

所以 SDF 的核心就是：

```text
零等值面 φ(x) = 0 就是重建出来的表面
```

------

# 2. SDF 和 Dual Contouring 的关系

Dual Contouring 需要判断一个八叉树 cell 里面有没有表面穿过。

最基本的判断就是看 cell 的边两端是否异号：

```text
φ(v0) < 0, φ(v1) > 0
```

说明表面穿过这条边。

然后用线性插值求交点：

```cpp
float t = phi0 / (phi0 - phi1);
Vec3 p = v0 + t * (v1 - v0);
```

这个 `p` 就是边与隐式表面的交点。

Dual Contouring 还需要法线，也可以从 SDF 得到：

```text
n = normalize(∇φ)
```

也就是 SDF 的梯度方向。

如果没有解析梯度，可以用有限差分：

```cpp
Vec3 sdfGradient(Vec3 p) {
    float eps = 1e-4f;

    float dx = sdf(p + Vec3(eps, 0, 0)) - sdf(p - Vec3(eps, 0, 0));
    float dy = sdf(p + Vec3(0, eps, 0)) - sdf(p - Vec3(0, eps, 0));
    float dz = sdf(p + Vec3(0, 0, eps)) - sdf(p - Vec3(0, 0, eps));

    return normalize(Vec3(dx, dy, dz));
}
```

所以 Dual Contouring 的 Hermite 数据：

```text
交点 p
法线 n
```

可以完全由 SDF 提供。

也就是说，你的 Dual Contouring 可以变成这样：

```cpp
for each leaf cell:
    sample sdf at 8 corners

    for each of 12 edges:
        if signs are different:
            Vec3 p = edgeIntersectionBySdf(edge)
            Vec3 n = sdfGradient(p)

            qef.add(p, n)

    if cell has intersections:
        Vec3 vertex = qef.solve()
        cell.vertex = vertex
```

------

# 3. 为什么说 SDF 可以“顺带实现”

因为你已经有：

```text
八叉树
cell
corner
edge
dual contouring 的 QEF
```

那么只需要给每个 corner 存一个 SDF 值：

```cpp
struct OctreeCornerSample {
    Vec3 position;
    float sdf;
};
```

每个叶子节点存八个角点的 SDF：

```cpp
struct OctreeLeaf {
    Vec3 corners[8];
    float values[8];

    bool active;
    Vec3 dualVertex;
};
```

之后：

```text
SDF 负责告诉你哪里是表面
Dual Contouring 负责从表面采样里生成网格
Poisson 负责从点云法线场里生成隐式面
```

所以 SDF 不是和 Dual Contouring 冲突的东西，而是 Dual Contouring 的输入形式之一。

------

# 4. SDF 的理论核心

SDF 定义为：

```text
φ(x) = ± min ||x - y||
       y∈S
```

其中：

```text
S 是目标表面
x 是空间中的任意一点
y 是表面上的最近点
```

如果 `x` 在外部，取正号；如果 `x` 在内部，取负号。

SDF 有几个重要性质。

------

## 4.1 零等值面就是表面

```text
φ(x) = 0
```

的所有点组成的集合就是物体表面。

这也是为什么 Marching Cubes、Dual Contouring 都能从 SDF 提取网格。

------

## 4.2 SDF 的梯度就是法线方向

在表面附近：

```text
n = ∇φ / |∇φ|
```

如果 SDF 是标准距离场，理论上满足：

```text
|∇φ| = 1
```

这就是 Eikonal 方程：

```text
|∇φ(x)| = 1
```

所以 SDF 不只是告诉你点在里面还是外面，它还隐含了表面法线信息。

Dual Contouring 正好需要法线，因此 SDF 很适合 DC。

------

## 4.3 SDF 比普通 occupancy 更强

普通 occupancy 只告诉你：

```text
inside / outside
```

比如：

```cpp
bool inside(Vec3 p);
```

但 SDF 告诉你：

```text
离表面多远
在哪一侧
法线方向是什么
```

所以它的信息量更大。

例如：

```text
occupancy:
    p 在内部

SDF:
    p 在内部，距离表面 0.034，法线大致朝 +x 方向
```

这对重建质量影响很大。

------

# 5. 从已有数据怎么构建 SDF

这个要看你的输入是什么。

一般有三种情况：

```text
1. 输入是三角网格
2. 输入是点云 + 法线
3. 输入本来就是隐式函数
```

------

# 6. 情况一：从三角网格生成 SDF

如果你已有一个 mesh，要生成 SDF，步骤是：

```text
1. 对查询点 x 找最近三角形
2. 计算 x 到最近三角形的距离
3. 判断 x 在模型内部还是外部
4. 根据 inside / outside 加符号
```

伪代码：

```cpp
float meshSdf(Vec3 x, Mesh mesh) {
    ClosestResult result = findClosestTriangle(x, mesh);

    float dist = length(x - result.closestPoint);

    bool inside = isInsideMesh(x, mesh);

    return inside ? -dist : dist;
}
```

关键在两个部分：

------

## 6.1 最近距离

对每个点 `x`，找距离最近的三角形。

暴力做法：

```cpp
for each triangle:
    closest = closestPointOnTriangle(x, triangle)
    dist = length(x - closest)
```

但是太慢。

实际应该用：

```text
BVH
AABB Tree
KD-tree
Octree acceleration
```

你已经有八叉树的话，也可以先用八叉树做粗筛，但是通常三角形最近距离更适合 BVH。

------

## 6.2 inside / outside 判断

如果 mesh 是封闭的，可以用射线法：

```text
从 x 发出一条射线
统计与三角形相交次数
奇数：内部
偶数：外部
```

也可以用 winding number：

```text
winding number 接近 1：内部
winding number 接近 0：外部
```

工程上：

```text
封闭网格：ray casting 或 winding number
非封闭网格：最好用 generalized winding number
```

对于不封闭的模型，单纯 ray casting 很容易出错。

------

# 7. 情况二：从点云 + 法线生成 SDF

如果你的输入是点云，比如：

```cpp
struct PointSample {
    Vec3 position;
    Vec3 normal;
};
```

可以用局部平面近似生成 SDF。

对于查询点 `x`，找到附近的点 `p_i` 和法线 `n_i`。

单个点的局部 SDF 可以近似为：

```text
φ_i(x) = dot(x - p_i, n_i)
```

也就是点 `x` 到该点切平面的有符号距离。

多个点加权平均：

```text
φ(x) = Σ w_i dot(x - p_i, n_i) / Σ w_i
```

权重可以用距离衰减：

```text
w_i = exp(-||x - p_i||² / h²)
```

伪代码：

```cpp
float pointCloudSdf(Vec3 x, PointCloud cloud) {
    auto neighbors = kNearestPoints(x, cloud, k);

    float sumW = 0.0f;
    float sumD = 0.0f;

    for (auto& s : neighbors) {
        float r2 = length2(x - s.position);
        float w = exp(-r2 / (h * h));

        float d = dot(x - s.position, s.normal);

        sumW += w;
        sumD += w * d;
    }

    return sumD / sumW;
}
```

这个方法本质上是：

```text
用点云法线拟合局部隐式面
```

注意：这不是严格意义上的真实距离场，但在表面附近很好用。

对于 Dual Contouring 来说，只要局部符号和法线稳定，就已经够用了。

------

# 8. 情况三：已有隐式函数

如果你的模型本来就能用函数表示，比如球、盒子、圆柱、布尔体，那就最简单。

例如球：

```cpp
float sdfSphere(Vec3 p, float r) {
    return length(p) - r;
}
```

盒子：

```cpp
float sdfBox(Vec3 p, Vec3 b) {
    Vec3 q = abs(p) - b;
    return length(max(q, Vec3(0))) + min(max(q.x, max(q.y, q.z)), 0.0f);
}
```

圆柱：

```cpp
float sdfCylinder(Vec3 p, float radius, float height) {
    Vec2 d = abs(Vec2(length(Vec2(p.x, p.z)), p.y)) - Vec2(radius, height * 0.5f);
    return min(max(d.x, d.y), 0.0f) + length(max(d, Vec2(0)));
}
```

这种情况下，Dual Contouring 只要采样这个函数就行。

------

# 9. 在八叉树里如何存 SDF

你可以把八叉树节点设计成这样：

```cpp
struct SdfSample {
    Vec3 position;
    float value;
    Vec3 gradient;
};

struct OctreeNode {
    AABB bounds;
    OctreeNode* children[8];

    bool isLeaf;

    SdfSample corners[8];

    bool active;
    Vec3 dualVertex;
};
```

构建时：

```cpp
void buildNode(OctreeNode* node, int depth) {
    sampleCorners(node);

    if (shouldSubdivide(node, depth)) {
        subdivide(node);
        for each child:
            buildNode(child, depth + 1);
    } else {
        node->isLeaf = true;
        node->active = hasSignChange(node);
    }
}
```

角点采样：

```cpp
void sampleCorners(OctreeNode* node) {
    for (int i = 0; i < 8; i++) {
        Vec3 p = node->cornerPosition(i);

        node->corners[i].position = p;
        node->corners[i].value = sdf(p);
        node->corners[i].gradient = sdfGradient(p);
    }
}
```

判断是否有符号变化：

```cpp
bool hasSignChange(OctreeNode* node) {
    bool hasPositive = false;
    bool hasNegative = false;

    for (int i = 0; i < 8; i++) {
        if (node->corners[i].value > 0) hasPositive = true;
        if (node->corners[i].value < 0) hasNegative = true;
    }

    return hasPositive && hasNegative;
}
```

但是注意：**只看八个角点会漏掉细小结构。**

更稳的判断方式是结合 cell 中心点和距离下界。

因为 SDF 满足：

```text
如果 cell 中心到表面的距离大于 cell 半对角线，
那么这个 cell 里一定没有表面。
```

设：

```cpp
float centerValue = abs(sdf(cell.center));
float radius = cell.bounds.halfDiagonalLength();
```

如果：

```cpp
centerValue > radius
```

说明表面不可能穿过这个 cell，可以不用细分。

否则要继续细分。

------

# 10. SDF + Dual Contouring 的完整流程

整体流程可以这样写：

```text
1. 准备 sdf(x)
2. 构建自适应八叉树
3. 在 octree corner 上采样 sdf
4. 找到 active cell
5. 对 active cell 的边做符号检测
6. 求边交点
7. 用 sdf gradient 得到法线
8. 建立 QEF
9. 解出 dual vertex
10. 根据相邻 cell 连接面片
```

核心伪代码：

```cpp
void processLeaf(OctreeNode* leaf) {
    QEF qef;

    for (int e = 0; e < 12; e++) {
        int a = edgeTable[e][0];
        int b = edgeTable[e][1];

        float va = leaf->corners[a].value;
        float vb = leaf->corners[b].value;

        if (va * vb < 0.0f) {
            Vec3 pa = leaf->corners[a].position;
            Vec3 pb = leaf->corners[b].position;

            float t = va / (va - vb);
            Vec3 p = pa + t * (pb - pa);

            Vec3 n = sdfGradient(p);

            qef.add(p, n);
        }
    }

    if (qef.count() > 0) {
        Vec3 v = qef.solve();

        if (!leaf->bounds.contains(v)) {
            v = qef.massPoint();
        }

        leaf->dualVertex = v;
        leaf->active = true;
    }
}
```

QEF 的意义是：

```text
找一个点 v，使它尽量靠近所有交点的切平面
```

每个交点 `p_i` 和法线 `n_i` 定义一个平面：

```text
dot(n_i, x - p_i) = 0
```

QEF 要最小化：

```text
Σ dot(n_i, v - p_i)²
```

这也是 Dual Contouring 能保留尖锐特征的关键。

------

# 11. SDF 和 Poisson 重建的关系

Poisson 重建和 SDF 的关系容易混淆。

Poisson Surface Reconstruction 不是直接求 SDF，它求的是一个隐式函数，通常可以理解为近似的 indicator function：

```text
χ(x)
```

它的目标是让：

```text
∇χ ≈ V
```

其中 `V` 是由输入点云法线构造的向量场。

最后提取某个等值面：

```text
χ(x) = isoValue
```

得到重建表面。

所以 Poisson 的输出也是一个隐式场，但它不是严格 SDF。

区别是：

```text
SDF:
    φ(x) 是到表面的有符号距离
    理论上 |∇φ| = 1

Poisson:
    χ(x) 更像内外指示函数
    不保证 |∇χ| = 1
```

因此：

```text
Poisson field ≠ SDF
```

但是你可以从 Poisson 结果“顺带生成 SDF”。

------

# 12. 从 Poisson 结果得到 SDF 的方法

有两种做法。

------

## 方法一：先提取 Poisson mesh，再从 mesh 生成 SDF

流程：

```text
点云 + 法线
    ↓
Poisson 重建
    ↓
三角网格
    ↓
mesh signed distance
    ↓
SDF
```

这是最稳的。

即：

```cpp
Mesh poissonMesh = poissonReconstruct(points, normals);
float phi = meshSdf(x, poissonMesh);
```

优点：

```text
稳定
容易理解
SDF 是真实几何距离
```

缺点：

```text
需要额外的最近三角形查询
需要处理 inside / outside
```

------

## 方法二：直接用 Poisson 的隐式函数近似 SDF

假设 Poisson 得到：

```text
F(x) = χ(x) - isoValue
```

表面是：

```text
F(x) = 0
```

那么在表面附近，可以近似：

```text
SDF(x) ≈ F(x) / |∇F(x)|
```

也就是：

```cpp
float approximateSdfFromImplicit(Vec3 x) {
    float f = poissonField(x) - isoValue;
    Vec3 g = gradientPoissonField(x);

    return f / length(g);
}
```

这个公式的含义是：

```text
普通隐式函数值除以梯度长度，可以近似变成距离
```

但是它只在表面附近比较准。

远离表面时不建议当作精确 SDF 使用。

------

# 13. 你现在最推荐的实现路线

如果你已经有八叉树和 Dual Contouring，我建议你按这个顺序实现：

```text
第一步：写一个统一的 SDF 接口
第二步：让 Dual Contouring 从 SDF 采样
第三步：从简单解析 SDF 测试，比如球、盒子
第四步：从三角 mesh 生成 SDF
第五步：从点云 + 法线生成近似 SDF
第六步：Poisson 结果转 SDF
```

接口可以这样设计：

```cpp
class ISdf {
public:
    virtual float value(const Vec3& p) const = 0;

    virtual Vec3 gradient(const Vec3& p) const {
        float eps = 1e-4f;

        float dx = value(p + Vec3(eps, 0, 0)) - value(p - Vec3(eps, 0, 0));
        float dy = value(p + Vec3(0, eps, 0)) - value(p - Vec3(0, eps, 0));
        float dz = value(p + Vec3(0, 0, eps)) - value(p - Vec3(0, 0, eps));

        return normalize(Vec3(dx, dy, dz));
    }
};
```

然后：

```cpp
class SphereSdf : public ISdf {
public:
    Vec3 center;
    float radius;

    float value(const Vec3& p) const override {
        return length(p - center) - radius;
    }
};
```

Dual Contouring 不关心你是球、mesh、点云还是 Poisson，它只调用：

```cpp
float phi = sdf.value(p);
Vec3 n = sdf.gradient(p);
```

这样结构最干净。

------

# 14. SDF 在八叉树上的自适应细分策略

你可以用这个策略：

```cpp
bool shouldSubdivide(OctreeNode* node, int depth) {
    if (depth >= maxDepth) {
        return false;
    }

    float centerPhi = abs(sdf(node->center()));
    float radius = node->bounds.halfDiagonalLength();

    if (centerPhi > radius && !hasCornerSignChange(node)) {
        return false;
    }

    return true;
}
```

含义是：

```text
如果 cell 离表面很远，不细分
如果 cell 可能包含表面，继续细分
如果达到最大深度，停止
```

更实际一点：

```cpp
bool shouldSubdivide(OctreeNode* node, int depth) {
    if (depth >= maxDepth) return false;

    bool signChange = hasCornerSignChange(node);

    float centerPhi = abs(sdf(node->center()));
    float radius = node->bounds.halfDiagonalLength();

    bool nearSurface = centerPhi < radius * 1.5f;

    return signChange || nearSurface;
}
```

这样可以避免只看 corner 导致漏掉薄片、尖角、小物体。

------

# 15. SDF 精度的几个坑

## 15.1 只采样 corner 会漏表面

如果一个表面完全穿过 cell 中间，但 8 个角点都在外部，那么 corner sign 不会变化。

所以要结合：

```text
中心采样
距离下界
更深细分
bounding volume 检测
```

------

## 15.2 点云 SDF 的符号不一定稳定

点云生成 SDF 依赖法线方向。

如果法线方向混乱：

```text
一部分朝外
一部分朝内
```

那么 SDF 会出现符号错乱。

所以点云输入必须先做：

```text
法线估计
法线一致化
法线朝向修正
```

------

## 15.3 Poisson 场不是 SDF

Poisson 的隐式函数可以提取表面，但它不是距离。

不能直接把：

```cpp
poissonField(x) - isoValue
```

当成真实距离。

最多只能当作：

```text
隐式标量场
```

如果要近似 SDF，需要：

```cpp
F(x) / |∇F(x)|
```

或者从提取后的 mesh 重新计算 signed distance。

------

## 15.4 SDF 的梯度在尖角处不连续

对于尖锐边、尖角，SDF 的最近点可能不唯一。

这时：

```text
∇φ 不连续
```

Dual Contouring 反而适合处理这种情况，因为 QEF 可以保留尖锐特征。

但是数值上要注意：

```text
法线不要过度平滑
QEF 解要限制在 cell 内
退化时 fallback 到交点平均值
```

------

# 16. 你可以这样理解整个系统

你的系统可以分成三层。

------

## 第一层：隐式场层

```cpp
float value(Vec3 p);
Vec3 gradient(Vec3 p);
```

来源可以是：

```text
解析 SDF
mesh SDF
point cloud SDF
Poisson field
```

------

## 第二层：八叉树采样层

```text
在八叉树 corner / center / edge 上采样 value
判断哪里有表面
自适应细分
```

------

## 第三层：网格提取层

可以选择：

```text
Marching Cubes
Dual Contouring
Surface Nets
```

你现在用的是 Dual Contouring。

所以 SDF 最自然的位置就是第一层。

------

# 17. 最小可行实现版本

你可以先实现一个球的 SDF，然后跑通 Dual Contouring。

```cpp
float sdf(Vec3 p) {
    return length(p - Vec3(0, 0, 0)) - 1.0f;
}
```

然后八叉树范围：

```text
[-1.5, 1.5]^3
```

最大深度：

```text
6 ~ 8
```

确认可以生成球。

再实现盒子：

```cpp
float sdfBox(Vec3 p, Vec3 b) {
    Vec3 q = abs(p) - b;
    return length(max(q, Vec3(0))) + min(max(q.x, max(q.y, q.z)), 0.0f);
}
```

如果球和盒子都能被 Dual Contouring 正确提取，说明：

```text
八叉树采样
边交点
法线
QEF
网格连接
```

基本都通了。

之后再接 mesh SDF、点云 SDF、Poisson field。

------

# 18. 一句话总结

SDF 的“顺带实现”方式是：

```text
把 SDF 做成一个统一的隐式场查询接口；
八叉树只负责自适应采样；
Dual Contouring 从 SDF 的符号变化中找交点；
法线由 SDF 梯度提供；
Poisson 的结果可以转成隐式场，也可以提取 mesh 后再重新计算 SDF。
```

最推荐的工程结构是：

```cpp
ISdf
 ├── SphereSdf
 ├── BoxSdf
 ├── MeshSdf
 ├── PointCloudSdf
 └── PoissonFieldSdf
```

然后 Dual Contouring 只依赖：

```cpp
sdf.value(p)
sdf.gradient(p)
```

这样你后面无论接 procedural model、mesh、点云还是 Poisson，都不用改 Dual Contouring 主体。

---

对，你这个理解**大方向是对的**：

> 给一个网格，SDF 就是实现一个 `float sdf(Vec3 x)`，返回点 `x` 到网格表面的有符号距离。

但是要注意三件事：

1. **距离怎么求**：点到最近三角形的距离。
2. **符号怎么定**：判断点在网格内还是网格外。
3. **梯度怎么算**：多数情况下可以用“点到最近点的连线方向”，但在表面上、尖角处、边界处要特殊处理。

------

# 1. Mesh 输入时，SDF 怎么实现

假设输入是三角网格：

```cpp
struct Triangle {
    Vec3 a, b, c;
};
```

对任意点 `x`，SDF 可以这样定义：

```cpp
float meshSdf(Vec3 x) {
    ClosestResult r = findClosestPointOnMesh(x);

    float unsignedDist = length(x - r.closestPoint);

    bool inside = isInsideMesh(x);

    return inside ? -unsignedDist : unsignedDist;
}
```

其中：

```cpp
struct ClosestResult {
    Vec3 closestPoint;
    int triangleIndex;
    float distance;
};
```

所以你说的：

> SDF 就是求点到网格的距离函数，自己写代码实现就行

是对的。

不过工程上不要暴力遍历所有三角形，否则采样八叉树会很慢。最好用：

```text
BVH / AABB Tree / KD-tree / Octree acceleration
```

八叉树本身也能做空间剪枝，但对三角形最近距离查询来说，BVH 通常更合适。

------

# 2. Mesh SDF 的梯度怎么算？

如果定义：

```text
φ(x) = signed distance
```

并且：

```text
外部 φ(x) > 0
内部 φ(x) < 0
```

那么在最近点唯一、且不在奇异位置时：

```text
∇φ(x) = sign * normalize(x - closestPoint)
```

其中：

```text
sign = +1  外部
sign = -1  内部
```

代码就是：

```cpp
Vec3 meshSdfGradient(Vec3 x) {
    ClosestResult r = findClosestPointOnMesh(x);

    Vec3 dir = x - r.closestPoint;
    float len = length(dir);

    if (len < 1e-8f) {
        return surfaceNormalAtClosestFeature(r);
    }

    float s = isInsideMesh(x) ? -1.0f : 1.0f;

    return s * dir / len;
}
```

这个公式很重要。

------

## 2.1 为什么里面也要乘 sign？

举个球体例子。

球的 SDF 是：

```cpp
φ(p) = length(p) - r;
```

它的梯度是：

```cpp
∇φ(p) = normalize(p);
```

也就是永远指向外侧。

如果点在球内部，比如：

```text
x = 0.5r * n
```

最近点是：

```text
c = r * n
```

那么：

```text
x - c = -0.5r * n
```

如果你直接用：

```cpp
normalize(x - c)
```

会得到：

```text
-n
```

方向是朝内的，这是错的。

因为内部 SDF 是负距离：

```text
φ(x) = -distance
```

所以梯度要乘 `-1`：

```text
∇φ = -normalize(x - c) = n
```

因此正确公式是：

```cpp
gradient = sign * normalize(x - closestPoint);
```

外部 `sign = +1`，内部 `sign = -1`。

------

# 3. 表面点上的梯度不能直接用最近点连线

Dual Contouring 里，你经常会算边交点：

```cpp
Vec3 p = edgeIntersection;
```

这个 `p` 理论上就在表面上。

这时候：

```cpp
p - closestPoint
```

接近零向量。

所以不能直接用：

```cpp
normalize(p - closestPoint)
```

这个会炸掉。

这时有三种常见做法。

------

## 方法一：用最近三角形法线

如果最近点落在某个三角形内部，可以直接用三角形法线：

```cpp
Vec3 triangleNormal(const Triangle& tri) {
    return normalize(cross(tri.b - tri.a, tri.c - tri.a));
}
```

然后保证方向是朝外的。

```cpp
Vec3 surfaceNormalAtClosestFeature(ClosestResult r) {
    Triangle tri = mesh.triangles[r.triangleIndex];
    return triangleNormal(tri);
}
```

这种适合平面网格、硬边模型。

缺点是三角形之间法线不连续。

------

## 方法二：用插值法线

如果你的 mesh 有顶点法线：

```cpp
n0, n1, n2
```

最近点在三角形内，可以用重心坐标插值：

```cpp
Vec3 n = normalize(w0 * n0 + w1 * n1 + w2 * n2);
```

这种适合光滑模型。

但是如果你要保留硬边，不要盲目插值法线。Dual Contouring 的优势就是能保留尖锐特征，过度平滑法线反而会把棱角抹掉。

------

## 方法三：有限差分

这是最通用的办法。

只要你有：

```cpp
float sdf(Vec3 p);
```

就可以用中心差分估计梯度：

```cpp
Vec3 sdfGradient(Vec3 p) {
    float eps = 1e-4f;

    float dx = sdf(p + Vec3(eps, 0, 0)) - sdf(p - Vec3(eps, 0, 0));
    float dy = sdf(p + Vec3(0, eps, 0)) - sdf(p - Vec3(0, eps, 0));
    float dz = sdf(p + Vec3(0, 0, eps)) - sdf(p - Vec3(0, 0, eps));

    return normalize(Vec3(dx, dy, dz));
}
```

对于 Dual Contouring，这个方法很好用，因为它直接给你隐式场的梯度。

但是它会调用 6 次 `sdf()`，所以比较慢。

如果你已经有最近三角形信息，可以优先用解析法线；如果没有，就用有限差分。

------

# 4. 推荐的 Mesh SDF 梯度实现

我建议你这样写：

```cpp
Vec3 meshSdfGradient(Vec3 x) {
    ClosestResult r = findClosestPointOnMesh(x);

    Vec3 dir = x - r.closestPoint;
    float dist = length(dir);

    if (dist > 1e-6f) {
        float s = isInsideMesh(x) ? -1.0f : 1.0f;
        return s * dir / dist;
    }

    // x 已经非常接近表面，此时用表面法线
    return surfaceNormalAtClosestFeature(r);
}
```

然后在 Dual Contouring 里面：

```cpp
Vec3 p = edgeIntersection;
Vec3 n = meshSdfGradient(p);
qef.add(p, n);
```

不过如果 `p` 非常靠近表面，`meshSdfGradient(p)` 会进入 `surfaceNormalAtClosestFeature()`，这是合理的。

------

# 5. 最近点落在边或顶点怎么办？

这是一个容易忽略的点。

点到三角形的最近点可能落在：

```text
1. 三角形内部
2. 三角形边上
3. 三角形顶点上
```

如果落在三角形内部，法线很好办。

如果落在边或顶点，就会有多个三角形共享这个 feature。

这时可以用：

```text
angle-weighted pseudo normal
```

简单说就是：

```cpp
Vec3 normal = normalize(sum(weight_i * faceNormal_i));
```

其中 `weight_i` 可以用该面在这个顶点处的夹角，或者简单平均。

例如顶点法线：

```cpp
Vec3 vertexNormal(int vertexIndex) {
    Vec3 n(0, 0, 0);

    for (Triangle tri : adjacentTriangles(vertexIndex)) {
        float angle = cornerAngle(tri, vertexIndex);
        n += angle * triangleNormal(tri);
    }

    return normalize(n);
}
```

边法线可以平均相邻两个面的法线：

```cpp
Vec3 edgeNormal(int edgeIndex) {
    Vec3 n(0, 0, 0);

    for (Triangle tri : adjacentTriangles(edgeIndex)) {
        n += triangleNormal(tri);
    }

    return normalize(n);
}
```

如果你不想一开始搞复杂，先用最近三角形法线也可以。

但是后面如果发现边缘抖动、符号错、法线不稳定，再加 pseudo normal。

------

# 6. inside / outside 怎么判断？

Mesh SDF 的“signed”部分取决于内外判断。

如果 mesh 是封闭的，可以用射线法：

```text
从 x 发出一条射线
统计与 mesh 的交点数
奇数：内部
偶数：外部
```

伪代码：

```cpp
bool isInsideMesh(Vec3 x) {
    Ray ray;
    ray.origin = x;
    ray.direction = Vec3(1, 0, 0);

    int hitCount = 0;

    for each triangle:
        if (rayIntersectsTriangle(ray, triangle)) {
            hitCount++;
        }

    return hitCount % 2 == 1;
}
```

但是射线法有退化问题，比如刚好穿过顶点、边，会出现重复计数。

工程上可以：

```text
1. 射线方向加一点随机扰动
2. 多射线投票
3. 使用 winding number
```

如果 mesh 不封闭，那严格意义上的 inside / outside 是不可靠的。

这种情况下你只能做：

```text
unsigned distance field
```

或者用局部法线做近似符号：

```cpp
float sign = dot(x - closestPoint, closestNormal) >= 0 ? 1.0f : -1.0f;
```

也就是：

```cpp
float sdf = sign * length(x - closestPoint);
```

但这只是近似，遇到开口、薄片、自交会出问题。

------

# 7. 点云输入时，不能简单理解成“最近点距离”

你说：

> 如果输入的是点云，直接寻找最近点和法向即可

这个说法**可以作为最简版本**，但要稍微修正一下。

点云没有连续表面，所以：

```cpp
length(x - nearestPoint)
```

不一定是点到表面的距离。

更常用的是用最近点的切平面近似 SDF。

假设最近点是：

```cpp
p
```

法线是：

```cpp
n
```

那么局部 SDF 近似为：

```text
φ(x) = dot(x - p, n)
```

代码：

```cpp
float pointCloudSdf(Vec3 x) {
    PointSample s = findNearestPoint(x);

    return dot(x - s.position, s.normal);
}
```

梯度就是：

```cpp
Vec3 pointCloudSdfGradient(Vec3 x) {
    PointSample s = findNearestPoint(x);
    return normalize(s.normal);
}
```

这就是最简版本。

------

# 8. 为什么点云 SDF 用 dot，而不是 length？

看这个图：

```text
       x
       |
       |
-------p-------- surface tangent plane
       n
```

如果点 `x` 沿法线方向偏离表面，那么：

```cpp
dot(x - p, n)
```

就是点到局部切平面的有符号距离。

而：

```cpp
length(x - p)
```

是点到采样点的欧氏距离。

如果 `x` 是沿切线方向偏离 `p`，比如：

```text
x -------- p
```

这时 `length(x - p)` 很大，但它可能仍然在表面附近。

所以点云近似 SDF 应该用：

```cpp
dot(x - p, n)
```

而不是：

```cpp
sign * length(x - p)
```

------

# 9. 更稳的点云 SDF：多个邻域点加权

只用最近点会不稳定，尤其点云稀疏时会出现跳变。

更好的做法是找 `k` 个邻近点：

```cpp
auto neighbors = kNearestPoints(x, k);
```

然后加权平均：

```text
φ(x) = Σ w_i * dot(x - p_i, n_i) / Σ w_i
```

其中：

```text
w_i = exp(-||x - p_i||² / h²)
```

代码：

```cpp
float pointCloudSdf(Vec3 x) {
    auto neighbors = kNearestPoints(x, 16);

    float sumW = 0.0f;
    float sumD = 0.0f;

    for (auto& s : neighbors) {
        Vec3 diff = x - s.position;

        float r2 = dot(diff, diff);
        float w = exp(-r2 / (h * h));

        float d = dot(diff, s.normal);

        sumW += w;
        sumD += w * d;
    }

    if (sumW < 1e-8f) {
        return 1e9f;
    }

    return sumD / sumW;
}
```

梯度可以用加权法线：

```cpp
Vec3 pointCloudSdfGradient(Vec3 x) {
    auto neighbors = kNearestPoints(x, 16);

    Vec3 n(0, 0, 0);
    float sumW = 0.0f;

    for (auto& s : neighbors) {
        float r2 = length2(x - s.position);
        float w = exp(-r2 / (h * h));

        n += w * s.normal;
        sumW += w;
    }

    return normalize(n / sumW);
}
```

这个比单个最近点稳定很多。

------

# 10. 点云 SDF 的关键前提：法线方向必须一致

点云版本最怕的是法线方向乱。

比如一部分法线朝外：

```text
n
```

另一部分法线朝内：

```text
-n
```

那么：

```cpp
dot(x - p, n)
```

的符号就会乱掉。

所以点云输入必须先处理：

```text
1. 估计法线
2. 法线一致化
3. 统一朝外
```

否则你的 SDF 会出现一块正一块负，Dual Contouring 会产生很多错误面片。

------

# 11. Mesh SDF 和 Point Cloud SDF 的区别

简单对比一下：

```text
Mesh SDF:
    φ(x) = ± distance(x, mesh)
    梯度 ≈ sign * normalize(x - closestPoint)

Point Cloud SDF:
    φ(x) ≈ dot(x - nearestPoint, nearestNormal)
    梯度 ≈ nearestNormal
```

更准确地说：

```text
Mesh 是真正的几何表面，所以可以求真实距离。

点云只是离散样本，所以通常用局部切平面近似距离。
```

------

# 12. 你在 Dual Contouring 里面实际需要什么？

Dual Contouring 不一定要求你有完美 SDF。

它真正需要的是 Hermite 数据：

```text
交点 p
法线 n
```

也就是：

```cpp
qef.add(p, n);
```

SDF 只是帮你找交点和法线的一种方式。

对于一条边：

```cpp
Vec3 a, b;
float va = sdf(a);
float vb = sdf(b);
```

如果：

```cpp
va * vb < 0
```

说明表面穿过这条边。

交点：

```cpp
float t = va / (va - vb);
Vec3 p = a + t * (b - a);
```

法线：

```cpp
Vec3 n = sdfGradient(p);
```

然后加入 QEF：

```cpp
qef.add(p, n);
```

所以你的 SDF 接口可以非常简单：

```cpp
struct SdfField {
    float value(Vec3 p);
    Vec3 gradient(Vec3 p);
};
```

------

# 13. 最推荐的实现方式

你可以做一个统一接口：

```cpp
class ISdf {
public:
    virtual float value(const Vec3& p) const = 0;
    virtual Vec3 gradient(const Vec3& p) const = 0;
};
```

Mesh 版本：

```cpp
class MeshSdf : public ISdf {
public:
    Mesh mesh;
    BVH bvh;

    float value(const Vec3& x) const override {
        ClosestResult r = bvh.closestPoint(x);

        float d = length(x - r.closestPoint);
        float s = isInsideMesh(x) ? -1.0f : 1.0f;

        return s * d;
    }

    Vec3 gradient(const Vec3& x) const override {
        ClosestResult r = bvh.closestPoint(x);

        Vec3 dir = x - r.closestPoint;
        float d = length(dir);

        if (d > 1e-6f) {
            float s = isInsideMesh(x) ? -1.0f : 1.0f;
            return s * dir / d;
        }

        return surfaceNormalAtClosestFeature(r);
    }
};
```

点云版本：

```cpp
class PointCloudSdf : public ISdf {
public:
    PointCloud cloud;
    KDTree kdtree;

    float value(const Vec3& x) const override {
        auto neighbors = kdtree.kNearest(x, 16);

        float sumW = 0.0f;
        float sumD = 0.0f;

        for (auto& s : neighbors) {
            Vec3 diff = x - s.position;

            float r2 = dot(diff, diff);
            float w = exp(-r2 / (h * h));

            float d = dot(diff, s.normal);

            sumW += w;
            sumD += w * d;
        }

        return sumD / sumW;
    }

    Vec3 gradient(const Vec3& x) const override {
        auto neighbors = kdtree.kNearest(x, 16);

        Vec3 n(0, 0, 0);
        float sumW = 0.0f;

        for (auto& s : neighbors) {
            float r2 = length2(x - s.position);
            float w = exp(-r2 / (h * h));

            n += w * s.normal;
            sumW += w;
        }

        return normalize(n / sumW);
    }
};
```

------

# 14. 最简结论

你的理解可以改成下面这个更准确的版本：

```text
如果输入是封闭三角网格：
    SDF(x) = 点 x 到最近三角形的距离，加上 inside/outside 符号。
    梯度一般是 sign * normalize(x - closestPoint)。
    如果 x 在表面上，则用最近三角形法线、插值法线、pseudo normal，或者有限差分。

如果输入是点云 + 法线：
    不建议直接用点到最近点的欧氏距离。
    更常用的是局部切平面近似：
        SDF(x) = dot(x - p, n)
    梯度就是 n。
    更稳定的做法是对多个邻近点做加权平均。
```

所以对于你的 Dual Contouring 来说，核心接口就是：

```cpp
float value = sdf.value(p);
Vec3 normal = sdf.gradient(p);
```

Mesh、点云、Poisson 场都可以包成这个接口，Dual Contouring 主体不用变。
