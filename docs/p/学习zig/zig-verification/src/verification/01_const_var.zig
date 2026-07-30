const std = @import("std");
const expect = std.testing.expect;

// 验证1: const和var变量基本特性
test "const variable cannot be modified" {
    const x: i32 = 10;
    // x += 1; // 这行会报错：cannot assign to const
    try expect(x == 10);
}

test "var variable can be modified" {
    var y: i32 = 10;
    y += 1;
    try expect(y == 11);
}

// 验证2: 结构体成员变量的const和var继承
const MyStruct = struct {
    a: i32,
    b: i32,

    fn modifySelf(self: *MyStruct) void {
        self.a += 1; // 可以修改，因为self是可变指针
        self.b += 1;
    }

    fn readConst(self: *const MyStruct) void {
        _ = self.a; // 可以读取
        // self.a += 1; // 这行会报错：cannot assign to const
    }
};

test "struct field const/var inheritance" {
    var my_var_struct = MyStruct{ .a = 1, .b = 2 };
    my_var_struct.a += 1; // 可以，因为实例是var
    try expect(my_var_struct.a == 2);

    const my_const_struct = MyStruct{ .a = 1, .b = 2 };
    // my_const_struct.a += 1; // 这行会报错：cannot assign to const
    try expect(my_const_struct.a == 1);

    // 测试通过方法调用修改
    my_var_struct.modifySelf();
    try expect(my_var_struct.a == 3);

    // const实例调用修改方法也会报错
    // my_const_struct.modifySelf(); // 编译错误
}

// 验证3: 函数参数默认是const
fn defaultConstParam(value: i32) void {
    // value += 1; // 这行会报错：cannot assign to const parameter
    _ = value;
}

test "function parameters are const by default" {
    const x: i32 = 10;
    defaultConstParam(x);

    // 演示虽然传递的是const，但函数参数是const的
    const y: i32 = 20;
    defaultConstParam(y);

    // 如果要修改参数，需要显式使用var
    try expect(y == 20);
}

fn modifyParam(param: anytype) void {
    // 这个演示anytype参数，如果是具体类型，参数仍然是const的
    _ = param;
}

// 验证4: 结构体静态成员变量不受实例const/var影响
const StructWithStatics = struct {
    var static_var: i32 = 100; // 容器级别的var变量

    fn modifyStatic() void {
        static_var += 1; // 可以修改静态变量
    }
};

test "static struct members" {
    try expect(StructWithStatics.static_var == 100);
    StructWithStatics.modifyStatic();
    try expect(StructWithStatics.static_var == 101);
}

pub fn main() !void {
    std.debug.print("Const and Var verification completed!\n", .{});
}
