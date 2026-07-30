const std = @import("std");
const expect = std.testing.expect;
const dprint = std.debug.print;

// 验证1: orelse运算符的基本用法
test "orelse operator basic usage" {
    // 演示null和非null情况
    const optional_value: ?i32 = 42;
    const non_null = optional_value orelse 0;
    try expect(non_null == 42);

    const null_value: ?i32 = null;
    const result = null_value orelse 100;
    try expect(result == 100);
}

// 验证2: .?语法（panic if null）
test "optional unwrap with .?" {
    const optional_value: ?i32 = 42;
    const value = optional_value.?; // 不会panic
    try expect(value == 42);

    // .? 如果是null会触发panic，所以这里不演示
    // const null_value: ?i32 = null;
    // const panic_value = null_value.?; // 这行会panic
}

// 验证3: if语句解包可选类型
test "if optional unwrap" {
    const optional_value: ?i32 = 42;

    if (optional_value) |value| {
        try expect(value == 42);
    } else {
        try expect(false); // 不应该执行到这里
    }

    // 测试null情况
    const null_value: ?i32 = null;
    if (null_value) |value| {
        dprint("Unexpected value: {}\n", .{value});
        try expect(false);
    } else {
        // 正确：值为null
        try expect(true);
    }
}

// 验证4: while循环解包可选类型
var optional_counter: u32 = 0;

fn getOptionalValue() ?u32 {
    if (optional_counter < 3) {
        optional_counter += 1;
        return optional_counter;
    }
    return null;
}

test "while optional unwrap" {
    optional_counter = 0; // 重置计数器

    var iterations: u32 = 0;
    while (getOptionalValue()) |value| {
        dprint("Got value: {}\n", .{value});
        iterations += 1;
        if (iterations >= 3) break;
    } else {
        // 当返回null时执行
        dprint("Optional returned null\n", .{});
    }

    try expect(iterations == 3);
}

// 验证5: 可选类型与指针的结合
test "optional pointer types" {
    var x: i32 = 42;
    const optional_ptr: ?*i32 = &x;

    if (optional_ptr) |ptr| {
        try expect(ptr.* == 42);
        ptr.* = 100; // 可以修改指向的值
        try expect(x == 100);
    } else {
        try expect(false);
    }

    // null指针情况
    const null_ptr: ?*i32 = null;
    if (null_ptr) |ptr| {
        _ = ptr;
        try expect(false);
    } else {
        try expect(true);
    }
}

// 验证6: 可选类型的嵌套
test "nested optional types" {
    const double_optional: ??i32 = 42;

    // 解包双重可选类型
    if (double_optional) |outer| {
        if (outer) |inner| {
            try expect(inner == 42);
        } else {
            try expect(false);
        }
    } else {
        try expect(false);
    }
}

// 验证7: 可选类型的sizeof
test "optional type size" {
    // 可选类型的大小可能因对齐和优化而不同
    const opt_size = @sizeOf(?i32);
    const base_size = @sizeOf(i32);

    dprint("Size of ?i32: {}\n", .{opt_size});
    dprint("Size of i32: {}\n", .{base_size});

    // 可选类型大小至少和原类型一样大
    try expect(opt_size >= base_size);

    // 指针类型的可选类型
    try expect(@sizeOf(?*i32) >= @sizeOf(*i32));
}

// 验证8: 可选结构体
const Point = struct {
    x: f32,
    y: f32,
};

test "optional struct" {
    const optional_point: ?Point = Point{ .x = 1.0, .y = 2.0 };

    if (optional_point) |point| {
        try expect(@abs(point.x - 1.0) < 0.001);
        try expect(@abs(point.y - 2.0) < 0.001);
    } else {
        try expect(false);
    }

    // null结构体
    const null_point: ?Point = null;
    try expect(null_point == null);
}

// 验证9: orelse与catch的区别
test "orelse vs catch" {
    // orelse用于可选类型
    const optional_value: ?i32 = null;
    const orelse_result = optional_value orelse 42;
    try expect(orelse_result == 42);

    // catch用于错误联合类型
    const error_value: anyerror!i32 = error.SomeError;
    const catch_result = error_value catch 42;
    try expect(catch_result == 42);

    dprint("orelse for optional: {}\n", .{orelse_result});
    dprint("catch for error: {}\n", .{catch_result});
}

// 验证10: 可选类型的默认值
fn getNumber(should_return: bool) ?i32 {
    if (should_return) {
        return 42;
    }
    return null;
}

test "optional with default values" {
    const result1 = getNumber(true) orelse 0;
    try expect(result1 == 42);

    const result2 = getNumber(false) orelse 100;
    try expect(result2 == 100);
}

// 验证11: 忽略可选值的捕获
test "ignore optional captured value" {
    const optional_value: ?i32 = 42;

    // 使用_|忽略捕获的值
    if (optional_value) |_| {
        try expect(true); // 只关心是否非null
    } else {
        try expect(false);
    }

    const null_value: ?i32 = null;
    if (null_value) |_| {
        try expect(false);
    } else {
        try expect(true);
    }
}

// 验证12: 可选类型的实际应用场景
const User = struct {
    id: u32,
    name: []const u8,
    email: ?[]const u8, // 可选字段：用户可能没有邮箱
};

test "real world optional usage" {
    const user_with_email = User{
        .id = 1,
        .name = "Alice",
        .email = "alice@example.com",
    };

    if (user_with_email.email) |email| {
        dprint("User email: {s}\n", .{email});
        try expect(std.mem.eql(u8, email, "alice@example.com"));
    } else {
        try expect(false);
    }

    const user_without_email = User{
        .id = 2,
        .name = "Bob",
        .email = null,
    };

    if (user_without_email.email) |email| {
        _ = email;
        try expect(false);
    } else {
        dprint("User has no email\n", .{});
        try expect(true);
    }
}

// 验证13: 可选类型与noreturn的兼容性
fn alwaysFail() noreturn {
    unreachable;
}

test "optional with noreturn" {
    // noreturn可以与任何类型兼容，包括可选类型
    // 这在理论上可行，但实际使用很少
    _ = alwaysFail; // 避免未使用警告
}

// 验证14: 可选类型的比较
test "optional comparison" {
    const a: ?i32 = 42;
    const b: ?i32 = 42;
    const c: ?i32 = null;

    // 可选类型可以比较
    try expect(a == b);
    try expect(a != c);

    // 与具体值比较
    try expect(a == 42);
    try expect(c != 42);
}

pub fn main() !void {
    dprint("Optional types verification completed!\n", .{});
}
