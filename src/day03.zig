const std = @import("std");
const root = @import("aoc2025");

const Allocator = std.mem.Allocator;

fn parseInput(input: []const u8) void {}

pub fn part1(allocator: *const Allocator) !void {
    const input = try root.read_input(allocator, "puzzle_input/day03.txt");
    defer allocator.free(input);
}

const testInput =
\\987654321111111
\\811111111111119
\\234234234234278
\\818181911112111
\\
;

test "part1" {
    const allocator = std.testing.allocator;
    parseInput(testInput);
}
