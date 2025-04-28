+++
date = '2025-04-27T13:06:57+08:00'
draft = true
title = 'Mytest'

+++

测试代码高亮

```zig
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    defer arena.deinit();
    const pt = .{
        .int = @as(u32, 1234),
    };

    dprint("pt type:{}\n", .{@TypeOf(pt)});
    const allocator = arena.allocator();
    var list = std.ArrayList(struct { u32, u32 }).init(allocator);
    defer list.deinit();

    // missing `defer list.deinit();`
    // try list.append('☔');
    dprint("{}\n", .{@sizeOf(@TypeOf(list))});
}
```
