const std = @import("std");
const expect = std.testing.expect;

// 验证1: void类型的基本特性
test "void type and its value" {
    const void_value: void = {};
    const void_value2: void = void{};
    _ = void_value;
    _ = void_value2;

    // void可以用于任何需要void的地方
    voidFunction();

    // void的实际值为{}
    try expect(@sizeOf(void) == 0);
}

fn voidFunction() void {
    // 函数返回void
}

// 验证2: void和anyopaque的区别（对应C的void）
test "void vs anyopaque" {
    // void是一个真正的类型，有确定的值{}
    const v: void = {};
    _ = v;

    // anyopaque对应C语言的void，是不透明的类型
    const opaque_ptr: *anyopaque = undefined;
    _ = opaque_ptr;

    // void可以用于函数返回，表示无返回值
    noReturnFunction();
}

fn noReturnFunction() void {
    std.debug.print("Function returns void\n", .{});
}

// 验证3: void作为泛型参数
const VoidContainer = struct {
    value: void,

    fn init() VoidContainer {
        return VoidContainer{ .value = {} };
    }
};

test "void in struct" {
    const container = VoidContainer.init();
    try expect(@TypeOf(container.value) == void);
}

// 验证4: void的sizeof为0（实际上是1字节）
test "void size" {
    try expect(@sizeOf(void) == 0); // void的大小为0
}

// 验证5: void表达式可以用于任何void类型的位置
test "void expression usage" {
    const result = if (true) {
        // 这里可以执行某些操作
        std.debug.print("Branch executed\n", .{});
    } else {
        unreachable;
    };
    _ = result;
}

// 验证6: anyopaque是不透明类型
test "anyopaque type" {
    // anyopaque用于表示未知类型的指针（类似C的void*）
    var x: i32 = 42;
    const opaque_ptr: *anyopaque = &x;

    // 需要重新转换回具体类型才能使用，同时需要对齐转换
    const i32_ptr: *i32 = @alignCast(@ptrCast(opaque_ptr));
    try expect(i32_ptr.* == 42);
}

// 验证7: void表达式的正确用法
test "void expression usage in conditional" {
    const should_print = true;
    if (should_print) {
        std.debug.print("Conditional executed\n", .{});
    }

    // void可以用于忽略返回值
    const result: i32 = 42;
    _ = result; // 显式忽略
}

// 验证8: compare anyopaque and void
test "anyopaque vs void comparison" {
    // void是Zig的独特类型，有具体值{}
    const v: void = {};
    _ = v;

    // anyopaque对应C的void*，是不透明指针类型
    var number: i32 = 10;
    const opaque_ptr: *anyopaque = &number;
    _ = opaque_ptr;

    // void不是指针类型
    try expect(@sizeOf(void) == 0);
    // anyopaque指针有大小
    try expect(@sizeOf(*anyopaque) == @sizeOf(usize));
}

pub fn main() !void {
    std.debug.print("Void type verification completed!\n", .{});
}
