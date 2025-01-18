const std = @import("std");
const rlz = @import("raylib-zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const opt = b.standardOptimizeOption(.{});

    const raylib_dep = b.dependency("raylib-zig", .{
        .target = target,
        .optimize = opt,
    });
    const raylib = raylib_dep.module("raylib");
    const raylib_artifact = raylib_dep.artifact("raylib");
    const exe = b.addExecutable(.{
        .name = "snake",
        .root_source_file = b.path("src/main.zig"),
        .optimize = opt,
        .target = target,
    });
    if (exe.rootModuleTarget().os.tag == .windows) {
        exe.subsystem = .Windows;
    }
    exe.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib);

    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run snake");
    run_step.dependOn(&run_cmd.step);
    b.installArtifact(exe);
}
