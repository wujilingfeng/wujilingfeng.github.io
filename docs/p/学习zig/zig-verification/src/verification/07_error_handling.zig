const std = @import("std");
const expect = std.testing.expect;
const dprint = std.debug.print;

// 错误类型定义
const FileOpenError = error{
    AccessDenied,
    OutOfMemory,
    FileNotFound,
};

const AllocationError = error{
    OutOfMemory,
};

const TestError = error{
    SomeError,
    AnotherError,
    ThirdError,
};

const FetchError = error{
    FetchFailed,
};

const ArbitraryError = error{
    ArbitraryError,
};

const MathError = error{
    DivisionByZero,
};

// 验证1: error类型的基本特性
test "error type automatic integer assignment" {
    const errort = FileOpenError.OutOfMemory;
    const err_int = @intFromError(errort);
    const err_int1 = @intFromError(AllocationError.OutOfMemory);

    dprint("error value: {}, {}\n", .{ err_int, err_int1 });

    // 不同的error集合中的相同错误应该有相同的整数值
    try expect(err_int == err_int1);
}

// 验证2: catch运算符的基本用法
fn parseU64(str: []const u8, radix: u8) !u64 {
    _ = str;
    _ = radix;
    return 42;
}

fn failingFunction() TestError!i32 {
    return error.SomeError;
}

test "catch operator basic usage" {
    const str = "123";
    const number = parseU64(str, 10) catch 13;
    try expect(number == 42);

    // 演示错误情况
    const result = failingFunction() catch 42;
    try expect(result == 42);
}

// 验证3: catch的扩展形式
test "catch extended form" {
    const result = failingFunction() catch |err| blk: {
        dprint("Caught error: {}\n", .{err});
        break :blk 42;
    };

    try expect(result == 42);
}

// 验证4: 错误联合类型的if解包
test "error union if unwrap" {
    const a: anyerror!u32 = error.AlwaysError;

    if (a) |value| {
        dprint("type a: {}\n", .{value});
        try expect(false); // 不应该执行到这里
    } else |err| {
        dprint("Caught error in if: {}\n", .{err});
        try expect(err == error.AlwaysError);
    }

    // 测试成功情况
    const b: anyerror!u32 = 42;
    if (b) |value| {
        try expect(value == 42);
    } else |err| {
        dprint("Unexpected error: {}\n", .{err});
        try expect(false);
    }
}

// 验证5: 错误联合类型的while解包
var fetch_counter: u32 = 0;

fn fetchData() FetchError!u32 {
    if (fetch_counter < 3) {
        fetch_counter += 1;
        return fetch_counter;
    } else {
        return error.FetchFailed;
    }
}

test "error union while unwrap" {
    fetch_counter = 0; // 重置计数器

    var retry: u32 = 0;
    while (fetchData()) |data| {
        dprint("Data: {}\n", .{data});
        retry += 1;
        if (retry >= 3) break; // 防止无限循环
    } else |err| {
        dprint("Error: {}\n", .{err});
        try expect(err == error.FetchFailed);
    }
}

// 验证6: 忽略捕获值
test "error union ignore captured value" {
    const a: anyerror!u32 = error.AlwaysError;

    // 使用_|忽略捕获的错误值
    if (a) |value| {
        _ = value;
        try expect(false);
    } else |_| {
        // 忽略了具体的错误
        dprint("Ignoring error value\n", .{});
    }
}

// 验证7: try关键字
fn tryFailingFunction() TestError!i32 {
    return error.ThirdError;
}

fn callingTryFunction() TestError!i32 {
    // try相当于 catch |err| return err
    const result = try tryFailingFunction();
    return result;
}

test "try keyword" {
    // 调用会传播错误
    const result = callingTryFunction() catch 42;
    try expect(result == 42);
}

// 验证8: 错误集合的合并
const CombinedError = error{
    FirstError,
    SecondError,
};

fn combinedErrorFunction() !void {
    return error.FirstError;
}

test "error set handling" {
    const result = combinedErrorFunction();
    if (result) {
        try expect(true);
    } else |err| {
        try expect(err == error.FirstError);
    }
}

// 验证9: anyerror的使用
fn anyErrorFunction(should_fail: bool) ArbitraryError!i32 {
    if (should_fail) {
        return error.ArbitraryError;
    }
    return 42;
}

test "anyerror usage" {
    const success = anyErrorFunction(false) catch 0;
    try expect(success == 42);

    const failure = anyErrorFunction(true) catch 0;
    try expect(failure == 0);
}

// 验证10: 实际的错误处理模式
const File = struct {
    data: []const u8,

    fn open(filename: []const u8) !File {
        _ = filename;
        // 模拟文件打开
        return File{ .data = "file contents" };
    }

    fn read(self: *const File) ![]const u8 {
        return self.data;
    }
};

test "real world error handling pattern" {
    const file = File.open("test.txt") catch |err| {
        dprint("Failed to open file: {}\n", .{err});
        return error.SkipZigTest;
    };

    const contents = file.read() catch |err| {
        dprint("Failed to read file: {}\n", .{err});
        return error.SkipZigTest;
    };

    dprint("File contents: {s}\n", .{contents});
}

// 验证11: 错误联合类型作为返回值
fn divide(a: f64, b: f64) MathError!f64 {
    if (b == 0) {
        return error.DivisionByZero;
    }
    return a / b;
}

test "error union as return value" {
    const result1 = divide(10.0, 2.0) catch 0;
    try expect(@abs(result1 - 5.0) < 0.001);

    const result2 = divide(10.0, 0.0) catch 0;
    try expect(result2 == 0);
}

// 验证12: 错误传播
fn propagateError() TestError!i32 {
    return error.SomeError;
}

fn callerPropagate() TestError!i32 {
    const value = try propagateError();
    return value + 1;
}

test "error propagation" {
    const result = callerPropagate() catch 999;
    try expect(result == 999);
}

pub fn main() !void {
    dprint("Error handling verification completed!\n", .{});
}
