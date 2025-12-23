const std = @import("std");

pub fn main() !void {
    const file = @embedFile("input.txt");
    var it = std.mem.tokenizeScalar(u8, file, ',');

    var invalid_sum: usize = 0;

    while (it.next()) |range| {
        const serparator_index = std.mem.indexOfScalar(u8, range, '-').?;
        const start_str = range[0..serparator_index];
        const end_str = std.mem.trimEnd(u8, range[serparator_index + 1..], " \r\n");

        const start = try std.fmt.parseInt(usize, start_str, 10);
        const end = try std.fmt.parseInt(usize, end_str, 10);

        for (start..end + 1) |i| {
            var temp = i;
            var digits: usize = 0;

            if (temp == 0) digits = 1 else while (temp != 0) : (digits += 1) temp /= 10;

            var chunk_size: usize = digits / 2;

            while (chunk_size > 0) : (chunk_size -= 1) {
                if (digits % chunk_size != 0) continue;

                const divisor = std.math.pow(usize, 10, chunk_size);

                const expected_chunk = i % divisor;
                var value = i / divisor;

                while (value > 0) : (value /= divisor) {
                    const next_chunk = @mod(value, divisor);
                    if (next_chunk != expected_chunk) break;
                } else {
                    invalid_sum += i;
                    break;
                }
            }
        }
    }
    std.debug.print("Day 2 Part 2: {d}\n", .{invalid_sum});
}
