const std = @import("std");
const root = @import("root.zig");

const Allocator = std.mem.Allocator;

const Direction = enum { L, R };

const Instruction = struct {
    direction: Direction,
    distance: u32,
};

const Data = struct {
    instructions: std.MultiArrayList(Instruction),
    click: usize,

    const Self = @This();

    fn new() Self {
        return Self {
            .instructions = .{},
            .click = 0,
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

    const Items = struct {
        direction: *const []Direction,
        distance: *const []u32,
    };

    fn getItems(self: *Self) Items {
        return Items {
            .direction = &self.instructions.items(std.meta.FieldEnum(Instruction).direction),
            .distance = &self.instructions.items(std.meta.FieldEnum(Instruction).distance)
        };
    }

    inline fn reset(self: *Self) void {
        self.click = 0;
    }

    fn process_part_1(self: *Self) void {
        var start: u32 = 50;
        const items = self.getItems();

        for (items.direction.*, items.distance.*) |dir, dis| {
            const rem = dis % 100;

            switch (dir) {
                .L => {
                    const dec: u32 = @intCast(@intFromBool(rem > start));
                    start = dec * 100 + start - rem;
                },
                .R => {
                    const inc: u32 = @intCast(@intFromBool(start + rem > 99));
                    start = start + rem - inc * 100;
                },
            }

            self.click += @intFromBool(start == 0);
        }

        std.debug.print("\nResult part 1 is: {d}\n\n", .{ self.click });
    }

    fn process_part_2(self: *Self, comptime log: bool) void {
        self.reset();
        var start: u32 = 50;
        const items = self.getItems();

        for (items.direction.*, items.distance.*) |dir, dis| {
            self.click += dis / 100;
            var remDist: u32 = 0;
            if (log) { std.debug.print("{d:3} => {any}{d:<3} => ", .{ start, dir, dis }); }

            switch (dir) {
                .L => {
                    remDist = 100 - (dis % 100);
                    self.click += @intFromBool((dis % 100) > start and start > 0);
                    if (log) { std.debug.print("current: {d:2} . remDist: {d:2} . ", .{ start, remDist }); }
                },
                .R => {
                    remDist = dis % 100;
                    self.click += @intFromBool(start + remDist > 100);
                    if (log) { std.debug.print("current: {d:2} . remDist: {d:2} . ", .{ start, remDist }); }
                },
            }

            start = (start + remDist) % 100;
            self.click += @intFromBool(start == 0);
            if (log) { std.debug.print("click: {d:04} => [ {d:2} ]\n", .{ self.click, start }); }
        }

        if (log) { std.debug.print("\n", .{}); }
        std.debug.print("Result part 2 is: {d}\n", .{ self.click });
    }
};

fn parseInput(input: []const u8, allocator: *const Allocator, data: *Data) !void {
    const len = input.len - 1;
    try data.init(allocator, len / 3);

    var iter = std.mem.splitSequence(u8, input[0..len], "\n");

    while (iter.next()) |inst| {
        const distance = try std.fmt.parseInt(u32, inst[1..], 10);

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
    data.process_part_1();
    data.process_part_2(false);
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
    data.process_part_1();
}

test "day02" {
    const allocator = std.testing.allocator;
    var data = Data.new();
    defer data.deinit(&allocator);

    try parseInput(testInput, &allocator, &data);
    data.process_part_2(true);
}
