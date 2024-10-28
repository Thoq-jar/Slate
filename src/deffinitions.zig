const std = @import("std");
const fs = std.fs;

pub const Purple = "\x1b[35m";
pub const Reset = "\x1b[0m";
pub const ServeFileError = error{
    HeaderMalformed,
    MethodNotSupported,
    ProtoNotSupported,
    UnknownMimeType,
};

pub const ConfigError = error{
    LocalhostNotAllowed,
};

pub const mimeTypes = .{
    .{ ".html", "text/html" },
    .{ ".css", "text/css" },
    .{ ".js", "text/javascript" },
    .{ ".mjs", "text/javascript" },
    .{ ".json", "application/json" },
    .{ ".xml", "application/xml" },
    .{ ".wasm", "application/wasm" },
    .{ ".png", "image/png" },
    .{ ".jpg", "image/jpeg" },
    .{ ".jpeg", "image/jpeg" },
    .{ ".gif", "image/gif" },
    .{ ".webp", "image/webp" },
    .{ ".svg", "image/svg+xml" },
    .{ ".ico", "image/x-icon" },
    .{ ".ttf", "font/ttf" },
    .{ ".otf", "font/otf" },
    .{ ".woff", "font/woff" },
    .{ ".woff2", "font/woff2" },
    .{ ".txt", "text/plain" },
    .{ ".pdf", "application/pdf" },
    .{ ".mp4", "video/mp4" },
    .{ ".webm", "video/webm" },
    .{ ".mp3", "audio/mpeg" },
    .{ ".wav", "audio/wav" },
    .{ ".ogg", "audio/ogg" },
};

pub const HeaderNames = enum {
    Host,
    @"User-Agent",
};

pub const HTTPHeader = struct {
    requestLine: []const u8,
    host: []const u8,
    userAgent: []const u8,

    pub fn print(self: HTTPHeader) void {
        std.debug.print("[+] {s} - {s}\n", .{
            self.requestLine,
            self.host,
        });
    }
};
