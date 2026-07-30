const std = @import("std");
const expect = std.testing.expect;
const dprint = std.debug.print;

const TestError = error{TestError};
const AnotherError = error{AnotherError};

// 辅助函数
fn mayFail() TestError!i32 {
    const val: i32 = 42;
    return val;
}

// 验证1: callconv(.c)小写语法
test "callconv lowercase syntax" {
    // 验证Zig 0.16.0使用callconv(.c)而不是callconv(.C)
    const FnType = fn () callconv(.c) void;

    const exampleFn: FnType = struct {
        fn example() callconv(.c) void {
            // 空函数
        }
    }.example;

    _ = exampleFn;
    try expect(true);
}

// 验证2: try catch不需要|_|
test "try catch without underscore" {
    // 在Zig 0.16.0中，try catch不需要捕获值
    const result = mayFail() catch blk: {
        break :blk @as(i32, 0);
    };

    try expect(result == 42);
}

// 验证2b: union类型错误处理
test "union error handling" {
    const Result = union(enum) {
        success: i32,
        failure: []const u8,
    };

    var success_result: Result = undefined;
    success_result = Result{ .success = 42 };

    if (success_result == .success) {
        try expect(success_result.success == 42);
    }
}

// 验证3: switch不需要|_|
test "switch without underscore" {
    const Value = union(enum) {
        int: i32,
        float: f64,
    };

    const value = Value{ .int = 42 };

    // Zig 0.16.0中switch也不需要捕获未使用的值
    const result = switch (value) {
        .int => |v| v + 1,
        .float => |v| @as(i32, @intFromFloat(v)),
    };

    try expect(result == 43);
}

// 验证4: for循环需要|_|
test "for loop requires underscore" {
    const array = [_]i32{1, 2, 3, 4, 5};
    var sum: i32 = 0;

    // for循环中如果忽略捕获值，必须写|_|
    for (array) |_| {
        sum += 1;
    }

    try expect(sum == 5);
}

// 验证5: 类型直接比较
test "type direct comparison" {
    // Zig语言type类型可以直接比较判断
    const i32_type: type = i32;
    const another_i32: type = i32;

    try expect(i32_type == another_i32);
    try expect(i32_type != f32);
}

// 验证6: @as与@intCast的区别
test "as vs intCast" {
    // @as用于在编译时明确指定类型，不修改数据位
    const literal_as_u32: u32 = @as(u32, 1234);

    // @intCast用于数值类型转换，检查范围
    const small: i8 = 100;
    const casted: i32 = @intCast(small);

    try expect(literal_as_u32 == 1234);
    try expect(casted == 100);

    // @as配合@intCast用于字面量转换
    const result: u32 = @as(u32, @intFromFloat(@as(f32, 1.5)));
    try expect(result == 1);
}

// 验证7: 数值隐式转换规则
test "numeric implicit conversion" {
    // 从小范围类型向大范围类型可以隐式转换
    const u8_val: u8 = 255;
    const u16_val: u16 = u8_val; // 可以隐式转换
    const u32_val: u32 = u16_val; // 可以隐式转换

    try expect(u32_val == 255);

    // 浮点数可以隐式转换到更高精度
    const f32_val: f32 = 3.14;
    const f64_val: f64 = f32_val;

    try expect(@abs(f64_val - 3.14) < 0.001);
}

// 验证8: usize和isize不能隐式转换
test "usize isize no implicit conversion" {
    // usize和isize之间不能隐式转换，因为只有交集没有包含关系
    const usize_val: usize = 100;

    // 需要显式转换
    const isize_val: isize = @intCast(usize_val);

    try expect(isize_val == 100);
}

// 验证9: 整数模运算溢出
test "integer modulo overflow handling" {
    // 正确的写法：(i+len-j)%len 而不是 (i-j+len)%len
    const i: usize = 5;
    const j: usize = 10;
    const len: usize = 20;

    // 错误的写法会导致溢出：i-j会是负数
    // const wrong_result = (i - j + len) % len; // 溢出！

    // 正确的写法
    const correct_result = (i + len - j) % len;

    try expect(correct_result == 15);
}

// 验证10: @mod和@divFloor的数学性质
test "mod and divFloor properties" {
    const c: isize = 19;
    const d: isize = 11;

    const b = @mod(c, d);
    const bb = @divFloor(c, d);

    // @mod保证结果非负，且bb*d+b=c
    try expect(b >= 0);
    try expect(bb * d + b == c);

    dprint("mod result: {}, divFloor result: {}\n", .{ b, bb });
}

// 验证11: tuple的创建和访问
test "tuple creation and access" {
    const a = .{
        @as(u32, 1234),
        @as(f64, 12.34),
        true,
        "hi",
    } ++ .{false} ** 2;

    // tuple成员可以访问
    try expect(a[0] == 1234);
    try expect(@abs(a[1] - 12.34) < 0.001);
    try expect(a[2] == true);
    try expect(std.mem.eql(u8, a[3], "hi"));
    try expect(a[4] == false);
    try expect(a[5] == false);

    dprint("tuple 0: {}\n", .{a[0]});
}

// 验证12: tuple成员不可修改
test "tuple members immutable" {
    const a = .{
        @as(u32, 1234),
        @as(f64, 12.34),
    };

    // tuple成员变量无法修改，a是常量
    // a[0] = 5678; // 编译错误！

    try expect(a[0] == 1234);
}

// 验证13: inline for访问tuple成员
test "inline for tuple iteration" {
    const tuple = .{
        @as(u32, 1),
        @as(u32, 2),
        @as(u32, 3),
    };

    var sum: u32 = 0;
    inline for (tuple) |value| {
        sum += value;
    }

    try expect(sum == 6);
}

pub fn main() !void {
    dprint("Language tips verification completed!\n", .{});
}