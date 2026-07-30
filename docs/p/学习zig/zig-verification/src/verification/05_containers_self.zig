const std = @import("std");
const expect = std.testing.expect;
const dprint = std.debug.print;

// 验证1: 容器中的self参数基本用法
const Counter = struct {
    count: i32,

    // 使用self的方法
    fn increment(self: *Counter) void {
        self.count += 1;
    }

    // 使用const self的方法
    fn getCount(self: *const Counter) i32 {
        return self.count;
    }

    // 使用值self的方法
    fn copy(self: Counter) Counter {
        return self;
    }
};

test "container self parameter basic usage" {
    var counter = Counter{ .count = 0 };

    // 通过实例调用，自动传递self
    counter.increment();
    try expect(counter.getCount() == 1);

    counter.increment();
    try expect(counter.getCount() == 2);

    // 值self会复制结构体
    const counter_copy = counter.copy();
    try expect(counter_copy.getCount() == 2);

    // 修改原对象不影响副本
    counter.increment();
    try expect(counter.getCount() == 3);
    try expect(counter_copy.getCount() == 2);
}

// 验证2: Self类型的正确使用
const ArrayList = struct {
    items: []i32,
    capacity: usize,

    // 使用Self作为返回类型
    fn init() ArrayList {
        return ArrayList{
            .items = &[_]i32{},
            .capacity = 0,
        };
    }

    // 方法使用self参数
    fn append(self: *ArrayList, item: i32) !void {
        // 这里应该实现实际的添加逻辑
        _ = self;
        _ = item;
    }

    fn deinit(self: *ArrayList) void {
        // 清理资源
        _ = self;
    }
};

// 修正：使用正确的容器类型名称
const MyArrayList = struct {
    items: []i32,
    capacity: usize,

    fn init() MyArrayList {
        return MyArrayList{
            .items = &[_]i32{},
            .capacity = 0,
        };
    }

    fn deinit(self: *MyArrayList) void {
        // 清理资源
        _ = self;
    }
};

test "container method vs static function" {
    var list = MyArrayList.init();
    defer list.deinit(); // 通过实例调用方法

    // deinit也可以通过容器类型调用，但需要传递实例
    MyArrayList.deinit(&list);
}

// 验证3: 不需要实例的静态函数应该通过容器类型调用
const MathUtil = struct {
    // 这个函数不需要实例，应该通过容器类型调用
    fn add(a: i32, b: i32) i32 {
        return a + b;
    }

    // 这个函数需要实例数据，应该通过实例调用
    fn addWithOffset(self: *const MathUtil, value: i32) i32 {
        _ = self;
        return value + 10;
    }
};

test "static vs instance methods" {
    // 静态函数通过容器类型调用
    const result = MathUtil.add(5, 3);
    try expect(result == 8);

    // 实例方法通过实例调用
    const math_util = MathUtil{};
    const offset_result = math_util.addWithOffset(5);
    try expect(offset_result == 15);
}

// 验证4: 容器级别的函数和实例级别函数的区别
const Container = struct {
    var static_var: i32 = 100; // 容器级别变量

    fn staticFunction() i32 {
        return static_var;
    }

    fn instanceMethod(self: *const Container) i32 {
        _ = self;
        return static_var;
    }
};

test "container level vs instance level" {
    // 容器级别函数通过容器类型调用
    try expect(Container.staticFunction() == 100);

    // 实例方法通过实例调用
    const container = Container{};
    try expect(container.instanceMethod() == 100);
}

// 验证5: 复杂的self参数模式
const Rectangle = struct {
    width: f32,
    height: f32,

    fn area(self: *const Rectangle) f32 {
        return self.width * self.height;
    }

    fn scale(self: *Rectangle, factor: f32) void {
        self.width *= factor;
        self.height *= factor;
    }

    fn new(width: f32, height: f32) Rectangle {
        return Rectangle{ .width = width, .height = height };
    }
};

test "rectangle example with self" {
    var rect = Rectangle.new(10.0, 20.0);
    try expect(rect.area() == 200.0);

    rect.scale(2.0);
    try expect(rect.area() == 800.0);

    // 构造函数通过容器类型调用
    const rect2 = Rectangle.new(5.0, 5.0);
    try expect(rect2.area() == 25.0);
}

// 验证6: 嵌套容器中的self参数
const OuterContainer = struct {
    value: i32,

    const InnerContainer = struct {
        multiplier: i32,

        fn multiply(inner: *const InnerContainer, val: i32) i32 {
            return inner.multiplier * val;
        }
    };

    fn combined(self: *const OuterContainer, multiplier: i32) i32 {
        const inner = InnerContainer{ .multiplier = multiplier };
        return InnerContainer.multiply(&inner, self.value);
    }
};

test "nested containers with self" {
    const outer = OuterContainer{ .value = 10 };
    try expect(outer.combined(3) == 30);

    // 也可以直接调用内部容器的方法
    const inner = OuterContainer.InnerContainer{ .multiplier = 5 };
    try expect(OuterContainer.InnerContainer.multiply(&inner, 10) == 50);
}

pub fn main() !void {
    dprint("Containers and self parameter verification completed!\n", .{});
}
