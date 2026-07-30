const std = @import("std");
const expect = std.testing.expect;
const dprint = std.debug.print;

// 验证1: std.testing.allocator的基本用法
test "std.testing.allocator basic usage" {
    const allocator = std.testing.allocator;

    // 分配一个整数
    const ptr = try allocator.create(i32);
    defer allocator.destroy(ptr);

    ptr.* = 42;
    try expect(ptr.* == 42);
}

// 验证2: 内存泄漏检测的基本概念
test "memory leak detection concept" {
    const allocator = std.testing.allocator;

    // 演示内存分配和释放的正确配对
    const ptr1 = try allocator.create(i32);
    allocator.destroy(ptr1); // 立即释放

    const ptr2 = try allocator.create(i32);
    defer allocator.destroy(ptr2); // 使用defer确保释放
    ptr2.* = 42;

    // 测试框架会检测内存泄漏
    try expect(ptr2.* == 42);
}

// 验证3: 分配器的类型
test "allocator type" {
    const allocator = std.testing.allocator;

    // 分配器是std.mem.Allocator类型
    try expect(@TypeOf(allocator) == std.mem.Allocator);

    // 分配器包含分配和释放函数
    const ptr = try allocator.create(i32);
    defer allocator.destroy(ptr);

    ptr.* = 100;
    try expect(ptr.* == 100);
}

// 验证4: 使用分配器创建数组
test "allocate array with allocator" {
    const allocator = std.testing.allocator;

    const array_len = 10;
    const array = try allocator.alloc(i32, array_len);
    defer allocator.free(array);

    try expect(array.len == array_len);

    // 初始化数组
    for (array, 0..) |*item, i| {
        item.* = @intCast(i);
    }

    try expect(array[0] == 0);
    try expect(array[9] == 9);
}

// 验证5: 动态数组的使用
test "dynamic array usage" {
    const allocator = std.testing.allocator;

    // 分配一个数组
    var array = try allocator.alloc(i32, 10);
    defer allocator.free(array);

    // 使用数组
    for (array, 0..) |*item, i| {
        item.* = @intCast(i);
    }

    try expect(array[0] == 0);
    try expect(array[9] == 9);

    // 可以重新分配
    const new_array = try allocator.realloc(array, 20);
    array = new_array;

    try expect(array.len == 20);
    try expect(array[9] == 9); // 原有数据保持
}

// 验证6: 分配器的不同类型
test "different allocator types" {
    // std.testing.allocator 是最常用的测试分配器
    const testing_allocator = std.testing.allocator;

    // std.heap.page_allocator 用于大块内存分配
    const page_allocator = std.heap.page_allocator;

    // 它们都是相同的类型
    try expect(@TypeOf(testing_allocator) == std.mem.Allocator);
    try expect(@TypeOf(page_allocator) == std.mem.Allocator);

    // 使用page_allocator分配内存
    const page_ptr = try page_allocator.create(i32);
    defer page_allocator.destroy(page_ptr);

    page_ptr.* = 200;
    try expect(page_ptr.* == 200);
}

// 验证7: 自定义分配器的基本概念
test "custom allocator concept" {
    // Zig支持自定义分配器，但测试中主要使用标准分配器
    const allocator = std.testing.allocator;

    // 分配器包含vtable，定义了分配和释放的行为
    const ptr = try allocator.create(i32);
    defer allocator.destroy(ptr);

    ptr.* = 300;
    try expect(ptr.* == 300);

    // 不同的分配器可以有不同的策略
    // 例如：内存池分配器、堆分配器、直接内存分配器等
}

// 验证8: 分配器的resize功能
test "allocator resize" {
    const allocator = std.testing.allocator;

    // 创建初始数组
    var array = try allocator.alloc(i32, 5);
    defer allocator.free(array);

    // 初始化
    for (array, 0..) |*item, i| {
        item.* = @intCast(i);
    }

    // 尝试调整大小
    const new_array = try allocator.realloc(array, 10);
    array = new_array;

    try expect(array.len == 10);

    // 原有数据应该保持不变
    try expect(array[0] == 0);
    try expect(array[4] == 4);
}

// 验证9: 内存分配失败处理
test "allocation failure handling" {
    const allocator = std.testing.allocator;

    // 分配可能失败，返回错误
    const ptr = allocator.create(i32) catch |err| {
        // 处理分配失败
        dprint("Allocation failed: {}\n", .{err});
        return err;
    };
    defer allocator.destroy(ptr);

    ptr.* = 400;
    try expect(ptr.* == 400);
}

// 验证10: 复杂数据结构的分配
const ComplexStruct = struct {
    data: []i32,
    size: usize,

    fn init(allocator: std.mem.Allocator, size: usize) !ComplexStruct {
        const data = try allocator.alloc(i32, size);
        return ComplexStruct{
            .data = data,
            .size = size,
        };
    }

    fn deinit(self: *ComplexStruct, allocator: std.mem.Allocator) void {
        allocator.free(self.data);
        self.* = undefined;
    }
};

test "complex struct with allocator" {
    const allocator = std.testing.allocator;

    var complex = try ComplexStruct.init(allocator, 10);
    defer complex.deinit(allocator);

    try expect(complex.size == 10);
    try expect(complex.data.len == 10);

    // 使用数据
    for (complex.data, 0..) |*item, i| {
        item.* = @intCast(i * 2);
    }

    try expect(complex.data[5] == 10);
}

// 验证11: 分配器的对齐要求
test "allocator alignment" {
    const allocator = std.testing.allocator;

    // Zig 0.16.0中使用Alignment枚举而不是整数
    const aligned_ptr = try allocator.alignedAlloc(u8, .@"16", 64);
    defer allocator.free(aligned_ptr);

    // 检查对齐
    const address = @intFromPtr(aligned_ptr.ptr);
    try expect(@rem(address, 16) == 0);

    try expect(aligned_ptr.len == 64);
}

// 验证12: 使用分配器的最佳实践
test "allocator best practices" {
    const allocator = std.testing.allocator;

    // 1. 总是配对create/destroy和alloc/free
    {
        const ptr = try allocator.create(i32);
        defer allocator.destroy(ptr);
        ptr.* = 500;
    }

    // 2. 使用defer确保清理
    {
        const array = try allocator.alloc(i32, 10);
        defer allocator.free(array);

        array[0] = 100;
    } // allocator.free(array)在这里自动调用

    // 3. 为结构体提供init/deinit方法
    var managed_struct = try ComplexStruct.init(allocator, 5);
    defer managed_struct.deinit(allocator);

    try expect(managed_struct.size == 5);
}

pub fn main() !void {
    dprint("Memory allocator verification completed!\n", .{});
}
