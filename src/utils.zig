const std = @import("std");
const HTTPHeader = @import("deffinitions.zig").HTTPHeader;
const HeaderNames = @import("deffinitions.zig").HeaderNames;
const ServeFileError = @import("deffinitions.zig").ServeFileError;
const mem = std.mem;
const mimeTypes = @import("deffinitions.zig").mimeTypes;

pub fn mimeForPath(path: []const u8) []const u8 {
    const extension = std.fs.path.extension(path);
    inline for (mimeTypes) |kv| {
        if (mem.eql(u8, extension, kv[0])) return kv[1];
    }
    return "application/octet-stream";
}

pub fn parseHeader(header: []const u8) !HTTPHeader {
    var headerStruct = HTTPHeader{
        .requestLine = undefined,
        .host = undefined,
        .userAgent = undefined,
    };
    var headerIter = mem.tokenizeSequence(u8, header, "\r\n");
    headerStruct.requestLine = headerIter.next() orelse return ServeFileError.HeaderMalformed;
    while (headerIter.next()) |line| {
        const nameSlice = mem.sliceTo(line, ':');
        if (nameSlice.len == line.len) return ServeFileError.HeaderMalformed;
        const headerName = std.meta.stringToEnum(HeaderNames, nameSlice) orelse continue;
        const headerValue = mem.trimLeft(u8, line[nameSlice.len + 1 ..], " ");
        switch (headerName) {
            .Host => headerStruct.host = headerValue,
            .@"User-Agent" => headerStruct.userAgent = headerValue,
        }
    }
    return headerStruct;
}
