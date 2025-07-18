+++
author = "libo"
title = "学习zig"
date = "2025-04-28"

image = "fanchuan.png"
+++



zig语言每个变量分为const 和var，结构体成员变量（除了静态变量）的const和var是和该结构体实例相同。

zig语言对函数声明和定义启用延迟检查分析，也就是如果定义的函数未使用，zig编译器就不会分析检查该函数，也就更不会对该函数报错。

zig语言的void和c语言的void不同，c语言的void对应anyopaque,anyopaque是一个类型，而anytype是一个关键词，类似struct ,enum,fn,if, else等。void也是一个类型，它的值通常为`{}`。anyerror 是一个类型，不是关键字。

zig语言 的”元组“，.{"nihao",3}其实是个value, 它的类型是匿名结构体，

zig语言会自动对结构体的内存进行布局优化，下面的例子:

```zig
const RB_Node = struct {
    key: i32,
    left: ?*RB_Node,
    right: ?*RB_Node,
    parent: ?*RB_Node,
    color: bool,
};
dprint("rb node size:{}\n", .{@sizeOf(RB_Node)});
std.debug.print("Size of RB_Node: {}\n", .{@sizeOf(RB_Node)});
std.debug.print("Offset of key: {}\n", .{@offsetOf(RB_Node, "key")});
std.debug.print("Offset of left: {}\n", .{@offsetOf(RB_Node, "left")});
std.debug.print("Offset of right: {}\n", .{@offsetOf(RB_Node, "right")});
std.debug.print("Offset of parent: {}\n", .{@offsetOf(RB_Node, "parent")});
std.debug.print("Offset of color: {}\n", .{@offsetOf(RB_Node, "color")});

```

zig语言的anytype只用于函数的参数声明（其他都不能用，函数的返回类型也不能用anytype）。

zig 的test的函数必须是字符串，否则必须是标识符，一般和某个函数名的标识符相同，这样会作为该函数的文档测试说明。test函数的默认返回类型是错误联合类型，也就是`!void` 



[这个网页说明了一些用法](https://www.cnblogs.com/violeshnv/p/18200280)



zig语言的error类型会自动赋一个整数值

```zig
const FileOpenError = error{
    AccessDenied,
    OutOfMemory,
    FileNotFound,
};

const AllocationError = error{
    OutOfMemory,
};

pub fn main() !void {
    const errort = FileOpenError.OutOfMemory;
    const err_int = @intFromError(errort);
    const err_int1 = @intFromError(AllocationError.OutOfMemory);

    dprint("value errot:{},{}\n", .{ err_int, err_int1 });
 }
```

zig语言的catch是个二元运算符,`value = expression catch default_value;`，含义：
- 如果 `expression` 成功（返回 `T` 类型的值），则 `value` 被赋值为该值。
- 如果 `expression` 返回错误（`error` 类型），则 `value` 被赋值为 `default_value`。

如:

```zig
const number = parseU64(str, 10) catch 13;
```



在 Zig 中，`catch` 还支持一种扩展形式，允许你在捕获错误时执行自定义逻辑。这种用法的语法是：

```zig
value = expression catch |err| { /* handle error */ };
expression catch |err| return err;这个语句完全等价try。
```

错误联合类型可以用if语句解包，但必须包含else分支，否则报错，也可以用while解包，但也需要包含else分支，否则报错。

```zig
const a: anyerror!u32 = error.AlwaysError;
    if (a) |value| {
        std.debug.print("type a{}\n", .{value});
        // 处理正常值
    } else |err| {
      std.debug.print("type a{}\n", .{err});
       // 处理错误（必须显式捕获err）
    }
fn fetchData() anyerror!u32 {
    // 模拟可能失败的操作
    return if (std.crypto.random.int(u32) % 2 == 0) 42 else error.FetchFailed;
}

pub fn main() void {
    var retry: u32 = 0;
    while (fetchData()) |data| {
        std.debug.print("Data: {}\n", .{data});
        retry += 1;
        if (retry >= 3) break; // 防止无限循环
    } else |err| {
        std.debug.print("Error: {}\n", .{err});
    }
}
上面的||捕获可以是|_|，即忽略捕获值。
```





zig语言的orelse也是二元运算符，用来解包可选类型，左右两边两个表达式为执行代码，`const b= a orelse value`其中a是可选类型，b的值是当a不为null时，b为a的解包值，否则b为value。也可以用`.?`可访问非null的值（如果是null会引发panic）,`if(optional_value)|value|`是最安全的用法，while也可以解包可选类型。



zig语言的return,break,continue,unreachable，`while(true){}`属于noreturn类型的值，用法基本和c一样，return用于全局退出，break用于局部退出。所以标签块要用break退出.

zig语言的noreturn 可以和任何类型兼容，所以任何表达式都可以使用noreturn赋值，但因为是noreturn 类型，赋值操作不会执行，只会影响控制。

下面是标签块的使用，

```zig
var y: i32 = 123;

    const x = blk: {
        y += 1;
        break :blk y;
    };
```



下面展示了枚举变量的简洁写法，

```zig
const Color = enum {
    red,
    @"really red",
};
const color: Color = .@"really red";
```

容器级别变量具有静态生命周期，且顺序无关，并且是惰性分析的。容器级别变量的初始化值隐式为编译时。如果容器级别变量是const，则其值在编译时已知，否则是在运行时已知。

```zig
var y:i32=add(10,x);
const x: i32=add(12,34);
test "container level variables"{
	try expect(x==46);
	try expect(y==56);
}
fn add(a:i32,b:i32) i32{
	return a+b;
}
const std= @import("std")
const expect= std.testing.expect;

```

zig语言的const变量尽量会在编译器赋值或者初始化，尤其是在容器内的const变量只会在编译时赋值。

如果想让var变量的初始化也在编译时进行，可以

``` zig
test "comptime vars" {
    var x: i32 = 1;
    comptime var y: i32 = 1;

    x += 1;
    y += 1;

    try expect(x == 2);
    try expect(y == 2);

    if (y != 2) {
        // This compile error never triggers because y is a comptime variable,
        // and so `y != 2` is a comptime value, and this if is statically evaluated.
        @compileError("wrong y value");
    }
}
```



zig语言的切片和数组（array）的区别似乎只是固定长度和动态长度的区别。而且数组不能转化为指针和切片，只有数组的指针才能转化为切片和指向多个元素的指针。

```zig
const all_zero = [_]u16{0} ** 10;
const Point = struct {
    x: i32,
    y: i32,
};

test "compile-time array initialization" {
    try expect(fancy_array[4].x == 4);
    try expect(fancy_array[4].y == 8);
}

// call a function to initialize an array
var more_points = [_]Point{makePoint(3)} ** 10;
fn makePoint(x: i32) Point {
    return Point{
        .x = x,
        .y = x * 2,
    };
}
```

zig语言数组的初始化用法

```zig
const all_zero = [_]u16{0} ** 10;

comptime {
    assert(all_zero.len == 10);
    assert(all_zero[5] == 0);
}
const Point = struct {
    x: i32,
    y: i32,
};

test "compile-time array initialization" {
    try expect(fancy_array[4].x == 4);
    try expect(fancy_array[4].y == 8);
}

// call a function to initialize an array
var more_points = [_]Point{makePoint(3)} ** 10;
fn makePoint(x: i32) Point {
    return Point{
        .x = x,
        .y = x * 2,
    };
}
```

虽然数组和切片更相似，但是切片和数组指针存在默认转换,数组的指针可以默认转化为切片，反之不行(除非在编译阶段能确定切片长度，这样就可以把切片默认转化为数组指针)。数组指针也可以转化为多项指针。

```zig
const bytes: *const [5:0]u8 = "hello";
dprint("bytes type:{}\n", .{@TypeOf(bytes)});
    // const slice: []const u8 = "slice";
const slice: []const u8 = bytes;\\数组的指针转化为切片
 dprint("slice type:{}\n", .{@TypeOf(slice)});
 
   const array: [5]u8 = [5]u8{ 1, 2, 3, 4, 5 };
    const array_ptr = &array;
    dprint("array type:{}\n", .{@TypeOf(array_ptr)});
    const array_ptr1: [*]const u8 = &array;\\数组的指针转化为指向多个元素的指针。
    dprint("array type1:{}\n", .{@TypeOf(array_ptr1)});

```



单个的指针ptr可以通过ptr[0..1]转化为切片（但是会在编译阶段优化为数组的指针）。

```zig
var sum2: i32 = 0;
    for (items, 0..) |_, i| {
        try expect(@TypeOf(i) == usize);
        sum2 += @as(i32, @intCast(i));
    }
    
    test "switch simple" {
    const a: u64 = 10;
    const zz: u64 = 103;

    // All branches of a switch expression must be able to be coerced to a
    // common type.
    //
    // Branches cannot fallthrough. If fallthrough behavior is desired, combine
    // the cases and use an if.
    const b = switch (a) {
        // Multiple cases can be combined via a ','
        1, 2, 3 => 0,

        // Ranges can be specified using the ... syntax. These are inclusive
        // of both ends.
        5...100 => 1,

        // Branches can be arbitrarily complex.
        101 => blk: {
            const c: u64 = 5;
            break :blk c * 2 + 1;
        },

        // Switching on arbitrary expressions is allowed as long as the
        // expression is known at compile-time.
        zz => zz,
        blk: {
            const d: u32 = 5;
            const e: u32 = 100;
            break :blk d + e;
        } => 107,

        // The else branch catches everything not already captured.
        // Else branches are mandatory unless the entire range of values
        // is handled.
        else => 9,
    };

    try expect(b == 1);
}

```



在 `switch` 中，范围使用了三个点，即 `3...6`，而这个示例中，范围使用了两个点，即 `0..10`。这是因为在 switch 中，范围的两端都是闭区间，而 for 则是左闭右开。

zig语言的函数参数默认是const，即不能修改参数的值。

下面是while的用法，支持一个额外的每次运行的表达式。

```zig
test "while loop continue expression, more complicated" {
    var i: usize = 1;
    var j: usize = 1;
    while (i * j < 2000) : ({
        i *= 2;
        j *= 3;
    }) {
        const my_ij = i * j;
        try expect(my_ij < 2000);
    }
}
```

其实while也是个表达式，它的值既可以是while循环里break value返回的value，也可以是else表达式返回的值.

```zig
fn rangeHasNumber(begin: usize, end: usize, number: usize) bool {
    var i = begin;
    return while (i < end) : (i += 1) {
        if (i == number) {
            break true;
        }
    } else false;
}
```





```zig

fn myfun()!void{
	var buf: [30]u8 = undefined;
		
	//在这里try语句遇到错误会从终止函数并返回错误结果，因为stdin.readUntilDelimiterOrEof(&buf, '\n')的返回值类型为`!?[]u8`，所以
	//if语句解包的是可选类型，得到|line|
	if (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
	}

}
		


```



在函数的泛型参数中anytype和comptime T:type，我没有看到本质区别。

```zig
const std = @import("std");
const expect = std.testing.expect;


const ComplexTypeTag = enum {
    ok,
    not_ok,
};
const ComplexType = union(ComplexTypeTag) {
    ok: u8,
    not_ok: void,
};

test "modify tagged union in switch" {
    var c = ComplexType{ .ok = 42 };

    switch (c) {
        ComplexTypeTag.ok => |*value| value.* += 1,
        ComplexTypeTag.not_ok => unreachable,
    }

    try expect(c.ok == 43);
}
```

defer是在作用域退出时执行表达式，表达式当然可以是块（block）。defer , if , while,for ,switch关键字都是控制语句，后面如果是单个语句要加`;`, 如果是`{}`不加分号。

```zig
onst std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;

fn deferExample() !usize {
    var a: usize = 1;

    {
        defer a = 2;
        a = 1;
    }
    try expect(a == 2);

    a = 5;
    return a;
}

test "defer basics" {
    try expect((try deferExample()) == 5);
}
```



#### 内存分配器

std.testing.allocator是建议且只建议在test函数中使用的内存分配器。

```zig
test "detect leak" {
    var list = std.ArrayList(u21).init(std.testing.allocator);
    // missing `defer list.deinit();`
    try list.append('☔');

    try std.testing.expect(list.items.len == 1);
}

```



#### 数值

在 Zig 语言中，‌**低精度数值向高精度变量赋值时不需要显式转换，编译器会自动完成安全的隐式提升**‌。

在Zig语言中，‌**高精度数值赋给低精度变量需要显式转换**‌，否则会触发编译错误。@intCast`、`@truncate`、`@floatCast





#### 额外说明

经过测试，结构体内部的函数和成员变量不能重名，block的标签名可以重名（除了嵌套）。

zig的import导入模块的话，如果是直接@import 文件名的话，相对路径是相对于该导入文件的路径。

zig的defer后面语句只能是void,也就是函数或者块不能返回值。

[风格指南](https://course.ziglang.cc/engineering/style_guide)

请注意，下面的代码中a不是二维数组，它是一维数组，每个分量是切片。同理window_name是一维数组，由于切片，数组指针，指向多项的指针三者存在默认转换关系，所以window_name的每个分量是个指向多项的数组。

```zig
const a=[_][]const u8{ "src", "test", "example" }
const window_name = [1][*:0]const u8{"window name"};
```







## zig语言的构建系统

zig语言的build.zig中，每个module或者test的root_source_file只能指向一个.zig文件（必须是相对路径），不可以是路径。

**示例：**

```zig
exe.addModule("my_module", .{
    .root_source_file = .{ .path = "src/my_module" }, // 这里是目录
});
```

然后在你的代码里可以这样用：

```zig
const foo = @import("my_module/foo.zig");
const bar = @import("my_module/bar.zig");
```

### 1. `addModule`

- **作用**：创建一个模块，并将其**添加到当前包的模块集合**（`b.modules`）。
- **可见性**：**公开（public）**。这个模块会被暴露给依赖当前包的其他包（即作为 package 的“导出模块”）。
- **典型用途**：当你希望你的库/包对外暴露一个或多个模块时，使用 `addModule`。
- **调用方式**：  
  
  ```zig
  const my_mod = b.addModule("my_mod", .{ .root_source_file = ... });
  ```
- **效果**：其他包可以通过 `@import("my_mod")` 访问这个模块。

---

### 2. `createModule`

- **作用**：创建一个模块，但**不添加到包的模块集合**，仅供当前包内部使用。
- **可见性**：**私有（private）**。这个模块不会被暴露给依赖当前包的其他包。
- **典型用途**：当你只需要在当前包内部组织代码、复用代码，但不希望对外暴露时，使用 `createModule`。
- **调用方式**：  
  ```zig
  const my_private_mod = b.createModule(.{ .root_source_file = ... });
  ```
- **效果**：只能在当前包的 build 脚本中通过 `addImport` 等方式引用，外部包无法通过 `@import` 访问。

---

### 总结对比表

| 函数名         | 是否加入 b.modules | 是否对外暴露 | 用途             |
| -------------- | ------------------ | ------------ | ---------------- |
| `addModule`    | 是                 | 是           | 对外暴露的模块   |
| `createModule` | 否                 | 否           | 仅包内私有的模块 |

---

#### zig fetch

`zig fetch --save "git+https://github.com/用户/仓库.git#<commit_hash或者tag>"`

如果省掉`#<commit_hash或者tag>`就会拉取默认分支的最新的提交

```bash
zig fetch --save=glfw "git+https://github.com/glfw/glfw.git"

```

下面测试也是可以的，但是不稳定，因为分支会变动

```bash
zig fetch --save https://github.com/webui-dev/zig-webui/archive/main.tar.gz

```



如果自己手动填写url时，格式为

`https://github.com/<用户名>/<仓库名>/archive/<commit或tag>.tar.gz`



可以在build.zig中添加传递参数

```zig
const exe = b.addExecutable(...);
if (b.args) |args| {
    exe.addArgs(args); // 将构建参数传递给可执行文件
}
```

然后在程序中使用参数

```zig

pub fn main() !void {
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);
    
    // args[0]是程序名，args[1..]才是实际参数
    for (args[1..]) |arg| {
        std.debug.print("参数: {s}\n", .{arg});
    }
}
```





## 和外部（比如C）交互

```zig
const cstdio = @cImport({
    // See https://github.com/ziglang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("stdio.h");
});
pub fn main() void{

	_ = cstdio.printf("hello\n");

}
```

上面展示了引入c头文件的功能，需要在编译文件`build.zig`中添加`exe.linkLibC();`

extern关键字表示在链接时才确定的符号，一般用在zig调用外部符号

```zig
// extern声明用于声明将在链接时、静态链接时或运行时动态链接的函数。
// extern 关键字后的引号标识符指定具有该函数的库。（例如，“c”->libc.so）
// callconv 标记更改了函数的调用约定。
const WINAPI: std.builtin.CallingConvention = if (native_arch == .x86) .Stdcall else .C;
extern "kernel32" fn ExitProcess(exit_code: u32) callconv(WINAPI) noreturn;
extern "c" fn atan2(a: f64, b: f64) f64;
```

