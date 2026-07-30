const std = @import("std");
const expect = std.testing.expect;
const dprint = std.debug.print;

// 验证1: 数组和切片的基本区别
test "array vs slice basic difference" {
    // 数组：固定长度，值类型
    const array: [5]i32 = [5]i32{ 1, 2, 3, 4, 5 };

    // 切片：动态长度，引用类型（指针+长度）
    const slice: []const i32 = &array;

    try expect(array.len == 5);
    try expect(slice.len == 5);

    try expect(array[0] == 1);
    try expect(slice[0] == 1);
}

// 验证2: 数组不能直接转化为指针和切片
test "array cannot directly convert to pointer and slice" {
    const array: [5]i32 = [5]i32{ 1, 2, 3, 4, 5 };

    // 数组本身不能直接转化为切片
    // const slice: []const i32 = array; // 编译错误

    // 只有数组的指针才能转化为切片
    const array_ptr: *const [5]i32 = &array;
    const slice: []const i32 = array_ptr;

    try expect(slice.len == 5);
}

// 验证3: 数组初始化的多种方式
test "array initialization methods" {
    // 使用 ** 运算符创建重复数组
    const all_zero = [_]u16{0} ** 10;
    try expect(all_zero.len == 10);
    try expect(all_zero[5] == 0);

    // 使用 ++ 运算符连接数组
    const combined = [_]u32{1, 2} ++ [_]u32{3, 4};
    try expect(combined.len == 4);
    try expect(combined[2] == 3);

    // 直接初始化
    const direct = [5]i32{ 1, 2, 3, 4, 5 };
    try expect(direct.len == 5);
}

// 验证4: 使用函数初始化数组
const Point = struct {
    x: i32,
    y: i32,
};

fn makePoint(x: i32) Point {
    return Point{
        .x = x,
        .y = x * 2,
    };
}

test "array initialization with function" {
    const more_points = [_]Point{makePoint(3)} ** 10;
    try expect(more_points[4].x == 3);
    try expect(more_points[4].y == 6);
}

// 验证5: 数组和切片的指针转换
test "array and slice pointer conversions" {
    const array: [5]u8 = [5]u8{ 1, 2, 3, 4, 5 };

    // 数组的指针可以转化为切片
    const array_ptr: *const [5]u8 = &array;
    const slice: []const u8 = array_ptr;
    dprint("slice type: {}\n", .{@TypeOf(slice)});

    try expect(slice.len == 5);

    // 数组的指针也可以转化为多项指针
    const multi_ptr: [*]const u8 = &array;
    dprint("multi ptr type: {}\n", .{@TypeOf(multi_ptr)});
}

// 验证6: 切片不能直接转化为数组指针（除非编译期能确定长度）
test "slice to array pointer conversion" {
    const array: [5]u8 = [5]u8{ 1, 2, 3, 4, 5 };

    // 切片不能直接转化为数组指针
    // const array_ptr: *[5]u8 = slice; // 编译错误

    // 但如果编译期能确定切片长度，可以转化
    if (array.len == 5) {
        const slice: []const u8 = &array;
        const array_ptr: *const [5]u8 = @ptrCast(slice);
        _ = array_ptr;
    }
}

// 验证7: 单个指针转化为切片
test "single pointer to slice conversion" {
    var value: i32 = 42;
    const ptr: *i32 = &value;

    // 单个指针可以通过ptr[0..1]转化为切片
    const slice: []i32 = ptr[0..1];
    try expect(slice.len == 1);
    try expect(slice[0] == 42);
}

// 验证8: 切片创建语法
test "slice creation syntax" {
    const array: [5]i32 = [5]i32{ 1, 2, 3, 4, 5 };

    // 使用[开始..结束]语法创建切片
    const slice1: []const i32 = array[0..3];
    try expect(slice1.len == 3);
    try expect(slice1[0] == 1);
    try expect(slice1[2] == 3);

    // 使用[开始..]语法到末尾
    const slice2: []const i32 = array[2..];
    try expect(slice2.len == 3);
    try expect(slice2[0] == 3);

    // 使用[0..结束]语法从开头
    const slice3: []const i32 = array[0..3];
    try expect(slice3.len == 3);
    try expect(slice3[2] == 3);
}

// 验证9: 切片的可变性与常量性
test "slice mutability" {
    var array: [5]i32 = [5]i32{ 1, 2, 3, 4, 5 };

    // 可变切片
    var mutable_slice: []i32 = &array;
    mutable_slice[0] = 100;
    try expect(array[0] == 100);

    // 常量切片不能修改
    const const_slice: []const i32 = &array;
    // const_slice[0] = 200; // 编译错误
    try expect(const_slice[0] == 100);
}

// 验证10: 数组和切片的遍历
test "array and slice iteration" {
    const array: [5]i32 = [5]i32{ 1, 2, 3, 4, 5 };
    const slice: []const i32 = &array;

    var sum: i32 = 0;
    for (array) |value| {
        sum += value;
    }
    try expect(sum == 15);

    sum = 0;
    for (slice) |value| {
        sum += value;
    }
    try expect(sum == 15);
}

// 验证11: 使用索引遍历
test "iteration with index" {
    const array: [5]i32 = [5]i32{ 10, 20, 30, 40, 50 };

    var sum: i32 = 0;
    for (array, 0..) |value, i| {
        try expect(@TypeOf(i) == usize);
        sum += value + @as(i32, @intCast(i));
    }

    try expect(sum == 160); // (10+0)+(20+1)+(30+2)+(40+3)+(50+4) = 160
}

// 验证12: 切片的长度和容量概念
test "slice length and capacity" {
    const array: [10]i32 = [10]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const slice: []const i32 = array[0..5];

    try expect(slice.len == 5);

    // 切片没有直接的容量属性（与Go不同）
    // 但可以通过切片到数组末尾来获得"剩余容量"
}

// 验证13: 多维数组
test "multidimensional arrays" {
    const matrix: [3][4]i32 = [3][4]i32{
        [4]i32{ 1, 2, 3, 4 },
        [4]i32{ 5, 6, 7, 8 },
        [4]i32{ 9, 10, 11, 12 },
    };

    try expect(matrix[1][2] == 7);
    try expect(matrix.len == 3);
    try expect(matrix[0].len == 4);
}

// 验证14: 切片与指针的关系
test "slice internal structure" {
    const array: [5]i32 = [5]i32{ 1, 2, 3, 4, 5 };
    const slice: []const i32 = array[1..3];

    // 切片内部是指针+长度
    try expect(slice.len == 2);
    try expect(slice[0] == 2);
    try expect(slice[1] == 3);

    // 修改原数组会影响切片
    var mutable_array: [5]i32 = [5]i32{ 1, 2, 3, 4, 5 };
    const mutable_slice: []i32 = mutable_array[1..3];
    mutable_array[1] = 100;
    try expect(mutable_slice[0] == 100);
}

// 验证15: 字符串作为切片
test "strings as slices" {
    const string: []const u8 = "hello";
    try expect(string.len == 5);
    try expect(string[0] == 'h');
    try expect(string[4] == 'o');

    // 字符串字面量实际上是指针到数组
    const string_literal: *const [5:0]u8 = "hello";
    try expect(string_literal[0] == 'h');
    try expect(string_literal[4] == 'o');
    try expect(string_literal[5] == 0); // null终止符
}

pub fn main() !void {
    dprint("Arrays and slices verification completed!\n", .{});
}
