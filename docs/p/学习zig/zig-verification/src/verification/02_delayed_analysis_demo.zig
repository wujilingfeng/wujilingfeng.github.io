const std = @import("std");

// 这个函数包含错误，但因为未被使用，编译器不会报错
fn unusedFunctionWithError() void {
    const x: i32 = "this would normally be an error";
    _ = x;
}

// 这个函数包含同样的错误，但因为被使用了，会触发编译错误
fn usedFunctionWithError() void {
    const x: i32 = "this causes compilation error";
    _ = x;
}

pub fn main() !void {
    std.debug.print("This compiles because unusedFunctionWithError is never called\n", .{});

    // 取消下面这行的注释会触发编译错误：
    usedFunctionWithError();
}
