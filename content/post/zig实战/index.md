+++
author = 'libo'
date = '2025-06-20T10:36:14+08:00'
draft = false
title = 'Zig实战'

image = "nature.png"

+++



[zig语言中文社区](https://ziglang.cc/)

[zig编译为webassembly](https://luojia.me/9940/)

https://dev.to/sleibrock/webassembly-with-zig-part-1-4onm



zig语言的type类型可以直接比较判断

```zig
pub fn normalize(p: anytype) Math_Compute_Abandon!void {
    comptime {
        const T=@TypeOf(p[0]);
        if(@TypeOf(p)!=[]T)
        {
            @compileError("normalize error\n"++@typeName(@TypeOf(p))++"fdsf");
        }
    }
    const norm = lb_norm(p);
    if (approxEqAbs(@TypeOf(p[0]), norm, 0, null)) {
        return error.Math_Compute_Abandon;
    }
    for (p) |*pv| {
        pv.* /= norm;
    }
}
```

下面是zig语言类型反射用法，包括访问struct类型，访问字段类型

```zig
fn myget_Array_rows(comptime TT: type) usize {
            return @typeInfo(TT).array.len;
        }
//下面有typeinfo的用法
pub fn mult(self: *const Self, mat: anytype) LBMatrix(T, rows, myget_Array_rows(@typeInfo(@TypeOf(mat)).@"struct".fields[0].type))



```

mat的类型如下:

```zig
struct {
        const Self = @This();

        data: [rows][cols]T,
}
```





似乎zig中的@import不能导入上层目录，也就是不能出现`..` 。那也就意味着每个子文件夹里面的zig源文件都要独立成为一个自摸块，除了依赖子文件夹，不会依赖其他文件夹的zig源文件

### comptime实战

```zig
test "inline while loop" {
    comptime var i = 0; // i 是一个编译期常量
    var sum: usize = 0; // sum 是一个运行时变量
    inline while (i < 3) : (i += 1) {
        const T = switch (i) {
            0 => f32,
            1 => i8,
            2 => bool,
            else => unreachable,
        };
        sum += typeNameLength(T); // typeNameLength 可能是一个编译期函数，用于获取类型名称的长度
    }
    try expect(sum == 9);
}
```

上面的例子中，如果i是不是comptime变量，就不能用inline while。



deepseek说只能写`try comptime` 而非comptime try ，可是下面的例子

```zig
test "peer type resolution: ?T and T" {
    try expect(peerTypeTAndOptionalT(true, false).? == 0);
    try expect(peerTypeTAndOptionalT(false, false).? == 3);
    comptime {
        try expect(peerTypeTAndOptionalT(true, false).? == 0);
        try expect(peerTypeTAndOptionalT(false, false).? == 3);
    }
}
```







zig语言的切片`[]T`可以安全地转向`[]const T` ，不需要显式转换。

下面的代码报错是因为没有确定类型导致类型推断冲突，因为x没有给类型，而-1是comptime_int,故而x是comptime_int类型，这和var冲突。

```zig

test safe_sqrt {
    var x= -1;\\这里需改为var x:f32=-1;即可修复错误
    x = x - 1;
    try std.testing.expect(safe_sqrt(x) >= 0);
}
```





一般来说zig语言的绑定库只需要@cImport()该库的暴露的.h文件即可，但是有些时候会再在上面裹上一层zig的wrapper， 比如这个[mach-glfw](https://gitee.com/wujilingfeng/mach-glfw) 里面的main分支，就是@cImport()之后又裹了一层zig。





如果zig语言想要实现类型类，只需要写个满足类型类约束的comptime函数，也就是在编译期进行类型检查是否有某些方法的判断，然后在需要添加类型类约束的函数上添加这个编译期函数判断即可。



### 编译系统

下面是编译c语言项目的构建代码，有冗余，这里的注释部分也能添加源文件，到底是cstructures_mod还是cstructures添加源文件呢？写法不统一。

```zig
const cstructures_mod = b.addModule("cstructures_mod", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = null,
    });
    // cstructures_mod.addIncludePath(b.path("cstructures/include"));
    // cstructures_mod.addCSourceFiles(.{
    //     .files = &.{"cstructures/src/tools_node.c"},
    //     .flags = &.{ "-Wall", "-O2" },
    // });
    const cstructures = b.addLibrary(.{
        .linkage = .static,
        .name = "cstructures",
        .root_module = cstructures_mod,
    });
    cstructures.addIncludePath(b.path("cstructures/include"));
    cstructures.addCSourceFiles(.{
        .files = &.{"cstructures/src/tools_node.c"},
        .flags = &.{ "-Wall", "-O2" },
    });
    cstructures.linkLibC();
```

### 导出为webassembly

```zig
const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(std.Target.Query.parse(
        .{ .arch_os_abi = "wasm32-wasi" },
    ) catch unreachable);
    const exe = b.addExecutable(.{
        .name = "main",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = b.standardOptimizeOption(.{}),
    });
    //注意这个选项
    exe.rdynamic = true; //导出该可执行对象中标记了export的项目
    // 此项默认为false，如果你需要在js环境中调用导出的方法，需要设置为true
    b.installArtifact(exe); //保存生成的结果
}
```



下面是ai生成测试用例

## 编写 Zig 代码举例

以最小 Hello World 为例：

```
// main.zig
const std = @import("std");

export fn add(a: i32, b: i32) i32 {
    return a + b;
}
```

**说明**:

- `export` 标记表明该函数将被导出到 WASM 模块，从 JS 里可调用。

------

## 编写 build.zig

build.zig 是使用 Zig 提供构建脚本功能的新式方法。下面以导出 WASM 的例子说明：

```
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{ .arch = .wasm32, .os_tag = .freestanding }
    });
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zighello",
        .root_source_file = .{ .path = "main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // 控制输出为 WebAssembly (wasm)
    exe.setOutputFile("zighello.wasm");

    // 一般来说，Web 上不需要标准库
    exe.stack_size = 64 * 1024; // 可选: 设置栈大小
    exe.disable_stack_protector = true; // 可选: 关闭栈保护

    b.default_step.dependOn(&exe.step);
}
```

**参数说明**:

- `target` 选用了 `.wasm32` 和 `.freestanding` (面向浏览器用freestanding。若需要标准库，如文件io，则用 `.wasm32-wasi`)
- `addExecutable` 制作出可执行 WASM, 并命名和指向源代码
- `.setOutputFile` 明确指定输出文件名
- `default_step.dependOn` 确保执行默认构建流程

### 编译命令

在含有 build.zig 的目录下运行：

```
sh
zig build
```

正常情况下会输出 `zighello.wasm` 文件。

------

## 用 JavaScript 加载 WASM

最基础的 JS 加载代码如下：

```
jsfetch('zighello.wasm')
  .then(response => response.arrayBuffer())
  .then(bytes => WebAssembly.instantiate(bytes))
  .then(results => {
      // zighello.wasm 里由 zig export 的函数
      const add = results.instance.exports.add;
      console.log('zig add:', add(33, 44)); // 输出 77
  });
```

**注意事项**

- 用 `wasm32-freestanding` 方式 Zig 标准库很多功能不可用（如I/O）
- 若常用 Zig 标准库（如console打印、文件IO），应将目标置为 `wasm32-wasi`，并在 Node/服务器侧WASI环境执行

------

## 进阶提示

1. 与 JS 更复杂的数据交互
   - WASM 只支持数字（int、float...），字符串等需传递内存指针。
2. 编译到 `wasm32-wasi`
   - 可在 `build.zig` 里改为 `.os_tag = .wasi`，能用 [std.io](http://std.io/)、环境变量等
3. 自动产出 JS 绑定代码
   - 可用 Zig 社区 wasm-bindings 或仅用 JS Fetch 加载
4. WebAssembly 与 Zig 版本
   - 推荐使用最新 Zig 版本（如0.12.0及以上）以获得更好的 WASM 支持

------

## 参考更复杂的实际 build.zig 示例

适配多种目标，暴露参数给命令行：

```
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "demo",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.setOutputDir("dist"); // 输出到dist文件夹
    exe.setOutputFile("demo.wasm");

    b.installArtifact(exe);

    // 默认步骤
    b.default_step.dependOn(&exe.step);
}
```

------

## 常见问题

- **Q: 为什么JS调用WASM时找不到导出函数？**
  A: 需用 `export fn ...`，如果没用export明示导出，WASM模块不会暴露该函数。
- **Q: Zig标准库不能用/编译时报错？**
  A: wasmf32-freestanding下禁用 std，换用`wasm32-wasi`作为target 或手工实现基础IO。
- **Q: 如何编译为Emscripten兼容的WASM？**
  A: 目前Zig不直接输出专为Emscripten定制代码。需自己对接JS glue code。



#### 生成文档

zig生成的文档，首先安装bun，然后在文档目录下执行命令`bunx serve .`。这是因为main.js里面需要借助http获取wasm，所以直接打开index.html没用。

#### zig-gamedev项目实战

`zig build -l `列出 所有构建项目

` zig build  minimal_glfw_g` 构建该项目

`zig build -l -Dtarget=wasm32-emscripten`列出web项目。

`zig build minimal_glfw_gl-run -Dtarget=wasm32-emscripten`构建该web项目。

运行`bunx server .`运行网页。
