+++
author = "libo"
title = "学习zig"
date = "2025-04-28"

image = "fanchuan.png"
+++

zig语言对函数声明和定义启用延迟检查分析，也就是如果定义的函数未使用，zig编译器就不会分析检查该函数，也就更不会对该函数报错。



zig语言 的”元组“，.{"nihao",3}其实是个value, 它的类型是匿名结构体，
sdsa
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



zig语言的anytype只用于函数的参数声明。



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



zig语言的切片和数组（array）的区别似乎只是固定长度和动态长度的区别。

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



