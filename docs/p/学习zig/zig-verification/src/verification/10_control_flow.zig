const std = @import("std");
const expect = std.testing.expect;
const dprint = std.debug.print;

// 验证1: if语句的基本用法
test "if statement basic usage" {
    const x: i32 = 10;

    if (x > 5) {
        try expect(x == 10);
    } else {
        try expect(false);
    }

    // if也可以作为表达式
    const result = if (x > 5) blk: {
        break :blk "greater";
    } else blk: {
        break :blk "lesser";
    };
    try expect(std.mem.eql(u8, result, "greater"));
}

// 验证2: while循环的基本用法
test "while loop basic usage" {
    var i: usize = 0;
    while (i < 5) {
        i += 1;
    }
    try expect(i == 5);
}

// 验证3: while循环的continue表达式
test "while loop with continue expression" {
    var i: usize = 1;
    var j: usize = 1;
    while (i * j < 2000) : ({
        i *= 2;
        j *= 3;
    }) {
        const my_ij = i * j;
        try expect(my_ij < 2000);
    }
}

// 验证4: while作为表达式
fn rangeHasNumber(begin: usize, end: usize, number: usize) bool {
    var i = begin;
    return while (i < end) : (i += 1) {
        if (i == number) {
            break true;
        }
    } else false;
}

test "while as expression" {
    try expect(rangeHasNumber(0, 10, 5) == true);
    try expect(rangeHasNumber(0, 10, 15) == false);
}

// 验证5: for循环的基本用法
test "for loop basic usage" {
    const array = [5]i32{ 1, 2, 3, 4, 5 };
    var sum: i32 = 0;

    for (array) |value| {
        sum += value;
    }

    try expect(sum == 15);
}

// 验证6: for循环带索引
test "for loop with index" {
    const array = [5]i32{ 10, 20, 30, 40, 50 };
    var sum: i32 = 0;

    for (array, 0..) |value, i| {
        try expect(@TypeOf(i) == usize);
        sum += value + @as(i32, @intCast(i));
    }

    try expect(sum == 160);
}

// 验证7: switch语句的基本用法
test "switch statement basic usage" {
    const a: u64 = 10;

    const b = switch (a) {
        1, 2, 3 => 0,
        5...100 => 1,
        else => 9,
    };

    try expect(b == 1);
}

// 验证8: switch的复杂分支
test "switch with complex branches" {
    const a: u64 = 101;

    const b = switch (a) {
        1, 2, 3 => 0,
        5...100 => 1,
        101 => blk: {
            const c: u64 = 5;
            break :blk c * 2 + 1;
        },
        else => 9,
    };

    try expect(b == 11); // 5*2+1 = 11
}

// 验证9: switch的多个条件和else分支
test "switch with multiple conditions" {
    const a: u64 = 103;
    const zz: u64 = 103;

    const b = switch (a) {
        1, 2, 3 => 0,
        5...100 => 1,
        101 => 5,
        zz => zz,
        else => 9,
    };

    try expect(b == 103);
}

// 验证10: defer的基本用法
fn deferExample() !usize {
    var a: usize = 1;

    {
        defer a = 2;
        a = 1;
    }
    try expect(a == 2);

    a = 5;
    return a;
}

test "defer basics" {
    try expect((try deferExample()) == 5);
}

// 验证11: defer的执行顺序（LIFO）
test "defer execution order" {
    var x: i32 = 0;

    {
        defer x += 1; // 最后执行
        defer x += 2; // 第二执行
        defer x += 3; // 首先执行
        x = 0;
    }

    try expect(x == 6); // 0+3+2+1 = 6
}

// 验证12: errdefer的用法
fn errdeferExample() !void {
    var resource: i32 = 0;

    // errdefer只在发生错误时执行
    errdefer {
        resource = 999; // 清理资源
    }

    // 模拟错误
    return error.SomeError;
}

test "errdefer usage" {
    const result = errdeferExample();
    if (result) {
        try expect(false); // 不应该成功
    } else |err| {
        try expect(err == error.SomeError);
    }
}

// 验证13: break和continue
test "break and continue" {
    var sum: i32 = 0;
    var i: usize = 0;

    while (i < 10) {
        i += 1;
        if (i == 5) {
            continue; // 跳过i=5
        }
        if (i == 8) {
            break; // 停止循环
        }
        sum += @intCast(i);
    }

    try expect(sum == 23); // 1+2+3+4+6+7 = 23
}

// 验证14: 标签块和break
test "labeled blocks and break" {
    var y: i32 = 123;

    const x = blk: {
        y += 1;
        break :blk y;
    };

    try expect(x == 124);
    try expect(y == 124);
}

// 验证15: if语句作为表达式（复杂情况）
test "if as expression complex" {
    const p1_len = 8;
    const p2_len = 12;

    const result_max = if (p1_len > p2_len) blk: {
        break :blk p1_len;
    } else blk: {
        break :blk p2_len;
    };
    try expect(result_max == 12);
}

// 验证16: 嵌套控制结构
test "nested control structures" {
    const matrix = [3][3]i32{
        [3]i32{ 1, 2, 3 },
        [3]i32{ 4, 5, 6 },
        [3]i32{ 7, 8, 9 },
    };

    var sum: i32 = 0;
    for (matrix) |row| {
        for (row) |value| {
            if (@rem(value, 2) == 0) {
                sum += value;
            }
        }
    }

    try expect(sum == 20); // 2+4+6+8 = 20
}

// 验证17: while循环带条件解包
var optional_counter: u32 = 0;

fn getOptionalValue() ?u32 {
    if (optional_counter < 3) {
        optional_counter += 1;
        return optional_counter;
    }
    return null;
}

test "while with optional unwrap" {
    optional_counter = 0;

    var count: u32 = 0;
    while (getOptionalValue()) |_| {
        count += 1;
        if (count >= 3) break;
    } else {
        // 当返回null时执行
    }

    try expect(count == 3);
}

// 验证18: switch用于类型检查
test "switch for type checking" {
    const Value = union(enum) {
        integer: i32,
        float: f64,
        boolean: bool,
    };

    const value = Value{ .integer = 42 };

    const result = switch (value) {
        Value.integer => |v| v * 2,
        Value.float => |v| @as(i32, @intFromFloat(v)),
        Value.boolean => |v| if (v) @as(i32, 1) else 0,
    };

    try expect(result == 84);
}

// 验证19: orelse和catch在控制流程中的使用
test "orelse and catch in control flow" {
    const optional_value: ?i32 = null;
    const result = if (optional_value) |v| blk: {
        break :blk v * 2;
    } else blk: {
        break :blk 42;
    };

    try expect(result == 42);
}

// 验证20: inline for和while
test "inline for and while" {
    const values = [3]i32{ 1, 2, 3 };
    var sum: i32 = 0;

    inline for (values) |value| {
        sum += value;
    }

    try expect(sum == 6);
}

pub fn main() !void {
    dprint("Control flow verification completed!\n", .{});
}
