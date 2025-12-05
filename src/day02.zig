const std = @import("std");
const root = @import("root.zig");
const Allocator = std.mem.Allocator;

pub fn run(allocator: *const Allocator) !void {
    const input = try root.read_input(allocator, "puzzle_input/day01.txt");
    defer allocator.free(input);
}

const testInput =
\\L68
\\L30
\\R48
\\L5
\\R60
\\L55
\\L1
\\L99
\\R14
\\L82
\\
;

// test "day01" {
//     const allocator = std.testing.allocator;
// }
