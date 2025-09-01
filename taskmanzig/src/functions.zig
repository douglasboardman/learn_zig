const std = @import("std");

pub const InputReader = struct {
    stdin: std.fs.File,
    buffer: [1024]u8,
    position: usize,
    length: usize,

    pub fn init() !InputReader {
        return InputReader{
            .stdin = std.fs.File.stdin(),
            .buffer = undefined,
            .position = 0,
            .length = 0,
        };
    }

    pub fn read(self: *InputReader) ![]const u8 {
        const bytes_read = try self.stdin.read(&self.buffer);
        self.length = bytes_read;
        self.position = 0;
        return self.buffer[0..bytes_read];
    }
};

pub fn printRaw(msg: []const u8) !void {
    try std.fs.File.stdout().writeAll(msg);
}

pub fn consolePrint(comptime format: []const u8, args: anytype) !void {
    var buf: [1024]u8 = undefined;
    const msg = try std.fmt.bufPrint(&buf, format, args);
    if (@import("builtin").os.tag == .windows) {
        const w = std.os.windows;
        const kernel32 = w.kernel32;

        var utf16_buf: [1024]u16 = undefined;
        const len_utf16 = try std.unicode.utf8ToUtf16Le(&utf16_buf, msg);
        const handle = kernel32.GetStdHandle(w.STD_OUTPUT_HANDLE) orelse return error.Unexpected;

        var written: w.DWORD = 0;
        if (kernel32.WriteConsoleW(
            handle,
            &utf16_buf,
            @intCast(len_utf16), // conversão necessária
            &written,
            null,
        ) == 0) {
            return error.Unexpected;
        }
    } else {
        try printRaw(msg);
    }
}

pub const Color = enum {
    reset,
    black,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,
    bright_black,
    bright_red,
    bright_green,
    bright_yellow,
    bright_blue,
    bright_magenta,
    bright_cyan,
    bright_white,

    pub fn code(self: Color) []const u8 {
        return switch (self) {
            .reset => "\x1b[0m",
            .black => "\x1b[30m",
            .red => "\x1b[31m",
            .green => "\x1b[32m",
            .yellow => "\x1b[33m",
            .blue => "\x1b[34m",
            .magenta => "\x1b[35m",
            .cyan => "\x1b[36m",
            .white => "\x1b[37m",
            .bright_black => "\x1b[90m",
            .bright_red => "\x1b[91m",
            .bright_green => "\x1b[92m",
            .bright_yellow => "\x1b[93m",
            .bright_blue => "\x1b[94m",
            .bright_magenta => "\x1b[95m",
            .bright_cyan => "\x1b[96m",
            .bright_white => "\x1b[97m",
        };
    }
};

pub fn printColor(msg: []const u8, color: Color) !void {
    try consolePrint("{s}{s}{s}", .{ color.code(), msg, Color.reset.code() });
}
