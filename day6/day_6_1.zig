const std = @import("std");

const Matrix = struct {
    const Shape = struct { rows: usize, cols: usize };

    grid: []const u64,
    shape: Shape,

    pub fn init(grid: []const u64, shape: Shape) @This() {
        std.debug.assert(grid.len % shape.cols == 0);
        return .{
            .grid = grid,
            .shape = shape,
        };
    }

    pub fn getValue(self: @This(), row: usize, col: usize) !u64 {
        if (row >= self.shape.rows or col >= self.shape.cols) return error.IndexOutOfRange;

        return self.grid[row * self.shape.cols + col];
    }

};

pub fn main() !void {
    var dba: std.heap.DebugAllocator(.{}) = .init;
    defer std.debug.assert(dba.deinit() == .ok);
    const allocator = dba.allocator();

    const file = @embedFile("input.txt");

    var numbers: std.ArrayList(u64) = .empty;
    defer numbers.deinit(allocator);

    var operations: std.ArrayList(u8) = .empty;
    defer operations.deinit(allocator);

    var it = std.mem.tokenizeAny(u8, file, " \n");

    while (it.next()) |elem| {
        if (elem[0] == '*' or elem[0] == '+') {
            try operations.append(allocator, elem[0]);
        } else {
            const number = try std.fmt.parseInt(u64, elem, 10);
            try numbers.append(allocator, number);
        }
    }

    const rows = @divExact(numbers.items.len, operations.items.len);
    var numbers_matrix = Matrix.init(numbers.items, .{
        .rows = rows,
        .cols = operations.items.len
    });

    var total: u64 = 0;
    for (0..numbers_matrix.shape.cols) |col| {
        const op = operations.items[col];

        var operation_result: u64 = if (op == '*') 1 else 0;

        for (0..numbers_matrix.shape.rows) |row| {
            const val = try numbers_matrix.getValue(row, col);
            switch (op) {
                '*' => operation_result *= val,
                '+' => operation_result += val,
                else => @panic("Invalid Operator")
            }
        }
        total += operation_result;
    }

    std.debug.print("Day 6 Part 1: {d}\n", .{total});
}
