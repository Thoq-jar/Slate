const std = @import("std");
const ServeFileError = @import("deffinitions.zig").ServeFileError;
const mem = std.mem;

pub fn route(requestLine: []const u8, routes: *const std.StringHashMap([]const u8)) ![]const u8 {
    var requestLineIter = mem.tokenizeScalar(u8, requestLine, ' ');
    const method = requestLineIter.next().?;
    const path = requestLineIter.next().?;
    const proto = requestLineIter.next().?;

    if (!mem.eql(u8, method, "GET")) return ServeFileError.MethodNotSupported;
    if (path.len <= 0) return error.NoPath;
    if (!mem.eql(u8, proto, "HTTP/1.1")) return ServeFileError.ProtoNotSupported;

    if (routes.get(path)) |route_file| {
        return route_file;
    }

    return path;
}
