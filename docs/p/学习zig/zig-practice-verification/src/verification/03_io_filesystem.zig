const std = @import("std");
const expect = std.testing.expect;
const dprint = std.debug.print;

// 验证1: std.Io.Threaded初始化
test "Io Threaded initialization" {
    var threadio = std.Io.Threaded.init(std.testing.allocator, .{});
    defer threadio.deinit();

    // 只验证初始化成功，不与null比较
    dprint("Io.Threaded initialized successfully\n", .{});
}

// 验证2: 获取IO接口
test "get io interface" {
    var threadio = std.Io.Threaded.init(std.testing.allocator, .{});
    defer threadio.deinit();

    const io = threadio.io();
    // 只验证获取成功
    _ = io;
    dprint("IO interface obtained successfully\n", .{});
}

// 验证3: 获取当前工作目录
test "get current working directory" {
    var threadio = std.Io.Threaded.init(std.testing.allocator, .{});
    defer threadio.deinit();

    const cwd = std.Io.Dir.cwd();
    dprint("Current working directory obtained\n", .{});
    _ = cwd;
}

// 验证4: 创建和写入测试文件
test "create and write test file" {
    var threadio = std.Io.Threaded.init(std.testing.allocator, .{});
    defer threadio.deinit();

    const test_content = "Hello, Zig IO!";
    var file = try std.Io.Dir.createFile(std.Io.Dir.cwd(), threadio.io(), "test_io.txt", .{
        .read = true,
    });
    defer file.close(threadio.io());

    // 使用writer接口写入
    var write_buffer: [100]u8 = undefined;
    var writer = file.writer(threadio.io(), &write_buffer);
    const writer_interface = &writer.interface;
    try writer_interface.writeAll(test_content);

    dprint("Test file created and written\n", .{});
}

// 验证5: 读取文件内容
test "read file content" {
    var threadio = std.Io.Threaded.init(std.testing.allocator, .{});
    defer threadio.deinit();

    // 先创建测试文件
    const test_content = "Hello, Zig IO!";
    var file = try std.Io.Dir.createFile(std.Io.Dir.cwd(), threadio.io(), "test_read.txt", .{
        .read = true,
    });

    // 使用writer接口写入
    var write_buffer: [100]u8 = undefined;
    var writer = file.writer(threadio.io(), &write_buffer);
    const writer_interface = &writer.interface;
    try writer_interface.writeAll(test_content);

    // 关闭文件并重新打开以进行读取
    file.close(threadio.io());

    var read_file = try std.Io.Dir.openFile(std.Io.Dir.cwd(), threadio.io(), "test_read.txt", .{});
    defer read_file.close(threadio.io());

    // 使用reader接口读取文件
    const file_stat = try read_file.stat(threadio.io());
    var buffer: [100]u8 = undefined;
    var file_reader = read_file.reader(threadio.io(), &buffer);
    const reader_interface = &file_reader.interface;

    const content = try reader_interface.readAlloc(std.testing.allocator, file_stat.size);
    defer std.testing.allocator.free(content);

    try expect(std.mem.eql(u8, content, test_content));
    dprint("File read successfully: {s}\n", .{content});
}

// 验证6: 文件读取器接口
test "file reader interface" {
    var threadio = std.Io.Threaded.init(std.testing.allocator, .{});
    defer threadio.deinit();

    const test_content = "Line 1\nLine 2\nLine 3";
    var file = try std.Io.Dir.createFile(std.Io.Dir.cwd(), threadio.io(), "test_reader.txt", .{
        .read = true,
    });

    // 使用writer接口写入
    var write_buffer: [100]u8 = undefined;
    var writer = file.writer(threadio.io(), &write_buffer);
    const writer_interface = &writer.interface;
    try writer_interface.writeAll(test_content);

    // 关闭文件并重新打开以进行读取
    file.close(threadio.io());

    var read_file = try std.Io.Dir.openFile(std.Io.Dir.cwd(), threadio.io(), "test_reader.txt", .{});
    defer read_file.close(threadio.io());

    var buffer: [100]u8 = undefined;
    var file_reader = read_file.reader(threadio.io(), &buffer);
    const reader_interface = &file_reader.interface;

    const content = try reader_interface.readAlloc(std.testing.allocator, test_content.len);
    defer std.testing.allocator.free(content);

    try expect(std.mem.eql(u8, content, test_content));
    dprint("File reader interface worked: {s}\n", .{content});
}

// 验证7: 分配读取
test "file readAlloc" {
    var threadio = std.Io.Threaded.init(std.testing.allocator, .{});
    defer threadio.deinit();

    const test_content = "Allocated read test content";
    var file = try std.Io.Dir.createFile(std.Io.Dir.cwd(), threadio.io(), "test_alloc.txt", .{
        .read = true,
    });

    // 使用writer接口写入
    var write_buffer: [100]u8 = undefined;
    var writer = file.writer(threadio.io(), &write_buffer);
    const writer_interface = &writer.interface;
    try writer_interface.writeAll(test_content);

    // 关闭文件并重新打开以进行读取
    file.close(threadio.io());

    var read_file = try std.Io.Dir.openFile(std.Io.Dir.cwd(), threadio.io(), "test_alloc.txt", .{});
    defer read_file.close(threadio.io());

    var buffer: [100]u8 = undefined;
    var file_reader = read_file.reader(threadio.io(), &buffer);
    const reader_interface = &file_reader.interface;

    const content = try reader_interface.readAlloc(std.testing.allocator, test_content.len);
    defer std.testing.allocator.free(content);

    try expect(std.mem.eql(u8, content, test_content));
    dprint("ReadAlloc worked: {s}\n", .{content});
}

// 验证8: 时间戳功能
test "timestamp functionality" {
    var threadio = std.Io.Threaded.init(std.testing.allocator, .{});
    defer threadio.deinit();

    const start = std.Io.Timestamp.now(threadio.io(), .real);

    // 模拟一些工作
    var sum: usize = 0;
    var i: usize = 0;
    while (i < 1000) : (i += 1) {
        sum += i;
    }

    const end = std.Io.Timestamp.now(threadio.io(), .real);
    const duration = std.Io.Timestamp.durationTo(start, end);

    dprint("Duration: {} ns, Sum: {}\n", .{ duration.nanoseconds, sum });
    try expect(duration.nanoseconds > 0);
}

// 验证9: 目录遍历
test "directory iteration" {
    var threadio = std.Io.Threaded.init(std.testing.allocator, .{});
    defer threadio.deinit();

    // 使用当前目录进行遍历测试
    const cwd = std.Io.Dir.cwd();
    var iter = cwd.iterate();

    var file_count: usize = 0;
    while (try iter.next(threadio.io())) |entry| {
        dprint("Found entry: {s}\n", .{entry.name});
        file_count += 1;
        // 只统计前几个文件，避免遍历整个目录
        if (file_count >= 5) break;
    }

    try expect(file_count > 0);
    dprint("Directory iteration test passed\n", .{});
}

// 验证10: 文件状态
test "file stat" {
    var threadio = std.Io.Threaded.init(std.testing.allocator, .{});
    defer threadio.deinit();

    const test_content = "File stat test";
    var file = try std.Io.Dir.createFile(std.Io.Dir.cwd(), threadio.io(), "test_stat.txt", .{
        .read = true,
    });
    defer file.close(threadio.io());

    // 使用writer接口写入
    var write_buffer: [100]u8 = undefined;
    var writer = file.writer(threadio.io(), &write_buffer);
    const writer_interface = &writer.interface;
    try writer_interface.writeAll(test_content);

    const stat = try file.stat(threadio.io());
    try expect(stat.size == test_content.len);

    dprint("File size: {} bytes\n", .{stat.size});
}

// 验证11: 文件存在检查
test "file exists check" {
    var threadio = std.Io.Threaded.init(std.testing.allocator, .{});
    defer threadio.deinit();

    // 创建测试文件
    var file = try std.Io.Dir.createFile(std.Io.Dir.cwd(), threadio.io(), "test_exists.txt", .{});
    file.close(threadio.io());

    // 检查文件是否存在
    try std.Io.Dir.access(std.Io.Dir.cwd(), threadio.io(), "test_exists.txt", .{});

    dprint("File exists check passed\n", .{});
}

// 验证12: 删除文件
test "delete file" {
    var threadio = std.Io.Threaded.init(std.testing.allocator, .{});
    defer threadio.deinit();

    // 创建测试文件
    var file = try std.Io.Dir.createFile(std.Io.Dir.cwd(), threadio.io(), "test_delete.txt", .{});
    file.close(threadio.io());

    // 删除文件
    try std.Io.Dir.deleteFile(std.Io.Dir.cwd(), threadio.io(), "test_delete.txt");

    // 验证文件不存在（access应该返回错误）
    const file_exists = blk: {
        std.Io.Dir.access(std.Io.Dir.cwd(), threadio.io(), "test_delete.txt", .{}) catch {
            break :blk false; // 文件不存在，符合预期
        };
        break :blk true; // 文件仍然存在
    };

    try expect(!file_exists);

    dprint("File deletion successful\n", .{});
}

pub fn main() !void {
    dprint("IO and filesystem verification completed!\n", .{});
}
