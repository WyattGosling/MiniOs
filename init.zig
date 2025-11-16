const std = @import("std");

fn monitor_shell(child: std.process.Child) void {
    var shell = child;
    _ = shell.wait() catch unreachable;
    // It is probably appropriate to cleanup stderr and stdout here, but the
    // system is about to go down, so who cares?
    _ = std.os.linux.reboot(std.os.linux.LINUX_REBOOT.MAGIC1.MAGIC1, std.os.linux.LINUX_REBOOT.MAGIC2.MAGIC2, std.os.linux.LINUX_REBOOT.CMD.POWER_OFF, null);
    unreachable;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var dir = try std.fs.openDirAbsolute("/", .{ .iterate = true });
    defer dir.close();

    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        std.debug.print("found entry: {s}\n", .{entry.name});
    }

    var shell = std.process.Child.init(&.{ "/shell", "irrelevant" }, allocator);
    try shell.spawn();
    try shell.waitForSpawn();

    _ = try std.Thread.spawn(.{}, monitor_shell, .{shell});

    var count: i32 = 1;
    while (true) {
        std.debug.print("Hello from init! {}\n", .{@as(i64, count)});
        count += 1;
        std.Thread.sleep(10_000_000_000);
    }
}
