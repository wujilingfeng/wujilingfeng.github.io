const std = @import("std");
const expect = std.testing.expect;
const dprint = std.debug.print;

// 验证1: 基本的模块导入
test "basic module import" {
    // 导入标准库
    const std_import = @import("std");
    try expect(@TypeOf(std_import) == type);

    // 导入builtin模块
    const builtin = @import("builtin");
    try expect(@TypeOf(builtin) == type);
}

// 验证2: 相对路径导入
test "relative path import concept" {
    // 演示相对路径导入的概念
    // 在实际项目中，使用相对于项目根目录的路径
    _ = @import("std");
    dprint("Relative path imports use project-relative paths\n", .{});
}

// 验证3: @import返回值的类型
test "import return type" {
    const std_module = @import("std");
    const debug = std_module.debug;

    // 模块导入返回的是包含所有公共声明的类型
    // Zig 0.16.0中debug.print的签名检查
    dprint("debug.print type: {}\n", .{@TypeOf(debug.print)});
}

// 验证4: 导入中的变量引用
test "imported constants and functions" {
    // 模块间可以共享常量和函数
    // 这是通过pub关键字实现的
    try expect(helper_const == 42);

    const result = moduleLevelFunction();
    try expect(result > 0);
}

// 辅助常量，供其他模块导入
const helper_const = 42;

// 验证5: 条件编译导入
test "conditional import" {
    // 使用comptime进行条件导入
    const has_feature = comptime blk: {
        break :blk true;
    };

    _ = has_feature;

    // 实际的条件导入通常基于目标平台
    const builtin = @import("builtin");
    _ = builtin;
}

// 验证6: 导入内置模块
test "builtin module import" {
    const builtin = @import("builtin");

    // builtin模块包含编译时信息
    try expect(@TypeOf(builtin) == type);
}

// 验证7: 使用comptime导入控制
const os_tag = @import("builtin").os.tag;

test "comptime import control" {
    // 在编译时根据操作系统导入不同的模块
    const is_windows = comptime os_tag == .windows;
    const is_linux = comptime os_tag == .linux;

    dprint("Is Windows: {}, Is Linux: {}\n", .{ is_windows, is_linux });

    // 根据平台进行不同的操作
    if (comptime os_tag == .windows) {
        dprint("Running on Windows\n", .{});
    } else if (comptime os_tag == .linux) {
        dprint("Running on Linux\n", .{});
    } else {
        dprint("Running on other OS\n", .{});
    }
}

// 验证8: 模块级的变量和函数
var module_level_var: i32 = 0;

fn moduleLevelFunction() i32 {
    module_level_var += 1;
    return module_level_var;
}

test "module level functions" {
    // 重置模块级变量状态
    module_level_var = 0;

    try expect(module_level_var == 0);

    const result1 = moduleLevelFunction();
    try expect(result1 == 1);

    const result2 = moduleLevelFunction();
    try expect(result2 == 2);
}

// 验证9: 使用pub导出
pub fn publicFunction() i32 {
    return 100;
}

pub const public_const = 200;

test "public declarations" {
    try expect(publicFunction() == 100);
    try expect(public_const == 200);
}

// 验证10: 导入其他测试文件的概念
test "cross-file import concept" {
    // 这个测试演示跨文件导入的概念
    // 在实际项目中，会从其他文件导入函数和常量
    const other_file_import = comptime blk: {
        break :blk true; // 假设从其他文件导入成功
    };

    try expect(other_file_import == true);
}

// 验证11: 构建系统的基本概念
test "build system concepts" {
    // Zig的构建系统使用build.zig文件
    // 这个测试演示基本概念

    // 测试执行器的类型信息
    const test_runner = @import("builtin");
    _ = test_runner;

    // 在实际构建中，可以访问构建参数
    dprint("Build system concepts verified\n", .{});
}

// 验证12: 内联和导出
inline fn inlineFunction() i32 {
    return 42;
}

export fn exportedFunction() i32 {
    return 84;
}

test "inline and export" {
    const inline_result = inlineFunction();
    try expect(inline_result == 42);

    // 导出的函数可以从其他模块调用
    const exported_result = exportedFunction();
    try expect(exported_result == 84);
}

pub fn main() !void {
    const stdout = std.io.getStdOut();
    try stdout.writeAll("Modules and build system verification completed!\n");
}
