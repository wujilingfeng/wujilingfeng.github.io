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

# zig语言tips

最新的zig当需要忽略捕获值时，除了for循环必须写|_|，其他的try catch 不用写| _ |, switch 也不用写 |_ | 。

zig的文件互相不可循环导入，如果要循环导入（彼此依赖），必须导入对方时不可见（不可声明为pub）.

也就是两个模块互相导入时不能声明为pub。

zig语言的type类型可以直接比较判断

```zig
pub fn normalize(p: anytype) Math_Compute_Abandon!void {
    comptime {
        const T=@TypeOf(p[0]);
        if(@TypeOf(p)!=[]T)
        {
            @compileError("normalize error\n" ++ 
                @typeName(@TypeOf(p)) ++ "fdsf");
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

下面是zig语言类型反射的一些用法，包括访问struct类型，访问字段类型

```zig

/// 浮点类型相关的默认容差
pub inline fn defaultTolerance(comptime T: type) T {
    return switch (@typeInfo(T)) {
        .float, .comptime_float => math.floatEps(T) * 100, // 100倍机器精度
        else => @compileError("Only floating-point types supported"),
    };
}


inline fn Sqrt(comptime T: type) type {
    return switch (@typeInfo(T)) {
        .int => |int| @Int(.unsigned, (int.bits + 1) / 2),
        else => T,
    };
}
 
```

builtin.zig的类型源码如下:

```zig
pub const Type = union(enum) {
    type,
    void,
    bool,
    noreturn,
    int: Int,
    float: Float,
    pointer: Pointer,
    array: Array,
    @"struct": Struct,
    comptime_float,
    comptime_int,
    undefined,
    null,
    optional: Optional,
    error_union: ErrorUnion,
    error_set: ErrorSet,
    @"enum": Enum,
    @"union": Union,
    @"fn": Fn,
    @"opaque": Opaque,
    frame: Frame,
    @"anyframe": AnyFrame,
    vector: Vector,
    enum_literal,

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const Int = struct {
        signedness: Signedness,
        bits: u16,
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const Float = struct {
        bits: u16,
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const Pointer = struct {
        size: Size,
        is_const: bool,
        is_volatile: bool,
        /// `null` means implicit alignment, which is equivalent to `@alignOf(child)`.
        alignment: ?usize,
        address_space: AddressSpace,
        child: type,
        is_allowzero: bool,

        /// The type of the sentinel is the element type of the pointer, which is
        /// the value of the `child` field in this struct. However there is no way
        /// to refer to that type here, so we use `*const anyopaque`.
        /// See also: `sentinel`
        sentinel_ptr: ?*const anyopaque,

        /// Loads the pointer type's sentinel value from `sentinel_ptr`.
        /// Returns `null` if the pointer type has no sentinel.
        pub inline fn sentinel(comptime ptr: Pointer) ?ptr.child {
            const sp: *const ptr.child = @ptrCast(@alignCast(ptr.sentinel_ptr orelse return null));
            return sp.*;
        }

        /// This data structure is used by the Zig language code generation and
        /// therefore must be kept in sync with the compiler implementation.
        pub const Size = enum(u2) {
            one,
            many,
            slice,
            c,
        };

        /// This data structure is used by the Zig language code generation and
        /// therefore must be kept in sync with the compiler implementation.
        pub const Attributes = struct {
            @"const": bool = false,
            @"volatile": bool = false,
            @"allowzero": bool = false,
            @"addrspace": ?AddressSpace = null,
            @"align": ?usize = null,
        };
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const Array = struct {
        len: comptime_int,
        child: type,

        /// The type of the sentinel is the element type of the array, which is
        /// the value of the `child` field in this struct. However there is no way
        /// to refer to that type here, so we use `*const anyopaque`.
        /// See also: `sentinel`.
        sentinel_ptr: ?*const anyopaque,

        /// Loads the array type's sentinel value from `sentinel_ptr`.
        /// Returns `null` if the array type has no sentinel.
        pub inline fn sentinel(comptime arr: Array) ?arr.child {
            const sp: *const arr.child = @ptrCast(@alignCast(arr.sentinel_ptr orelse return null));
            return sp.*;
        }
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const ContainerLayout = enum(u2) {
        auto,
        @"extern",
        @"packed",
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const StructField = struct {
        name: [:0]const u8,
        type: type,
        /// The type of the default value is the type of this struct field, which
        /// is the value of the `type` field in this struct. However there is no
        /// way to refer to that type here, so we use `*const anyopaque`.
        /// See also: `defaultValue`.
        default_value_ptr: ?*const anyopaque,
        is_comptime: bool,
        /// `null` means the field alignment was not explicitly specified. The
        /// field will still be aligned to at least `@alignOf` its `type`.
        alignment: ?usize,

        /// Loads the field's default value from `default_value_ptr`.
        /// Returns `null` if the field has no default value.
        pub inline fn defaultValue(comptime sf: StructField) ?sf.type {
            const dp: *const sf.type = @ptrCast(@alignCast(sf.default_value_ptr orelse return null));
            return dp.*;
        }

        /// This data structure is used by the Zig language code generation and
        /// therefore must be kept in sync with the compiler implementation.
        pub const Attributes = struct {
            @"comptime": bool = false,
            @"align": ?usize = null,
            default_value_ptr: ?*const anyopaque = null,
        };
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const Struct = struct {
        layout: ContainerLayout,
        /// Only valid if layout is .@"packed"
        backing_integer: ?type = null,
        fields: []const StructField,
        decls: []const Declaration,
        is_tuple: bool,
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const Optional = struct {
        child: type,
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const ErrorUnion = struct {
        error_set: type,
        payload: type,
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const Error = struct {
        name: [:0]const u8,
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const ErrorSet = ?[]const Error;

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const EnumField = struct {
        name: [:0]const u8,
        value: comptime_int,
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const Enum = struct {
        tag_type: type,
        fields: []const EnumField,
        decls: []const Declaration,
        is_exhaustive: bool,

        /// This data structure is used by the Zig language code generation and
        /// therefore must be kept in sync with the compiler implementation.
        pub const Mode = enum { exhaustive, nonexhaustive };
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const UnionField = struct {
        name: [:0]const u8,
        type: type,
        /// `null` means the field alignment was not explicitly specified. The
        /// field will still be aligned to at least `@alignOf` its `type`.
        alignment: ?usize,

        /// This data structure is used by the Zig language code generation and
        /// therefore must be kept in sync with the compiler implementation.
        pub const Attributes = struct {
            @"align": ?usize = null,
        };
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const Union = struct {
        layout: ContainerLayout,
        tag_type: ?type,
        fields: []const UnionField,
        decls: []const Declaration,
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const Fn = struct {
        calling_convention: CallingConvention,
        is_generic: bool,
        is_var_args: bool,
        /// TODO change the language spec to make this not optional.
        return_type: ?type,
        params: []const Param,

        /// This data structure is used by the Zig language code generation and
        /// therefore must be kept in sync with the compiler implementation.
        pub const Param = struct {
            is_generic: bool,
            is_noalias: bool,
            type: ?type,

            /// This data structure is used by the Zig language code generation and
            /// therefore must be kept in sync with the compiler implementation.
            pub const Attributes = struct {
                @"noalias": bool = false,
            };
        };

        /// This data structure is used by the Zig language code generation and
        /// therefore must be kept in sync with the compiler implementation.
        pub const Attributes = struct {
            @"callconv": CallingConvention = .auto,
            varargs: bool = false,
        };
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const Opaque = struct {
        decls: []const Declaration,
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const Frame = struct {
        function: *const anyopaque,
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const AnyFrame = struct {
        child: ?type,
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const Vector = struct {
        len: comptime_int,
        child: type,
    };

    /// This data structure is used by the Zig language code generation and
    /// therefore must be kept in sync with the compiler implementation.
    pub const Declaration = struct {
        name: [:0]const u8,
    };
};

```

似乎zig中的@import不能导入上层目录的文件，也就是不能出现`..` 。那也就意味着每个子文件夹里面的zig源文件都要独立成为一个自摸块，除了依赖子文件夹，不会依赖其他文件夹的zig源文件。

#### test函数

最新的test函数里面的打印不能使用std.debug.print函数，否则zig build test时会报错。



#### @as和作用和@intCast等其他转换函数的区别

`@as` 的核心作用是**在编译时明确指定类型**，帮助编译器理解你的意图，避免类型推断错误或歧义。所以@as本质上不会修改数据位，也不会对数据进行修改。所以一般的浮点数类型转换和整数类型转换不用@as。一般用法是`@as(f32,1)`，也就是用在字面量，也配合@intCast等转换函数，比如@as(u32,@intFromFloat(a)).

#### 数值之间的隐式转换

zig对数值之间类型可以隐式转换，但只能是从小范围的类型转换为更大类型的，不会发生数值的截断，溢出等潜在风险，所以u8类型可以隐式转换为u16，但u16不能隐式转换为u8。usize和isize之间也不能隐式转换，因为二者没有包含关系，只有交集。

#### 常见整数溢出

一般我们对索引进行整数模运算时，比如(i-j+len)%len 时会出现整数溢出，因为会先进行i-j的运算，而i,j一般都是usize,导致出现负数，故要写成(i+len-j)%len;

#### 整数整除需要注意

```zig
 const c: isize = 19;
    const d: isize = 11;
    const b = @mod(c, d);
    const bb = @divFloor(c, d);
    std.debug.print("tuple 0: {} {}\n", .{  b, bb });
```

上面这种整数和除余能保证b是大于等于0的整数，且bb*d+b=c。而一般的整除`/`对负数不能保证这个等式。

#### tuple的用法

```zig
 const a = .{
        @as(u32, 1234),
        @as(f64, 12.34),
        true,
        "hi",
    } ++ .{false} ** 2;
    // a.@"2" = false;
    std.debug.print("tuple 0:{}\n", .{a[0]});
```

请注意tuple的成员变量的值无法修改.可以配合inline for访问成员。

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
        sum += typeNameLength(T); // typeNameLength 
        //可能是一个编译期函数，用于获取类型名称的长度
    }
    try expect(sum == 9);
}
```

上面的例子中，如果i不是comptime变量，就不能用inline while。


````

zig语言的切片`[]T`可以安全地转向`[]const T` ，不需要显式转换。

下面的代码报错是因为没有确定类型导致类型推断冲突，因为x没有给类型，而-1是comptime_int,故而x是comptime_int类型，这和var冲突。

``` zig
test safe_sqrt {
    var x= -1;\\这里需改为var x:f32=-1;即可修复错误
    x = x - 1;
    try std.testing.expect(safe_sqrt(x) >= 0);
}
```
````

一般来说zig语言的绑定库只需要@cImport()该库的暴露的.h文件即可，但是有些时候会再在上面裹上一层zig的wrapper， 比如这个[mach-glfw](https://gitee.com/wujilingfeng/mach-glfw) 里面的main分支，就是@cImport()之后又裹了一层zig。

如果zig语言想要实现类型类，只需要写个满足类型类约束的comptime函数，也就是在编译期进行类型检查是否有某些方法的判断，然后在需要添加类型类约束的函数上添加这个编译期函数判断即可。

### 编译系统

zig语言编译系统的b.option是对编译命令添加选项，一般通过`zig build -Doption=content`来传递，b.addOptions是向项目程序里面的模块添加选项模块。

比如下面的例子:

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "app",
        .root_module = b.createModule(.{
            .root_source_file = b.path("app.zig"),
            .target = b.graph.host,
        }),
    });

    const version = b.option([]const u8, "version", "application version string") orelse "0.0.0";
    const enable_foo = detectWhetherToEnableLibFoo();

    const options = b.addOptions();
    options.addOption([]const u8, "version", version);
    options.addOption(bool, "have_libfoo", enable_foo);

    exe.root_module.addOptions("config", options);

    b.installArtifact(exe);
}

fn detectWhetherToEnableLibFoo() bool {
    return false;
}
```

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

# zig标准库的用法

如何打开文件夹并遍历里面的文件，代码如下:

```zig
// abs_dir_src是上面创建好的变量
var io = std.Io.Threaded.init(b.allocator, .{});
defer io.deinit();
var open_dir = std.Io.Dir.openDirAbsolute(io.io(), abs_dir_src, .{ .iterate = true }) catch |err| {
     std.debug.print("open directory failed: {}\n", .{err});
     return;
};

defer open_dir.close(io.io());
var walker = open_dir.walk(b.allocator) catch |err| {
    std.debug.print("walk directory failed: {}\n", .{err});
    return;
};
defer walker.deinit();
while (walker.next(io.io()) catch null) |entry| {
    if (!std.mem.endsWith(u8, entry.path, ".zig")) {
        continue;
    }
}
```





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
