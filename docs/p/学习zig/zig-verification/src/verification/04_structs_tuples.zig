const std = @import("std");
const expect = std.testing.expect;
const dprint = std.debug.print;

// 验证1: 匿名结构体的声明和初始化
test "anonymous struct declaration and initialization" {
    // 这个演示了index.md中的例子
    var value = .{
        .int = @as(u32, 1234),
        .float = @as(f64, 12.34),
        .b = true,
        .s = "hi",
    };

    // 类型推导（s的类型实际上是指向const u8数组的指针）
    const FieldType = @TypeOf(value.s);
    try expect(FieldType == *const [2:0]u8);

    try expect(value.int == 1234);
    try expect(value.float == 12.34);
    try expect(value.b == true);
    try expect(std.mem.eql(u8, value.s[0..2], "hi"));
}

// 验证2: 元组（不带变量名的匿名结构体）
test "tuple as anonymous struct without field names" {
    // 元组其实是不带字段名的匿名结构体
    const tuple = .{ "nihao", 3 };

    // 类型检查：元组是匿名结构体
    const TupleType = @TypeOf(tuple);

    // 可以通过索引访问
    try expect(tuple[0].len == 5); // "nihao"的长度是5，不是6
    try expect(tuple[1] == 3);

    // 也可以通过字段名"0", "1"等访问
    try expect(std.mem.eql(u8, tuple.@"0", "nihao"));
    try expect(tuple.@"1" == 3);

    dprint("Tuple type: {}\n", .{TupleType});
}

// 验证3: **和++运算符需要编译期已知
test "compile time required for ** and ++" {
    // ** 运算符需要编译期已知
    const array1 = [_]u16{0} ** 10; // 编译期已知
    try expect(array1.len == 10);
    try expect(array1[5] == 0);

    // ++ 运算符也需要编译期已知（数组连接）
    const array2 = [_]u16{1, 2} ++ [_]u16{3, 4}; // 编译期已知
    try expect(array2.len == 4);
    try expect(array2[0] == 1);
    try expect(array2[3] == 4);

    // 演示不能用运行时值
    // const runtime_len: usize = 5;
    // const array3 = [_]u16{0} ** runtime_len; // 这会报错
}

// 验证4: 结构体内存布局优化
const RB_Node = struct {
    key: i32,
    left: ?*RB_Node,
    right: ?*RB_Node,
    parent: ?*RB_Node,
    color: bool,
};

test "struct memory layout optimization" {
    dprint("RB node size: {}\n", .{@sizeOf(RB_Node)});
    dprint("Size of RB_Node: {}\n", .{@sizeOf(RB_Node)});
    dprint("Offset of key: {}\n", .{@offsetOf(RB_Node, "key")});
    dprint("Offset of left: {}\n", .{@offsetOf(RB_Node, "left")});
    dprint("Offset of right: {}\n", .{@offsetOf(RB_Node, "right")});
    dprint("Offset of parent: {}\n", .{@offsetOf(RB_Node, "parent")});
    dprint("Offset of color: {}\n", .{@offsetOf(RB_Node, "color")});

    // 从输出可以看到，Zig确实进行了内存布局优化：
    // - color (bool, 1字节) 被放在最后偏移28
    // - 指针字段 (left, right, parent) 被优化排列在偏移0, 8, 16
    // - key (i32, 4字节) 被放在偏移24
    // 总大小为32字节

    // Zig会自动优化内存布局，重新排列字段顺序
    try expect(@sizeOf(RB_Node) == 32);

    // 验证指针字段的大小和对齐
    try expect(@sizeOf(?*RB_Node) == 8); // 指针大小是8字节（64位系统）
}

// 验证5: 结构体字段顺序
test "struct field ordering" {
    const MyStruct = struct {
        a: u8,
        b: u32,
        c: u8,
    };

    dprint("MyStruct size: {}\n", .{@sizeOf(MyStruct)});
    dprint("Offset a: {}\n", .{@offsetOf(MyStruct, "a")});
    dprint("Offset b: {}\n", .{@offsetOf(MyStruct, "b")});
    dprint("Offset c: {}\n", .{@offsetOf(MyStruct, "c")});

    // 从输出可以看到，Zig重新排列了字段以优化内存布局：
    // - b (u32, 4字节) 在偏移0，与后面的padding优化对齐
    // - a (u8, 1字节) 在偏移4
    // - c (u8, 1字节) 在偏移5
    // 总大小为8字节，包含了padding

    // 验证Zig确实重新排列了字段
    try expect(@sizeOf(MyStruct) == 8);

    // 验证b字段被放在了前面（偏移0）以优化对齐
    try expect(@offsetOf(MyStruct, "b") == 0);
}

// 验证6: 函数参数使用匿名结构体类型
fn processAnonymousStruct(args: struct {
    int: u32,
    float: f64,
    b: bool,
}) void {
    dprint("Processing: int={}, float={}, bool={}\n", .{ args.int, args.float, args.b });
}

test "anonymous struct as function parameter" {
    processAnonymousStruct(.{
        .int = 100,
        .float = 3.14,
        .b = false,
    });
}

// 验证7: 复杂的元组操作
test "tuple operations" {
    const tuple1 = .{ 1, 2, 3 };
    const tuple2 = .{ "a", "b" };

    try expect(tuple1.len == 3);
    try expect(tuple2.len == 2);

    // 元组可以通过索引访问
    try expect(tuple1[0] == 1);
    try expect(tuple1[1] == 2);
    try expect(tuple1[2] == 3);

    // 也可以通过数字命名字段访问
    try expect(tuple1.@"0" == 1);
    try expect(tuple1.@"1" == 2);
    try expect(tuple1.@"2" == 3);
}

// 用于数组初始化测试的辅助结构体和函数
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

// 验证8: 数组初始化的多种方式
test "array initialization patterns" {
    // 使用 ** 运算符创建重复数组
    const all_zero = [_]u16{0} ** 10;
    try expect(all_zero.len == 10);
    try expect(all_zero[0] == 0);

    // 使用 ++ 运算符连接数组
    const combined = [_]u32{1, 2} ++ [_]u32{3, 4};
    try expect(combined.len == 4);
    try expect(combined[2] == 3);

    // 使用函数初始化数组
    const more_points = [_]Point{makePoint(3)} ** 10;
    try expect(more_points[4].x == 3);
    try expect(more_points[4].y == 6);
}

pub fn main() !void {
    dprint("Structs and tuples verification completed!\n", .{});
}
