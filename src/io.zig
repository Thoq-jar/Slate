const std = @import("std");
const fs = std.fs;
pub fn info(comptime fmt: []const u8, args: anytype) void {
    const now = std.time.nanoTimestamp();
    const seconds = @divFloor(now, std.time.ns_per_s);
    const nanos = @mod(now, std.time.ns_per_s);
    const micros = @divFloor(nanos, std.time.ns_per_us);

    const ts = std.time.epoch.EpochSeconds{ .secs = @intCast(seconds) };
    const days = ts.getDaySeconds();

    std.debug.print("[Slate] [{d:0>2}:{d:0>2}:{d:0>2}.{d:0>6}.{d:0>3}] [+] " ++ fmt ++ "\n", .{
        days.getHoursIntoDay(),
        days.getMinutesIntoHour(),
        days.getSecondsIntoMinute(),
        micros,
        @mod(nanos, std.time.ns_per_us),
    } ++ args);
}

pub fn err(comptime fmt: []const u8, args: anytype) void {
    const now = std.time.nanoTimestamp();
    const seconds = @divFloor(now, std.time.ns_per_s);
    const nanos = @mod(now, std.time.ns_per_s);
    const micros = @divFloor(nanos, std.time.ns_per_us);

    const ts = std.time.epoch.EpochSeconds{ .secs = @intCast(seconds) };
    const days = ts.getDaySeconds();

    std.debug.print("[Slate] [{d:0>2}:{d:0>2}:{d:0>2}.{d:0>6}.{d:0>3}] [-] " ++ fmt ++ "\n", .{
        days.getHoursIntoDay(),
        days.getMinutesIntoHour(),
        days.getSecondsIntoMinute(),
        micros,
        @mod(nanos, std.time.ns_per_us),
    } ++ args);
}

pub fn loadFile(root: []const u8, path: []const u8) ![]u8 {
    const localPath = if (path[0] == '/') path[1..] else path;
    const fullPath = try std.fs.path.join(std.heap.page_allocator, &[_][]const u8{ root, localPath });
    defer std.heap.page_allocator.free(fullPath);

    info("Loading file: {s}", .{fullPath});

    const file = fs.cwd().openFile(fullPath, .{}) catch |e| switch (e) {
        error.FileNotFound => {
            err("File not found: {s}", .{fullPath});
            return error.FileNotFound;
        },
        else => return e,
    };
    defer file.close();

    const memory = std.heap.page_allocator;
    const maxSize = std.math.maxInt(usize);
    return try file.readToEndAlloc(memory, maxSize);
}
