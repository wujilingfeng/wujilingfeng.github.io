const std = @import("std");
const expect = std.testing.expect;

// 验证1: 未使用的函数不会进行语法检查（延迟分析）
fn unusedFunction() void {
    // 这个函数不会被使用，所以里面的错误不会被发现
    // const x: i32 = "string"; // 如果启用这行，应该不会报错
    // undefinedVariable += 1; // 这行也不会报错
}

// 验证2: 通过test调用的函数会被检查
fn usedFunctionWithError() void {
    const x: i32 = "this will cause error"; // 这行会报错，因为函数被使用了
    _ = x;
}

test "used function gets analyzed" {
    // 取消下面这行的注释会触发错误，因为函数被使用了
    // usedFunctionWithError();
}

// 验证3: 正确的函数可以被调用
fn correctFunction(x: i32, y: i32) i32 {
    return x + y;
}

test "correct function usage" {
    const result = correctFunction(10, 20);
    try expect(result == 30);
}

// 验证4: 泛型函数也遵循延迟分析
fn genericFunction(comptime T: type, value: T) T {
    return value;
}

// 这个泛型函数没有被使用，所以不会报错
fn unusedGeneric(comptime T: type, value: T) T {
    // some undefined variable; // 不会报错，因为函数未被使用
    return value;
}

test "generic function when used" {
    const result = genericFunction(i32, 42);
    try expect(result == 42);
}

// 验证5: 导出的函数即使未显式使用也会被分析
export fn exportedFunction() void {
    // const x: i32 = "error"; // 导出函数会被检查，因为这行会报错
}

// 验证6: pub函数在模块内可见时会被分析
pub fn publicFunction() void {
    // 如果这个函数在其他文件中被导入使用，它会被分析
}

// 验证7: 复杂的类型错误在未使用时不会被检测
fn complexUnusedFunction() SomeStruct {
    return SomeStruct{ .value = 10 };
}

const SomeStruct = struct {
    value: i32,
    method: i32,
};

test "complex unused function" {
    // 不调用这个函数，所以它的错误不会被发现
    // const result = complexUnusedFunction();
}

pub fn main() !void {
    std.debug.print("Function delayed analysis verification completed!\n", .{});
}
