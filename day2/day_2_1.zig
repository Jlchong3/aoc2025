const std = @import("std");

pub fn main() !void {
    const file = @embedFile("input.txt");
    var it = std.mem.tokenizeScalar(u8, file, ',');

    var invalid_sum: usize = 0;

    while (it.next()) |range| {
        const serparator_index = std.mem.indexOfScalar(u8, range, '-').?;
        const start_str = range[0..serparator_index];
        const end_str = std.mem.trimEnd(u8, range[serparator_index + 1..], " \r\n");

        if (start_str.len == end_str.len and start_str.len % 2 != 0) continue;

        const start = try std.fmt.parseInt(usize, start_str, 10);
        const end = try std.fmt.parseInt(usize, end_str, 10);

        for (start..end + 1) |i| {
            var temp = i;
            var digits: usize = 0;

            while (temp != 0) : (digits += 1) temp /= 10;
            if (digits % 2 != 0) continue;

            const half_divisor = std.math.pow(usize, 10, digits / 2);
            const top = @divTrunc(i, half_divisor);
            const bottom = @mod(i, half_divisor);

            if (top == bottom) invalid_sum += i;
        }
    }
    std.debug.print("Day 2 Part 1: {d}\n", .{invalid_sum});
}
