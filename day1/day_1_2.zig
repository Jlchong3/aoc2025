const std = @import("std");

pub fn main() !void {
    const file_content = @embedFile("input.txt");

    var it = std.mem.tokenizeScalar(u8, file_content, '\n');
    var dial: i64 = 50;
    var count: usize = 0;

    while (it.next()) |value| {
        const number = try std.fmt.parseInt(i64, value[1..], 10);
        if (value[0] == 'R') {
            count += @intCast(@divTrunc(dial + number, 100));
            dial = @mod(dial + number, 100);
        } else {
            count += @intCast(@divTrunc(@mod(100 - dial, 100) + number, 100));
            dial = @mod(dial - number, 100);
        }
    }

    std.debug.print("Day 1 Part 2: {d}\n", .{count});
}
