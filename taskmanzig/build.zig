const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 1. Define o módulo 'functions' a partir do arquivo-fonte.
    const functions_mod = b.addModule("functions", .{
        .root_source_file = b.path("src/functions.zig"),
    });

    // 2. Define o executável.
    const exe = b.addExecutable(.{
        .name = "taskmanzig",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "functions", .module = functions_mod },
            },
        }),
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run tests");

    // A definição de teste simplesmente reutiliza o módulo raiz do executável,
    // que já contém as configurações de target, optimize e imports.
    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
        // As linhas .target e .optimize foram removidas daqui, pois são redundantes e incorretas.
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);
    test_step.dependOn(&run_exe_tests.step);
}
