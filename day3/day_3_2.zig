const std = @import("std");

pub fn main() !void {
    const file = @embedFile("input.txt");

    var it = std.mem.tokenizeScalar(u8, file, '\n');

    var stack_buf: [file.len]u8 = undefined;
    var stack: std.ArrayList(u8) = .initBuffer(&stack_buf);

    var total_output: usize = 0;
    while (it.next()) |bank| {
        var drop_count: usize = bank.len - 12;

        for (bank) |joltage| {
            while (stack.items.len > 0 and drop_count > 0) {
                if (joltage > stack.items[stack.items.len - 1]) {
                    _ = stack.pop();
                    drop_count -= 1;
                } else {
                    break;
                }
            }
            stack.appendAssumeCapacity(joltage);
        }

        total_output += try std.fmt.parseInt(usize, stack.items[0..12], 10);

        stack.clearRetainingCapacity();
    }
    std.debug.print("Day 3 Part 2: {d}\n", .{total_output});
}

pub fn lessThanFn(numbers: []const u8, lhs: usize, rhs: usize) bool {
    return numbers[lhs] > numbers[rhs];
}
