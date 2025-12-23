const std = @import("std");
const mem = std.mem;

const Range = struct {
    start: u64,
    end: u64,

    pub fn isInRange(self: @This(), value: u64) bool {
        return self.start <= value and value <= self.end;
    }

};

const OrderedRangeSet = struct {
    list: std.ArrayList(Range),
    comparator: *const fn (Range, Range) RangeOrder,

    const RangeOrder = enum {
        lt,
        gt,
        ol,
    };

    pub const empty: @This() = .{
        .list = std.ArrayList(Range).empty,
        .comparator = compareFn,
    };

    pub fn add(self: *@This(), allocator: mem.Allocator, range: Range) !void {
        var low: usize = 0;
        var high: usize = self.list.items.len;

        while (low < high) {
            const mid = low + (high - low) / 2;
            const order = self.comparator(range, self.list.items[mid]);

            switch (order) {
                .lt => high = mid,
                .gt => low = mid + 1,
                .ol => {
                    var merged = mergeRanges(self.list.items[mid], range);

                    var i = mid;
                    while (i > 0 and self.list.items[i - 1].end >= merged.start) : (i -= 1)
                        merged = mergeRanges(self.list.items[i - 1], merged);

                    var j = mid + 1;
                    while (j < self.list.items.len and merged.end >= self.list.items[j].start) : (j += 1)
                        merged = mergeRanges(merged, self.list.items[j]);

                    self.list.replaceRangeAssumeCapacity(i, j - i, &.{merged});

                    return;
                },
            }
        }

        try self.list.insert(allocator, low, range);
    }

    pub fn searchInRanges(self: @This(), value: u64) ?usize {
        var low: usize = 0;
        var high: usize = self.list.items.len;

        while (low < high) {
            const mid = low + (high - low) / 2;
            const range = self.list.items[mid];
            if (range.isInRange(value)) return mid;

            if (value < range.start) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        return null;
    }

    pub fn deinit(self: *@This(), allocator: mem.Allocator) void {
        self.list.deinit(allocator);
        self.* = undefined;
    }

    fn compareFn(range_a: Range, range_b: Range) RangeOrder {
        if (range_a.end < range_b.start) {
            return .lt;
        } else if (range_a.start > range_b.end) {
            return .gt;
        }
        return .ol;
    }

    fn mergeRanges(range_a: Range, range_b: Range) Range {
        return .{
            .start = @min(range_a.start, range_b.start),
            .end = @max(range_a.end, range_b.end),
        };
    }

};


pub fn main() !void {
    var dba: std.heap.DebugAllocator(.{}) = .init;
    const allocator = dba.allocator();

    const file = @embedFile("input.txt");


    var ord_ranges: OrderedRangeSet = .empty;
    var it = mem.splitScalar(u8, file, '\n');

    while (it.next()) |range_str| {
        if (mem.eql(u8, range_str, "")) break;
        const separator_idx = mem.indexOfScalar(u8, range_str, '-') orelse unreachable;

        try ord_ranges.add(allocator, .{
            .start = try std.fmt.parseInt(u64, range_str[0..separator_idx], 10),
            .end = try std.fmt.parseInt(u64, range_str[separator_idx + 1..], 10),
        });
    }

    var fresh_count: usize = 0;
    for (ord_ranges.list.items) |range| {
        fresh_count += range.end - range.start + 1;
    }
    std.debug.print("Day 5 Part 2: {d}\n", .{fresh_count});
}
