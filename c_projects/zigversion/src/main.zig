const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var input: []const u8 = undefined;
    var out = try Stdout.init();
    var in = try Stdin.init(allocator);

    try out.print("Some input request:\n", .{});
    input = try in.read();
    try out.print("The input is: {s}, and it is {d} characters long\n", .{ input, input.len });
    defer allocator.free(input);
}

pub const Stdout = struct {
    stdout: std.fs.File.Writer,
    pub fn init() !Stdout {
        return Stdout{
            .stdout = std.fs.File.stdout().writerStreaming(&.{}),
        };
    }
    pub fn print(self: *Stdout, comptime format: []const u8, args: anytype) !void {
        try self.stdout.interface.print(format, args);
        try self.stdout.interface.flush();
    }
};

pub const Stdin = struct {
    stdin: std.fs.File.Reader,
    buffer: [1024]u8,
    allocator: std.mem.Allocator,
    pub fn init(allocator: std.mem.Allocator) !Stdin {
        return Stdin{
            .stdin = std.fs.File.stdin().readerStreaming(&.{}),
            .buffer = undefined,
            .allocator = allocator,
        };
    }
    pub fn read(self: *Stdin) ![]const u8 {
        const bytes_read = try self.stdin.read(&self.buffer);
        const trimmed_slice = std.mem.trim(u8, self.buffer[0..bytes_read], "\n\r");
        return try self.allocator.dupe(u8, trimmed_slice);
    }
};
