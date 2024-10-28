const std = @import("std");
const ConfigError = @import("deffinitions.zig").ConfigError;
const fs = std.fs;

pub const Config = struct {
    display_host: []const u8,
    host: []const u8,
    port: u16,
    src: []const u8,
    main: []const u8,
    error_404: ?[]const u8,
    routes: std.StringHashMap([]const u8),

    pub fn load() !Config {
        const file = try fs.cwd().openFile("config.slate", .{});
        defer file.close();

        const content = try file.readToEndAlloc(std.heap.page_allocator, 1024);
        defer std.heap.page_allocator.free(content);

        var config = Config{
            .display_host = "localhost",
            .host = "127.0.0.1",
            .port = 8080,
            .src = "src/",
            .main = "index.html",
            .error_404 = null,
            .routes = std.StringHashMap([]const u8).init(std.heap.page_allocator),
        };

        var lines = std.mem.split(u8, content, "\n");
        while (lines.next()) |line| {
            if (line.len == 0) continue;

            var kv = std.mem.split(u8, line, ":");
            const key = kv.next() orelse continue;
            const value = kv.next() orelse continue;
            const trimmed_value = std.mem.trim(u8, value, " \t\r\n");

            if (std.mem.eql(u8, key, "host")) {
                if (std.mem.eql(u8, trimmed_value, "localhost")) {
                    std.debug.print("[-] localhost not allowed! (Use 127.0.0.1 instead)\n", .{});
                    return ConfigError.LocalhostNotAllowed;
                }
                config.display_host = try std.heap.page_allocator.dupe(u8, trimmed_value);
                config.host = try std.heap.page_allocator.dupe(u8, trimmed_value);
                continue;
            }

            if (std.mem.eql(u8, key, "port")) {
                config.port = try std.fmt.parseInt(u16, value, 10);
                continue;
            }

            if (std.mem.eql(u8, key, "src")) {
                config.src = try std.heap.page_allocator.dupe(u8, value);
                continue;
            }

            if (std.mem.eql(u8, key, "main")) {
                config.main = try std.heap.page_allocator.dupe(u8, value);
                continue;
            }

            if (std.mem.eql(u8, key, "routes")) {
                var routes = std.mem.split(u8, trimmed_value, "|");
                while (routes.next()) |route| {
                    var route_parts = std.mem.split(u8, route, "=");
                    const route_path = route_parts.next() orelse continue;
                    const route_file = route_parts.next() orelse continue;
                    try config.routes.put(try std.heap.page_allocator.dupe(u8, route_path), try std.heap.page_allocator.dupe(u8, route_file));
                }
                continue;
            }

            if (std.mem.eql(u8, key, "404")) {
                config.error_404 = try std.heap.page_allocator.dupe(u8, trimmed_value);
                continue;
            }
        }

        return config;
    }

    pub fn deinit(self: *Config) void {
        var routes_iterator = self.routes.iterator();
        while (routes_iterator.next()) |entry| {
            std.heap.page_allocator.free(entry.key_ptr.*);
            std.heap.page_allocator.free(entry.value_ptr.*);
        }
        self.routes.deinit();
    }
};
