const std = @import("std");
const root = @import("root.zig");
const Allocator = std.mem.Allocator;
const String = root.String;

const Ranges = struct {
    start: std.ArrayList(usize),
    end: std.ArrayList(usize),

    const Self = @This();

    fn new() Self {
        return Self {
            .start = undefined,
            .end = undefined,
        };
    }

    fn init(self: *Self, allocator: *const Allocator, capacity: usize) !void {
        self.start = try std.ArrayList(usize).initCapacity(allocator.*, capacity);
        self.end = try std.ArrayList(usize).initCapacity(allocator.*, capacity);
    }

    fn deinit(self: *Self, allocator: *const Allocator) void {
        self.start.deinit(allocator.*);
        self.end.deinit(allocator.*);
    }

    fn process_part_1(self: *Self, allocator: *const Allocator) !void {
        const lo = self.start.items;
        const hi = self.end.items;

        var s = try String.new(allocator, 10);
        defer s.destroy(allocator);

        var count: usize = 0;
        for (lo, hi) |start, end| {
            try repeated_twice(start, end, &count, &s);
        }

        std.debug.print("Result part 1: {d}\n", .{ count });
    }

    fn process_part_2(self: *Self, allocator: *const Allocator, comptime log: bool) !void {
        const lo = self.start.items;
        const hi = self.end.items;

        var s = try String.new(allocator, 10);
        defer s.destroy(allocator);

        var count: usize = 0;
        for (lo, hi) |start, end| {
            try repeated_more_than_twice(start, end, &count, &s, log);
        }

        std.debug.print("Result part 2: {d}\n", .{ count });
    }
};

inline fn repeated_twice(start: usize, end: usize, count: *usize, s: *String) !void {
    for (start..end + 1) |id| {
        const string = try s.createStr("{d}", .{ id });

        const mid = string.len / 2;
        const front = string[0..mid];
        const back = string[mid..string.len];

        if (std.mem.eql(u8, front, back)) {
            count.* += id;
        }
    }
}

inline fn repeated_more_than_twice(
    start: usize,
    end: usize,
    count: *usize,
    s: *String,
    comptime log: bool
) !void {
    for (start..end + 1) |id| {
        const string = try s.createStr("{d}", .{ id });

        inner: for (0..string.len / 2) |index| {
            var windowIter = std.mem.window(u8, string, index + 1, index + 1);
            var tempBuf: []const u8 = windowIter.next() orelse "";
            var allEql = true;

            while (windowIter.next()) |window| {
                allEql &= std.mem.eql(u8, tempBuf, window);
                tempBuf = window;
            }

            if (allEql) {
                if (log) { std.debug.print("sequence: {s}\n", .{ string }); }
                count.* += id;
                break :inner;
            }
        }
    }
}

fn parseInput(input: []const u8, allocator: *const Allocator, ranges: *Ranges) !void {
    const capacity = std.mem.count(u8, input, ",") + 1;
    try ranges.init(allocator, capacity);
    var iter = std.mem.splitScalar(u8, input, ',');

    while (iter.next()) |seq| {
        var seqSplit = std.mem.splitScalar(u8, seq, '-');
        const frt = try std.fmt.parseUnsigned(usize, seqSplit.first(), 10);
        const rest = seqSplit.rest();
        const lst = std.fmt.parseUnsigned(usize, rest, 10)
            catch try std.fmt.parseUnsigned(usize, rest[0..rest.len - 1], 10);

        try ranges.start.appendBounded(frt);
        try ranges.end.appendBounded(lst);
    }
}

pub fn part1(allocator: *const Allocator) !void {
    const input = try root.read_input(allocator, "puzzle_input/day02.txt");
    defer allocator.free(input);

    var ranges = Ranges.new();
    defer ranges.deinit(allocator);

    try parseInput(input, allocator, &ranges);
    try ranges.process_part_1(allocator);
}

pub fn part2(allocator: *const Allocator) !void {
    const input = try root.read_input(allocator, "puzzle_input/day02.txt");
    defer allocator.free(input);

    var ranges = Ranges.new();
    defer ranges.deinit(allocator);

    try parseInput(input, allocator, &ranges);
    try ranges.process_part_2(allocator, false);
}

const testInput =
\\11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124
;

test "part1" {
    const allocator = std.testing.allocator;
    var ranges = Ranges.new();
    defer ranges.deinit(&allocator);

    try parseInput(testInput, &allocator, &ranges);
    try ranges.process_part_1(&allocator);
}

test "part2" {
    const allocator = std.testing.allocator;
    var ranges = Ranges.new();
    defer ranges.deinit(&allocator);

    try parseInput(testInput, &allocator, &ranges);
    try ranges.process_part_2(&allocator, true);
}
