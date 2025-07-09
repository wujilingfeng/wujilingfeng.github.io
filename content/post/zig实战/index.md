+++
author = 'libo'
date = '2025-06-20T10:36:14+08:00'
draft = false
title = 'Zig实战'

image = "nature.png"

+++



[zig语言中文社区](https://ziglang.cc/)

[zig编译为webassembly](https://luojia.me/9940/)



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

