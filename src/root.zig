//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn read_input(allocator: *const Allocator, file_path: []const u8) ![]const u8 {
    var pathBuffer: [1024]u8 = undefined;
    const path = try std.fs.realpath(file_path, &pathBuffer);
    const file = try std.fs.openFileAbsolute(path, .{ .mode = .read_only });
    defer file.close();

    const fileSize = try file.stat();
    var buffer = try allocator.alloc(u8, @intCast(fileSize.size));
    const len = try file.read(buffer);

    return buffer[0..len];
}
