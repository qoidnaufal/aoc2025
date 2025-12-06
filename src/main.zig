const std = @import("std");
const day01 = @import("day01.zig");
const day02 = @import("day02.zig");

const Day = enum {
    day01a,
    day01b,
    day02a,
    day02b,
};

pub fn main() !void {
    var gp = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gp.deinit();
    const allocator = gp.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len == 2) {
        const day = std.meta.stringToEnum(Day, args[1]) orelse {
            std.debug.print("[ERROR] unknown day: {s}\n", .{ args[1] });
            printInstruction();
            return;
        };
        switch (day) {
            .day01a => try day01.part1(&allocator),
            .day01b => try day01.part2(&allocator),
            .day02a => try day02.part1(&allocator),
            .day02b => try day02.part2(&allocator),
        }
    } else {
        printInstruction();
    }
}

const instruction: []const u8 =
\\ Usage:
\\     zig build run <Day>
\\ Day:
\\     day01a, day01b, day02a, etc.
\\ Example:
\\     zig build run day01a
;

fn printInstruction() void {
    std.debug.print("{s}\n", .{instruction});
}
