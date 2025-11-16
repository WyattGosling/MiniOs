const std = @import("std");

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
    defer allocator.free(shell.stderr);
    defer allocator.free(shell.stdout);

    var count: i32 = 1;
    while (true) {
        std.debug.print("Hello from init! {}\n", .{@as(i64, count)});
        count += 1;
        std.Thread.sleep(10_000_000_000);
    }
}
