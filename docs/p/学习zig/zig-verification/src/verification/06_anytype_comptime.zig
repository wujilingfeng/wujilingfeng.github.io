const std = @import("std");
const expect = std.testing.expect;

// 验证1: comptime T:type用于泛型函数
fn genericFunction(comptime T: type, value: T) T {
    return value;
}

test "comptime T:type for generic functions" {
    const int_result: i32 = genericFunction(i32, 42);
    try expect(int_result == 42);

    const float_result: f64 = genericFunction(f64, 3.14);
    try expect(@abs(float_result - 3.14) < 0.001);
}

// 验证2: comptime变量的基本用法
test "comptime variables" {
    comptime var x: i32 = 1;
    x += 1;

    try expect(x == 2);

    // comptime变量在编译时就被计算
    comptime {
        var y: i32 = 10;
        y *= 2;
        try expect(y == 20);
    }
}

// 验证3: comptime块
test "comptime block" {
    const result = comptime blk: {
        const x = 1 + 2;
        const y = x * 3;
        break :blk y + 4;
    };

    try expect(result == 13); // (1+2)*3+4 = 13
}

// 验证4: inline关键字的作用
inline fn inlineFunction(x: i32) i32 {
    return x * 2;
}

test "inline keyword behavior" {
    const result = inlineFunction(21);
    try expect(result == 42);
}

// 验证5: 编译时条件编译
test "comptime conditional compilation" {
    const target = @import("builtin").target;

    const is_windows = comptime blk: {
        const result = if (target.os.tag == .windows) true else false;
        break :blk result;
    };

    _ = is_windows; // 可以在编译时使用这个条件
}

// 验证6: comptime内联循环
test "comptime loop" {
    comptime {
        var sum: i32 = 0;
        var i: i32 = 0;
        while (i < 5) : (i += 1) {
            sum += i;
        }

        try expect(sum == 10); // 0+1+2+3+4 = 10
    }
}

// 验证7: 类型信息在comptime中的使用
test "type info at comptime" {
    const Point = struct {
        x: i32,
        y: i32,
    };

    // 演示可以在编译时获取类型信息
    const info = @typeInfo(Point);
    _ = info; // 可以在编译时使用类型信息

    // 简单验证类型信息的结构
    const size = @sizeOf(Point);
    try expect(size == 8); // 两个i32字段
}

// 验证8: comptime在数组初始化中的应用
test "comptime array initialization" {
    // 使用comptime创建编译时已知大小的数组
    const array: [5]i32 = comptime blk: {
        var result: [5]i32 = undefined;
        var i: usize = 0;
        while (i < 5) : (i += 1) {
            result[i] = @intCast(i * 2);
        }
        break :blk result;
    };

    try expect(array.len == 5);
    try expect(array[0] == 0);
    try expect(array[4] == 8);
}

// 验证9: anytype的实际应用场景
const Printer = struct {
    fn print(self: *const Printer, value: anytype) void {
        _ = self;
        _ = value;
        // 在实际使用中可以在这里处理不同类型的值
    }
};

test "anytype in struct methods" {
    var printer = Printer{};
    printer.print(42);
    printer.print("hello");
    printer.print(3.14);
}

// 验证10: comptime与inline的组合
inline fn inlineComptimeCalc(comptime n: i32) i32 {
    comptime {
        var result: i32 = 0;
        var i: i32 = 0;
        while (i < n) : (i += 1) {
            result += i;
        }
        return result;
    }
}

test "inline comptime calculation" {
    const sum = inlineComptimeCalc(10);
    try expect(sum == 45); // 0+1+2+...+9 = 45
}

pub fn main() !void {
    std.debug.print("Anytype and comptime verification completed!\n", .{});
}
