const std = @import("std");
const Io = @import("io.zig");
const utils = @import("utils.zig");
const router = @import("router.zig");
const Config = @import("config.zig").Config;
const http404 = @import("404.zig").http404;
const HTTPHeader = @import("deffinitions.zig").HTTPHeader;
const Reset = @import("deffinitions.zig").Reset;
const Purple = @import("deffinitions.zig").Purple;
const HeaderNames = @import("deffinitions.zig").HeaderNames;
const ServeFileError = @import("deffinitions.zig").ServeFileError;
const mimeForPath = @import("utils.zig").mimeForPath;
const net = std.net;
const mem = std.mem;
const expect = std.testing.expect;
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    const config = try Config.load();
    const self_addr = try net.Address.resolveIp(config.host, config.port);
    var listener = try self_addr.listen(.{ .reuse_address = true });

    try stdout.print("\n{s} ● Slate v1.2\n\n", .{Purple});

    const file_info = try std.fmt.allocPrint(std.heap.page_allocator, "  - Local: http://{s}:{d}\n  - File:  {s}{s}\n", .{ config.display_host, config.port, config.main, Reset });
    defer std.heap.page_allocator.free(file_info);

    try stdout.print("{s}\n", .{file_info});
    Io.info("Ready! Press Ctrl+C to exit", .{});

    while (listener.accept()) |conn| {
        const start = std.time.milliTimestamp();
        Io.info("Accepted connection from: {}", .{conn.address});
        var recv_buf: [4096]u8 = undefined;
        var recv_total: usize = 0;
        while (conn.stream.read(recv_buf[recv_total..])) |recv_len| {
            if (recv_len == 0) break;
            recv_total += recv_len;
            if (mem.containsAtLeast(u8, recv_buf[0..recv_total], 1, "\r\n\r\n")) {
                break;
            }
        } else |read_err| {
            return read_err;
        }
        const recv_data = recv_buf[0..recv_total];
        if (recv_data.len == 0) {
            Io.err("Got connection but no header!", .{});
            continue;
        }
        const header = try utils.parseHeader(recv_data);
        const path = router.route(header.requestLine, &config.routes) catch |err| {
            switch (err) {
                error.ProtoNotSupported => {
                    Io.err("Protocol not supported", .{});
                    _ = try conn.stream.writer().write("HTTP/1.1 505 HTTP Version Not Supported\r\n\r\n");
                    continue;
                },
                error.MethodNotSupported => {
                    Io.err("Method not supported", .{});
                    _ = try conn.stream.writer().write("HTTP/1.1 405 Method Not Allowed\r\n\r\n");
                    continue;
                },
                else => return err,
            }
        };
        const mime = mimeForPath(path);
        const buf = Io.loadFile(config.src, path) catch |err| {
            if (err == error.FileNotFound) {
                if (config.error_404) |error_page| {
                    const error_content = Io.loadFile(config.src, error_page) catch {
                        _ = try conn.stream.writer().write(http404());
                        continue;
                    };
                    const error_mime = mimeForPath(error_page);
                    const error_head =
                        "HTTP/1.1 404 NOT FOUND\r\n" ++
                        "Connection: close\r\n" ++
                        "Content-Type: {s}\r\n" ++
                        "Content-Length: {}\r\n" ++
                        "\r\n";
                    _ = try conn.stream.writer().print(error_head, .{ error_mime, error_content.len });
                    _ = try conn.stream.writer().write(error_content);
                } else {
                    _ = try conn.stream.writer().write(http404());
                }
                continue;
            } else {
                return err;
            }
        };
        const end = std.time.milliTimestamp();
        const latency = end - start;
        Io.info("{s} ......... {d}ms", .{ path, latency });
        const httpHead =
            "HTTP/1.1 200 OK \r\n" ++
            "Connection: close\r\n" ++
            "Content-Type: {s}\r\n" ++
            "Content-Length: {}\r\n" ++
            "\r\n";
        _ = try conn.stream.writer().print(httpHead, .{ mime, buf.len });
        _ = try conn.stream.writer().write(buf);
    } else |err| {
        Io.err("error in accept: {}", .{err});
    }
}
