const std = @import("std");
const root = @import("root.zig");

const Allocator = std.mem.Allocator;

const Direction = enum { L, R };

const Instruction = struct {
    direction: Direction,
    distance: u16,
};

const Data = struct {
    instructions: std.MultiArrayList(Instruction),
    zero: usize,

    const Self = @This();

    fn new() Self {
        return Self {
            .instructions = .{},
            .zero = 0,
        };
    }

    fn init(self: *Self, allocator: *const Allocator, capacity: usize) !void {
        try self.instructions.setCapacity(allocator.*, capacity);
    }

    fn push(self: *Self, instruction: Instruction) void {
        self.instructions.appendAssumeCapacity(instruction);
    }

    fn deinit(self: *Self, allocator: *const Allocator) void {
        self.instructions.deinit(allocator.*);
    }

    fn run(self: *Self) void {
        var start: u16 = 50;
        const direction: []Direction = self.instructions.items(std.meta.FieldEnum(Instruction).direction);
        const distance: []u16 = self.instructions.items(std.meta.FieldEnum(Instruction).distance);

        for (direction, distance) |dir, dis| {
            processInstruction(&start, dir, dis, &self.zero);
        }

        std.debug.print("\nResult is: {d}\n", .{ self.zero });
    }
};

fn processInstruction(start: *u16, direction: Direction, distance: u16, count: *usize) void {
    const rem = distance % 100;

    switch (direction) {
        .L => {
            const dec: u16 = @intCast(@intFromBool(rem > start.*));
            start.* = dec * 100 + start.* - rem;
        },
        .R => {
            const inc: u16 = @intCast(@intFromBool(start.* + rem > 99));
            start.* = start.* + rem - inc * 100;
        },
    }

    count.* += @intFromBool(start.* == 0);
}

fn parseInput(input: []const u8, allocator: *const Allocator, data: *Data) !void {
    const len = input.len - 1;
    const i = input[0..len];
    var iter = std.mem.splitSequence(u8, i, "\n");

    try data.init(allocator, len / 3);

    while (iter.next()) |inst| {
        const distance = try std.fmt.parseInt(u16, inst[1..], 10);

        if (std.ascii.startsWithIgnoreCase(inst, "L")) {
            data.push(.{ .direction = Direction.L, .distance = distance });
        } else {
            data.push(.{ .direction = Direction.R, .distance = distance });
        }
    }
}

pub fn run(allocator: *const Allocator) !void {
    const input = try root.read_input(allocator, "puzzle_input/day01.txt");
    defer allocator.free(input);

    var data = Data.new();
    defer data.deinit(allocator);

    try parseInput(input, allocator, &data);
    data.run();
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

test "day01" {
    const allocator = std.testing.allocator;
    var data = Data.new();
    defer data.deinit(&allocator);

    try parseInput(testInput, &allocator, &data);
    data.run();
}
