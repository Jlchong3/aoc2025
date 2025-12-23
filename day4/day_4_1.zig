const std = @import("std");

const Matrix = struct {
    const Shape = struct { rows: usize, cols: usize };

    grid: []const u8,
    shape: Shape,

    pub fn init(grid: []const u8, shape: Shape) @This() {
        std.debug.assert(grid.len % shape.cols == 0);
        return .{
            .grid = grid,
            .shape = shape,
        };
    }

    pub fn getValue(self: @This(), row: usize, col: usize) !u8 {
        if (row >= self.shape.rows or col >= self.shape.cols) return error.IndexOutOfRange;

        return self.grid[row * self.shape.cols + col];
    }

    pub fn countAdyacentSymbol(self: @This(), row: usize, col: usize, symbol: u8) usize {
        var count: usize = 0;
        const differentials = [_]isize{-1, 0, 1};

        for (differentials) |drow| {
            for (differentials) |dcol| {
                if (drow == 0 and dcol == 0) continue;
                if (row == 0 and drow == -1 or col == 0 and dcol == -1) continue; //manage error of negatives with usize

                const value = self.getValue(
                    @intCast(@as(isize, @intCast(row)) + drow),
                    @intCast(@as(isize, @intCast(col)) + dcol)
                ) catch continue;

                if (value == symbol) count += 1;
            }
        }

        return count;
    }
};

pub fn main() !void {
    const file = @embedFile("input.txt");
    const line_len = if (std.mem.indexOfScalar(u8, file, '\n')) |idx| idx else file.len;
    var grid_buf: [file.len]u8 = undefined;

    var i: usize = 0;
    for (file) |char| {
        if (char == '\n') continue;

        grid_buf[i] = char;
        i += 1;
    }

    const grid = grid_buf[0..i];

    const column_size = line_len;

    const paper_grid = Matrix.init(grid, .{
        .rows = @divExact(grid.len, column_size),
        .cols = column_size
    });

    var count_allowed: usize = 0;

    for (paper_grid.grid, 0..) |char, pos| {
        if (char == '.') continue;

        const row = @divTrunc(pos, paper_grid.shape.cols);
        const col = pos % paper_grid.shape.cols;

        if (paper_grid.countAdyacentSymbol(row, col, '@') < 4) count_allowed += 1;
    }

    std.debug.print("Day 4 Part 1: {d}\n", .{count_allowed});
}
