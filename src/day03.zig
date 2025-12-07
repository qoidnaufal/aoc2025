const std = @import("std");
const root = @import("aoc2025");

const Allocator = std.mem.Allocator;

fn process_part_1(input: []const u8, comptime log: bool) void {
    var output: usize = 0;
    var iter = std.mem.splitScalar(u8, input[0..input.len - 1], '\n');

    while (iter.next()) |line| {
        var joltage: u8 = 0;

        for (0..line.len - 1) |idx| {
            const num0 = (line[idx] - '0') * 10;
            var num1: u8 = 0;

            for (idx + 1..line.len) |secIdx| {
                const numInner = line[secIdx] - '0';
                if (numInner > num1) {
                    num1 = numInner;
                }
            }

            if (num0 + num1 > joltage) {
                joltage = num0 + num1;
            }
        }

        if (log) std.debug.print("{d}\n", .{ joltage });
        output += @as(usize, joltage);
    }

    std.debug.print("Result of part 1: {d}\n", .{ output });
}

pub fn part1(allocator: *const Allocator) !void {
    const input = try root.read_input(allocator, "puzzle_input/day03.txt");
    defer allocator.free(input);
    process_part_1(input, false);
}

const testInput =
\\987654321111111
\\811111111111119
\\234234234234278
\\818181911112111
\\
;

test "part1" {
    // const allocator = std.testing.allocator;
    process_part_1(testInput, true);
}
