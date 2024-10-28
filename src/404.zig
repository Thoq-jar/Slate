const std = @import("std");

pub fn http404() []const u8 {
    const not_found_html =
        \\<html>
        \\<head><title>404 Not Found</title></head>
        \\<body>
        \\<h1>We've encountered an error:</h1>
        \\<h2>404 (Not Found)</h2>
        \\<p>Sorry, the file you are looking for does not exist.</p>
        \\<style>
        \\body {
        \\    font-family: sans-serif;
        \\    background-color: #000000;
        \\    color: #999999;
        \\    font-size: 16px;
        \\    padding: 20px;
        \\    text-align: center;
        \\    margin: 0;
        \\    height: 100vh;
        \\    display: flex;
        \\    flex-direction: column;
        \\    justify-content: center;
        \\    align-items: center;
        \\}
        \\</style>
        \\</body>
        \\</html>
    ;

    const response_fmt =
        "HTTP/1.1 404 NOT FOUND\r\n" ++
        "Connection: close\r\n" ++
        "Content-Type: text/html; charset=utf-8\r\n" ++
        "Content-Length: {d}\r\n" ++
        "\r\n" ++
        "{s}";

    var buf: [2048]u8 = undefined;
    return std.fmt.bufPrint(&buf, response_fmt, .{ not_found_html.len, not_found_html }) catch "HTTP/1.1 500 Internal Server Error\r\n\r\n";
}
