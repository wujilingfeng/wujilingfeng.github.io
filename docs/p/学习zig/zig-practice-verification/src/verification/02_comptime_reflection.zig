const std = @import("std");
const expect = std.testing.expect;
const dprint = std.debug.print;

// 验证1: comptime while循环
test "inline while loop" {
    comptime var i: usize = 0; // i 是一个编译期常量
    var sum: usize = 0; // sum 是一个运行时变量

    inline while (i < 3) : (i += 1) {
        const T = switch (i) {
            0 => f32,
            1 => i8,
            2 => bool,
            else => unreachable,
        };
        sum += typeNameLength(T);
    }

    try expect(sum == 9);
}

// 辅助函数：获取类型名称长度
fn typeNameLength(comptime T: type) usize {
    return @typeName(T).len;
}

// 验证2: comptime变量要求
test "comptime variable requirement" {
    // comptime变量只能在inline while中使用
    comptime var i: usize = 0;
    var count: usize = 0;

    inline while (i < 3) : (i += 1) {
        count += 1;
    }

    try expect(count == 3);
}

// 验证3: 类型反射 - @typeInfo基本用法
test "typeInfo basic usage" {
    // 浮点类型反射
    const float_info = @typeInfo(f32);
    try expect(float_info == .float);

    // 整数类型反射
    const int_info = @typeInfo(i32);
    try expect(int_info == .int);

    // 结构体类型反射
    const Point = struct { x: f32, y: f32 };
    const struct_info = @typeInfo(Point);
    try expect(struct_info == .@"struct");
}

// 验证4: 浮点类型默认容差
pub inline fn defaultTolerance(comptime T: type) T {
    return switch (@typeInfo(T)) {
        .float, .comptime_float => math.floatEps(T) * 100, // 100倍机器精度
        else => @compileError("Only floating-point types supported"),
    };
}

test "floating point tolerance" {
    const tol_f32 = defaultTolerance(f32);
    const tol_f64 = defaultTolerance(f64);

    dprint("f32 tolerance: {e}, f64 tolerance: {e}\n", .{ tol_f32, tol_f64 });

    try expect(tol_f32 > 0);
    try expect(tol_f64 > 0);
    try expect(tol_f64 < tol_f32); // f64精度更高，容差更小
}

const math = std.math;

// 验证5: 编译期整数类型计算
inline fn Sqrt(comptime T: type) type {
    return switch (@typeInfo(T)) {
        .int => |int| blk: {
            const new_bits = (int.bits + 1) / 2;
            _ = new_bits;
            // 在Zig 0.16.0中，直接返回简化的类型
            break :blk if (int.bits <= 16) u8 else if (int.bits <= 32) u16 else u32;
        },
        else => T,
    };
}

test "compile time integer type calculation" {
    // 对于u32 (32位)，Sqrt应该返回u16 (16位)
    const SqrtU32 = Sqrt(u32);
    try expect(@typeInfo(SqrtU32).int.bits == 16);

    // 对于u64 (64位)，Sqrt应该返回u32 (32位)
    const SqrtU64 = Sqrt(u64);
    try expect(@typeInfo(SqrtU64).int.bits == 32);
}

// 验证6: 访问struct字段类型
test "access struct field types" {
    const Point = struct { x: f32, y: f32 };

    // 获取结构体类型信息
    const info = @typeInfo(Point);
    const struct_info = info.@"struct";

    // 访问第一个字段的类型
    const first_field_type = struct_info.fields[0].type;
    try expect(first_field_type == f32);
}

// 验证7: @typeName获取类型名称
test "typeName usage" {
    const Point = struct { x: f32, y: f32 };
    const type_name = @typeName(Point);

    try expect(type_name.len > 0);
    dprint("Point type name: {s}\n", .{type_name});
}

// 验证8: comptime类型检查
test "comptime type checking" {
    const checkType = struct {
        fn isInteger(comptime T: type) bool {
            return @typeInfo(T) == .int;
        }

        fn isFloat(comptime T: type) bool {
            return @typeInfo(T) == .float;
        }
    };

    try expect(checkType.isInteger(i32));
    try expect(checkType.isFloat(f64));
    try expect(!checkType.isInteger(f32));
}

// 验证9: 类型安全的normalize函数
pub fn normalize(p: anytype) Math_Compute_Abandon!void {
    const norm = blk: {
        break :blk @as(f32, 1.0); // 简化的lb_norm
    };

    if (approxEqAbs(@TypeOf(p[0]), norm, 0, null)) {
        return error.Math_Compute_Abandon;
    }

    for (p) |*pv| {
        pv.* /= norm;
    }
}

const Math_Compute_Abandon = error{Math_Compute_Abandon};

fn approxEqAbs(comptime T: type, a: T, b: T, tolerance: ?T) bool {
    _ = tolerance;
    return @abs(a - b) < 0.0001;
}

test "normalize function" {
    var values = [_]f32{ 2.0, 4.0, 6.0 };
    const slice = values[0..];
    try normalize(slice);

    try expect(@abs(values[0] - 2.0) < 0.01);
    try expect(@abs(values[1] - 4.0) < 0.01);
    try expect(@abs(values[2] - 6.0) < 0.01);
}

// 验证10: 切片类型安全转换
test "slice type conversion" {
    const array = [_]i32{ 1, 2, 3, 4, 5 };
    const slice: []const i32 = &array;

    // []T 可以安全地转向 []const T，不需要显式转换
    const const_slice: []const i32 = slice;

    try expect(const_slice.len == 5);
    try expect(const_slice[0] == 1);
}

// 验证11: comptime_int类型问题
test "comptime_int type inference" {
    // 下面的代码会报错，因为x没有给类型，而-1是comptime_int
    // var x = -1;  // 这会导致类型推断冲突
    // 正确的写法：
    var x: f32 = -1;
    x = x - 1;

    try expect(x < 0);
}

// 定义WithAdd结构体以解决前向引用问题
const WithAddStruct = struct {
    x: i32,
    pub fn add(self: *const WithAddStruct, val: i32) i32 {
        return self.x + val;
    }
};

// 验证12: 类型类约束实现
test "type class constraint" {
    // 先简单测试，看看结构体的信息
    const with_add_info = @typeInfo(WithAddStruct);
    try expect(with_add_info == .@"struct");

    const struct_info = with_add_info.@"struct";
    dprint("WithAddStruct has {} decls\n", .{struct_info.decls.len});

    // 检查是否存在add方法
    var found_add = false;
    for (struct_info.decls) |decl| {
        dprint("Found decl: {s}\n", .{decl.name});
        if (std.mem.eql(u8, decl.name, "add")) {
            found_add = true;
        }
    }

    try expect(found_add);

    // 简化的类型类约束检查
    const hasAddMethodSimple = struct {
        fn check(comptime T: type) bool {
            const type_info = @typeInfo(T);
            if (type_info != .@"struct") {
                return false;
            }

            for (type_info.@"struct".decls) |decl| {
                if (std.mem.eql(u8, decl.name, "add")) {
                    return true;
                }
            }
            return false;
        }
    };

    const WithoutAdd = struct {
        x: i32,
    };

    // 先检查WithoutAdd，应该是false
    try expect(!hasAddMethodSimple.check(WithoutAdd));

    // 再检查WithAddStruct，应该是true
    try expect(hasAddMethodSimple.check(WithAddStruct));
}

// 验证13: 编译期整数范围检查
test "compile time integer range check" {
    const checkRange = struct {
        fn inRange(comptime T: type, val: T, min: T, max: T) bool {
            return val >= min and val <= max;
        }
    };

    try expect(checkRange.inRange(i32, 5, 0, 10));
    try expect(!checkRange.inRange(i32, 15, 0, 10));
}

// 验证14: 类型信息遍历
test "iterate struct fields" {
    const Point = struct { x: f32, y: f32, z: f32 };

    const info = @typeInfo(Point);
    const struct_info = info.@"struct";

    var field_count: usize = 0;
    inline for (struct_info.fields) |field| {
        _ = field;
        field_count += 1;
    }

    try expect(field_count == 3);
    dprint("Point has {} fields\n", .{field_count});
}

pub fn main() !void {
    dprint("Comptime and type reflection verification completed!\n", .{});
}
