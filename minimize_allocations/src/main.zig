const std = @import("std");

pub fn main() !void {
    // try usingHeapAllocation();
    // try usingStackAllocation();
    // try usingFixedBuffer();
    try usingFixedCapacityArrayList();
}

// Exemplo de uso de alocator para gravar dados dinamicamente no heap. Contudo, essa
// abordagem pode não ser a mais adequada quando se tratar de sistemas embarcados e
// runtime applications
fn usingHeapAllocation() !void {
    // Alocação padrão no heap utilizando alocador
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Alocando uma array no heap utilizando allocator
    const numbers = try allocator.alloc(i32, 10);
    numbers[0] = 42;
    defer allocator.free(numbers);

    // Recuperando valores alocados no array
    std.debug.print("Using Heap Allocation:\n", .{});
    std.debug.print("The first number is: {}\n", .{numbers[0]});
}

// Utilizando a alocação de pilha ou stack. A alocação em pilha é simples e eficiente
// porém possui limitações de tamanho.
fn usingStackAllocation() !void {
    var stack_array: [10]i32 = undefined;

    stack_array[0] = 42;
    std.debug.print("Using Stack Allocation:\n", .{});
    std.debug.print("The first number is {}\n", .{stack_array[0]});
}

// Fixed buffer allocation
fn usingFixedBuffer() !void {
    // Buffer prealocado
    var buffer: [1024]u8 = undefined;

    // Allocador para o buffer fixo
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    // Uso do alocador, porém sem realizar alocação no heap
    const data = try allocator.alloc(i32, 10);

    // Utilizando os dados
    data[0] = 42;
    std.debug.print("Using Fixed Buffer Allocation:\n", .{});
    std.debug.print("The first number is {}\n", .{data[0]});

    // Não é necessário fazer alocações individuais ou mesmo limpar alocações feitas
    // O buffer inteiro é reivindicado quando o contexto do seu escopo é deixado
}

fn usingFixedCapacityArrayList() !void {
    var list = FixedCapacityArrayList(i32, 10).init;

    try list.append(10);
    try list.append(20);
    try list.append(30);

    std.debug.print("Appended items: ", .{});
    for (list.slice()) |item| {
        std.debug.print("{} ", .{item});
    }

    if (list.pop()) |item| {
        std.debug.print("\nPopped: {}", .{item});
    }

    std.debug.print("\nRemaining items: {any}", .{list.slice()});
}

pub fn FixedCapacityArrayList(comptime T: type, comptime capacity: usize) type {
    return struct {
        const Self = @This();
        pub const init: Self = .{};

        items: [capacity]T = undefined,
        len: usize = 0,

        pub fn append(self: *Self, item: T) !void {
            if (self.len >= capacity) {
                return error.ArrayListFull;
            }
            self.items[self.len] = item;
            self.len += 1;
        }

        pub fn pop(self: *Self) ?T {
            if (self.len == 0) {
                return null;
            }
            self.len -= 1;
            return self.items[self.len];
        }

        pub fn slice(self: *const Self) []const T {
            return self.items[0..self.len];
        }

        pub fn clear(self: *Self) void {
            self.len = 0;
        }
    };
}
