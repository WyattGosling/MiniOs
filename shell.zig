const std = @import("std");

pub fn main() !void {
    std.debug.print("Hello world from shell!\n", .{});

    var stdin_buffer: [4096]u8 = undefined;
    var stdin_reader = std.fs.File.stdin().reader(&stdin_buffer);
    const stdin = &stdin_reader.interface;

    while (true) {
        std.debug.print("enter a command: ", .{});
        const cmd = try stdin.takeDelimiter('\n');
        std.debug.print("Your command is: {?s}\n", .{cmd});
    }
}
