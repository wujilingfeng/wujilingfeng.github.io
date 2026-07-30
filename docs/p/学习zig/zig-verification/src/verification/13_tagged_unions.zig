const std = @import("std");
const expect = std.testing.expect;
const dprint = std.debug.print;

// 验证1: 标记联合体(union(enum))的基本用法
const ComplexTypeTag = enum {
    ok,
    not_ok,
};

const ComplexType = union(ComplexTypeTag) {
    ok: u8,
    not_ok: void,
};

test "tagged union basic usage" {
    var c = ComplexType{ .ok = 42 };

    try expect(@TypeOf(c) == ComplexType);
    try expect(c.ok == 42);

    // 修改标记联合体的值
    c.ok = 100;
    try expect(c.ok == 100);
}

// 验证2: 在switch中修改标记联合体
test "modify tagged union in switch" {
    var c = ComplexType{ .ok = 42 };

    switch (c) {
        ComplexTypeTag.ok => |*value| {
            value.* += 1;
        },
        ComplexTypeTag.not_ok => unreachable,
    }

    try expect(c.ok == 43);
}

// 验证3: 枚举的基本用法
const Color = enum {
    red,
    green,
    blue,
};

test "enum basic usage" {
    const color = Color.red;
    try expect(@intFromEnum(color) == 0);

    const green = Color.green;
    try expect(@intFromEnum(green) == 1);
}

// 验证4: 枚举的显式值
const ColorWithValues = enum(u8) {
    red = 0,
    green = 1,
    blue = 2,
    yellow = 10,
};

test "enum with explicit values" {
    const yellow = ColorWithValues.yellow;
    try expect(@intFromEnum(yellow) == 10);

    const blue = ColorWithValues.blue;
    try expect(@intFromEnum(blue) == 2);
}

// 验证5: 枚举变量的简洁写法
const SpecialColor = enum {
    red,
    @"really red",
};

test "enum with special names" {
    const color: SpecialColor = .@"really red";
    try expect(@TypeOf(color) == SpecialColor);
}

// 验证6: @typeInfo返回的Type类型
test "typeInfo returns union(enum)" {
    const info = @typeInfo(ComplexType);

    // 验证是联合体类型的标识符
    try expect(info == .@"union");
}

// 验证7: 枚举的方法
const Direction = enum {
    north,
    south,
    east,
    west,

    fn opposite(self: Direction) Direction {
        return switch (self) {
            .north => .south,
            .south => .north,
            .east => .west,
            .west => .east,
        };
    }
};

test "enum with methods" {
    const dir = Direction.north;
    const opposite = dir.opposite();
    try expect(opposite == Direction.south);
}

// 验证8: 联合体的基本用法
const SimpleUnion = union {
    int: i32,
    float: f64,
    bool: bool,
};

test "simple union usage" {
    var value = SimpleUnion{ .int = 42 };
    try expect(value.int == 42);

    value = SimpleUnion{ .float = 3.14 };
    try expect(@abs(value.float - 3.14) < 0.001);
}

// 验证9: 联合体的内存布局
test "union memory layout" {
    const UnionWithMultipleFields = union {
        a: u8,
        b: u32,
        c: u64,
    };

    try expect(@sizeOf(UnionWithMultipleFields) >= 8);
}

// 验证10: extern联合体
const ExternalUnion = extern union {
    a: i32,
    b: f32,
};

test "extern union usage" {
    var value = ExternalUnion{ .a = 100 };
    try expect(value.a == 100);

    value.b = 3.14;
    try expect(@abs(value.b - 3.14) < 0.001);
}

// 验证11: 枚举的switch匹配
test "enum switch matching" {
    const color = Color.green;

    const result = switch (color) {
        .red => "red",
        .green => "green",
        .blue => "blue",
    };

    try expect(std.mem.eql(u8, result, "green"));
}

// 验证12: 标记联合体的完整示例
const Result = union(enum) {
    success: u32,
    failure: []const u8,
};

test "tagged union as result type" {
    const success_result = Result{ .success = 200 };
    try expect(success_result.success == 200);

    const failure_result = Result{ .failure = "something failed" };
    try expect(std.mem.eql(u8, failure_result.failure, "something failed"));
}

// 验证13: 使用opaque类型
const OpaqueType = opaque {};

test "opaque type usage" {
    // opaque类型用于类型安全，不能直接获取大小
    // 它通常作为指针使用
    const ptr: *OpaqueType = undefined;
    _ = ptr;
}

// 验证14: 嵌套的枚举和联合体
const SizeEnum = enum {
    small,
    medium,
    large,
};

const Nested = union(enum) {
    integer: SizeEnum,
    text: []const u8,
};

test "nested enum and union" {
    const nested = Nested{ .integer = .medium };
    try expect(@TypeOf(nested.integer) == SizeEnum);
    try expect(nested.integer == SizeEnum.medium);
}

pub fn main() !void {
    dprint("Tagged unions and enums verification completed!\n", .{});
}
