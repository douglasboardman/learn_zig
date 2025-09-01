const std = @import("std");
const print = std.debug.print;
const heap = std.heap;
const mem = std.mem;
const unicode = std.unicode;

fn asBytes(allocator: mem.Allocator, code_points: []const u21) ![]u8 {
    var list = try std.ArrayList(u8).initCapacity(allocator, 0);
    defer list.deinit(allocator);

    var buf: [4]u8 = undefined;

    for (code_points) |cp| {
        const len = try unicode.utf8Encode(cp, &buf);
        try list.appendSlice(allocator, buf[0..len]);
    }

    return try list.toOwnedSlice(allocator);
}

fn asCodePointsAlloc(allocator: mem.Allocator, str: []const u8) ![]u21 {
    var list = try std.ArrayList(u21).initCapacity(allocator, 0);
    defer list.deinit(allocator);

    var view = try unicode.Utf8View.init(str);
    var iter = view.iterator();

    while (iter.nextCodepoint()) |cp| try list.append(allocator, cp);

    return try list.toOwnedSlice(allocator);
}

fn asCodePoints(str: []const u8, out: []u21) ![]u21 {
    var view = try unicode.Utf8View.init(str);
    var iter = view.iterator();

    var i: usize = 0;
    while (iter.nextCodepoint()) |cp| : (i += 1) out[i] = cp;

    return out[0..i];
}

fn fail() !void {
    return error.Fail;
}

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const ptr = try allocator.create(u8);
    defer allocator.destroy(ptr);
    ptr.* = 42;

    print("{*}\n", .{ptr});

    // try fail();

    const slice = try allocator.alloc(u8, 2);
    defer allocator.free(slice);

    slice[0] = 42;
    slice[1] = 43;

    print("{any}\n", .{slice});

    const code_points_in = [_]u21{ 'H', 'é', 'l', 'l', 'o', ' ', 'ç' };
    // _ = code_points_in;

    const str_out = try asBytes(allocator, &code_points_in);
    defer allocator.free(str_out);

    for (str_out) |b| print("{x} ", .{b});
    print("\n", .{});

    // const code_points_out = try asCodePointsAlloc(allocator, str_out);
    // defer allocator.free(code_points_out);
    const str_in = "Héllo ç";
    var buf: [str_in.len]u21 = undefined;
    const code_points_out = try asCodePoints(str_out, &buf);

    for (code_points_out) |cp| print("{u} ", .{cp});
    print("\n", .{});
}
