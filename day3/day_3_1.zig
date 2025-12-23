const std = @import("std");

pub fn main() !void {
    const file = @embedFile("input.txt");
    var it = std.mem.tokenizeScalar(u8, file, '\n');

    var total_output: usize = 0;
    while (it.next()) |bank| {
        var first_biggest: u8 = 0;
        var second_biggest: u8 = 0;

        for (bank, 0..) |joltage, i| {
            if (joltage > first_biggest and i != bank.len - 1) {
                first_biggest = joltage;
                second_biggest = 0;
            } else if (joltage > second_biggest) {
                second_biggest = joltage;
            }
        }

        total_output += try std.fmt.parseInt(usize, &.{ first_biggest, second_biggest }, 10);
    }
    std.debug.print("Day 3 Part 1: {d}\n", .{total_output});
}
