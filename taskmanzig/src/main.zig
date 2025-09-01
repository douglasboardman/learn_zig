const std = @import("std");
const functions = @import("functions");
const Color = functions.Color;
const printColor = functions.printColor;
const ArrayList = std.ArrayList;
const consolePrint = functions.consolePrint;

const Category = struct { name: []const u8, color: Color };

const TaskStatus = enum {
    completed,
    in_progress,
    pending,

    pub fn toString(self: TaskStatus) []const u8 {
        return switch (self) {
            .completed => "Concluída",
            .in_progress => "Em andamento",
            .pending => "A fazer",
        };
    }
};

const Task = struct {
    description: []const u8,
    category: Category,
    status: TaskStatus,
};

pub fn main() !void {
    // Instanciando o allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Inicializando lista de categorias
    var cat_list = try ArrayList(Category).initCapacity(allocator, 0);
    try initCatList(allocator, &cat_list);
    defer cat_list.deinit(allocator);

    // Alocando o tasks_list
    var tasks_list = try ArrayList(Task).initCapacity(allocator, 0);
    try initTaskList(allocator, &tasks_list, &cat_list);
    defer tasks_list.deinit(allocator);

    // Inicializa o leitor
    var reader = try functions.InputReader.init();

    while (true) {
        try printMenu();

        // Realiza e ajusta a leitura da entrada do usuário
        const input = try reader.read();
        const trimmed_input = std.mem.trimRight(u8, input, "\r\n");

        if (trimmed_input.len == 0) continue;

        if (std.mem.eql(u8, trimmed_input, "sair")) {
            try consolePrint("\nAté mais!\n", .{});
            break;
        } else if (std.mem.eql(u8, trimmed_input, "list")) {
            try consolePrint("\n--- Lista de Tarefas ---\n", .{});
            try printTasks(&tasks_list); // Função para listar tarefas
        } else if (std.mem.eql(u8, trimmed_input, "add")) {
            try consolePrint("Comando 'add' recebido. Lógica a ser implementada.\n", .{});
        } else {
            try consolePrint("Comando inválido: \"{s}\"\n", .{trimmed_input});
        }
    }
}

fn printMenu() !void {
    try consolePrint("\n--- TaskManZig Menu ---\n", .{});
    try consolePrint("Comandos: list, add, sair\n", .{});
    try consolePrint("Digite um comando: ", .{});
}

// Adicionei o allocator como parâmetro aqui para consistência
fn initTaskList(allocator: std.mem.Allocator, t_list: *ArrayList(Task), c_list: *ArrayList(Category)) !void {
    try t_list.append(allocator, Task{
        .description = "Levar o carro para lavar",
        .category = getCategoryOrDefault(c_list, "Casa"),
        .status = .completed,
    });
    try t_list.append(allocator, Task{
        .description = "Aprender sobre Allocators e ArrayList em Zig",
        .category = getCategoryOrDefault(c_list, "Estudos"),
        .status = .in_progress,
    });
    try t_list.append(allocator, Task{
        .description = "Fazer leitura dos e-mails pendentes",
        .category = getCategoryOrDefault(c_list, "Trabalho"),
        .status = .pending,
    });
}

// Nova função para imprimir a lista de tarefas sob demanda
fn printTasks(list: *const ArrayList(Task)) !void {
    for (list.items, 0..) |task, i| {
        try consolePrint("\n[{d}] Tarefa: {s}\n", .{ i + 1, task.description });
        try consolePrint("    Categoria: ", .{});
        try printColor(task.category.name, task.category.color);
        try consolePrint("\n", .{});
        try consolePrint("    Status: {s}\n", .{task.status.toString()});
    }
}

fn initCatList(allocator: std.mem.Allocator, c_list: *ArrayList(Category)) !void {
    try c_list.append(allocator, Category{ .name = "Tarefa Padrão", .color = .white });
    try c_list.append(allocator, Category{ .name = "Estudos", .color = .blue });
    try c_list.append(allocator, Category{ .name = "Trabalho", .color = .red });
    try c_list.append(allocator, Category{ .name = "Casa", .color = .magenta });
}

fn getCategoryByName(c_list: *const ArrayList(Category), name: []const u8) ?Category {
    for (c_list.items) |cat| {
        if (std.mem.eql(u8, cat.name, name)) {
            return cat;
        }
    }
    return null;
}

fn getCategoryOrDefault(c_list: *const ArrayList(Category), name: []const u8) Category {
    return getCategoryByName(c_list, name) orelse getCategoryByName(c_list, "Tarefa Padrão").?;
}
