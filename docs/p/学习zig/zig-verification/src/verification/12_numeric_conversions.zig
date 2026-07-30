const std = @import("std");
const expect = std.testing.expect;
const dprint = std.debug.print;

// 验证1: 低精度到高精度的隐式转换
test "implicit numeric promotion" {
    // 整数提升：小类型到大类型
    const small: i8 = 42;
    const large: i32 = small; // 隐式提升
    try expect(large == 42);

    // 浮点数提升
    const f: f32 = 3.14;
    const d: f64 = f; // 隐式提升
    try expect(@abs(d - 3.14) < 0.001);
}

// 验证2: @intCast的基本用法
test "intCast basic usage" {
    // 安全的类型转换，确保值在目标类型范围内
    const large: i32 = 100;
    const small: i8 = @intCast(large);
    try expect(small == 100);

    // 演示在范围内的值
    const safe: i32 = 50;
    const safe_result: i8 = @intCast(safe);
    try expect(safe_result == 50);
}

// 验证3: @truncate的用法
test "truncate usage" {
    // @truncate保留低位，不进行范围检查
    const big: u32 = 0x12345678;
    const small: u8 = @truncate(big);
    try expect(small == 0x78); // 只保留最低8位

    const negative_u: u32 = 0xFFFFFFFF;
    const truncated_u8: u8 = @truncate(negative_u);
    try expect(truncated_u8 == 255);
}

// 验证4: 浮点数转换
test "float conversions" {
    // f32到f64的隐式转换
    const f: f32 = 3.14159;
    const d: f64 = f;
    try expect(@abs(d - 3.14159) < 0.00001);

    // f64到f32需要显式转换
    const d2: f64 = 2.71828;
    const f2: f32 = @floatCast(d2);
    try expect(@abs(@as(f64, f2) - 2.71828) < 0.0001);
}

// 验证5: 整数和浮点数之间的转换
test "integer to float conversions" {
    // 整数到浮点数
    const i: i32 = 42;
    const f: f64 = @floatFromInt(i);
    try expect(@abs(f - 42.0) < 0.001);

    // 浮点数到整数
    const f2: f64 = 123.0;
    const i2_val: i32 = @intFromFloat(f2);
    try expect(i2_val == 123);
}

// 验证6: 有符号和无符号之间的转换
test "signed unsigned conversions" {
    // 有符号到无符号
    const signed: i32 = -1;
    const unsigned: u32 = @bitCast(signed);
    try expect(unsigned == 0xFFFFFFFF);

    // 无符号到有符号
    const u: u32 = 0xFFFFFFFF;
    const s: i32 = @bitCast(u);
    try expect(s == -1);
}

// 验证7: @intFromError
const TestError = error{
    FirstError,
    SecondError,
};

test "intFromError usage" {
    const err = TestError.FirstError;
    const err_int = @intFromError(err);
    dprint("Error as int: {}\n", .{err_int});

    // 演示错误和整数的对应关系
    try expect(err_int >= 0);
}

// 验证8: enum和整数之间的转换
const Color = enum(u8) {
    red = 0,
    green = 1,
    blue = 2,
};

test "enum and integer conversions" {
    // enum到整数
    const color = Color.blue;
    const int_value: u8 = @intFromEnum(color);
    try expect(int_value == 2);

    // 整数到enum（演示概念）
    try expect(@intFromEnum(Color.green) == 1);
}

// 验证9: 指针和整数之间的转换
test "pointer and integer conversions" {
    var value: i32 = 42;
    const ptr: *i32 = &value;

    // 指针到整数
    const addr: usize = @intFromPtr(ptr);
    try expect(addr > 0);

    // 整数到指针（危险操作）
    const ptr2: *i32 = @ptrFromInt(addr);
    try expect(ptr2.* == 42);
}

// 验证10: 不同大小的整数之间的转换
test "different size integer conversions" {
    const i8_val: i8 = 100;
    const i16_val: i16 = i8_val; // 隐式提升
    const i32_val: i32 = i16_val; // 隐式提升
    const i64_val: i64 = i32_val; // 隐式提升

    try expect(i64_val == 100);

    // 大到小需要显式转换
    const big: i64 = 100;
    const small: i8 = @intCast(big);
    try expect(small == 100);
}

// 验证11: 布尔值和整数之间的转换
test "bool and integer conversions" {
    // bool到整数
    const t: bool = true;
    const t_int: u8 = @intFromBool(t);
    try expect(t_int == 1);

    const f: bool = false;
    const f_int: u8 = @intFromBool(f);
    try expect(f_int == 0);

    // 整数到bool（需要显式转换）
    const zero: u8 = 0;
    const zero_bool: bool = zero != 0;
    try expect(zero_bool == false);

    const one: u8 = 1;
    const one_bool: bool = one != 0;
    try expect(one_bool == true);
}

// 验证12: 类型推断中的数值转换
test "type inference with numeric conversions" {
    // Zig可以推断合适的类型
    const a = 42; // 整数字面量类型
    const b = 3.14; // 浮点数字面量类型
    const c: u32 = 100;

    dprint("Type of a: {}\n", .{@TypeOf(a)});
    dprint("Type of b: {}\n", .{@TypeOf(b)});
    dprint("Type of c: {}\n", .{@TypeOf(c)});

    // 验证推断的类型
    try expect(@TypeOf(a) == comptime_int); // 整数字面量是comptime_int
    try expect(@TypeOf(b) == comptime_float); // 浮点数字面量是comptime_float
    try expect(@TypeOf(c) == u32);
}

pub fn main() !void {
    dprint("Numeric conversions verification completed!\n", .{});
}
