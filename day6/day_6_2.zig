const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = @embedFile("input.txt");

    var lines: std.ArrayList([]const u8) = .empty;
    defer lines.deinit(allocator);
    var it = std.mem.tokenizeScalar(u8, file, '\n');
    while (it.next()) |line|
        try lines.append(allocator, line);

    const op_line = lines.pop().?;
    const data_lines = lines.items;

    var operators: std.ArrayList(u8) = .empty;
    defer operators.deinit(allocator);
    var op_it = std.mem.tokenizeScalar(u8, op_line, ' ');
    while (op_it.next()) |op|
        try operators.append(allocator, op[0]);

    const width = data_lines[0].len;
    var op_index: usize = 0;
    var current_result: u64 = if (operators.items[0] == '*') 1 else 0;

    var num_builder: std.ArrayList(u8) = .empty;
    defer num_builder.deinit(allocator);

    var total: u64 = 0;

    for (0..width) |x| {
        var is_empty_col = true;
        for (data_lines) |line| {
            if (line[x] != ' ') {
                is_empty_col = false;
                break;
            }
        }

        if (is_empty_col) {
            total += current_result;
            op_index += 1;
            current_result = if (operators.items[op_index] == '*') 1 else 0;
            continue;
        }

        for (data_lines) |line| {
            if (line[x] != ' ') try num_builder.append(allocator, line[x]);
        }

        const parsed = try std.fmt.parseInt(u64, num_builder.items, 10);
        num_builder.clearRetainingCapacity();

        const op = operators.items[op_index];

        switch (op) {
            '*' => current_result *= parsed,
            '+' => current_result += parsed,
            else => {},
        }
    }
    total += current_result;

    std.debug.print("Day 6 Part 2: {d}\n", .{total});
}
