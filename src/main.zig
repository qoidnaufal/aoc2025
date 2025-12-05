const std = @import("std");
const root = @import("root.zig");
const day01 = @import("day01.zig");
const day02 = @import("day02.zig");

const Day = enum {
    day01,
    day02,
};

pub fn main() !void {
    var gp = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gp.deinit();
    const allocator = gp.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    switch (args.len) {
        1 => printInstruction(),
        2 => {
            const day = std.meta.stringToEnum(Day, args[1]) orelse {
                printInstruction();
                return;
            };
            switch (day) {
                .day01 => try day01.run(&allocator),
                .day02 => try day02.run(&allocator),
            }
        },
        else => printInstruction()
    }
}

const instruction: []const u8 =
\\ Usage:
\\     zig build run <Day>
\\
\\ Day:
\\     day01, day02, etc.
\\
\\ Example:
\\     zig build run day01
;

fn printInstruction() void {
    std.debug.print("{s}\n", .{instruction});
}
