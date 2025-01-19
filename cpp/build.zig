const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "Snake",
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });
    const cflags = [_][]const u8{
        "-pedantic-errors",
        "-Wc++11-extensions",
        "-std=c++17",
        "-g",
    };
    exe.addCSourceFile(.{ .file = b.path("src/main.cpp"), .flags = &cflags });
    exe.linkLibCpp();

    const raylib_dep = b.dependency("raylib", .{ .target = target, .optimize = optimize });
    const raylib_artifact = raylib_dep.artifact("raylib");
    exe.linkLibrary(raylib_artifact);
    exe.addIncludePath(raylib_dep.path("."));
    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run Snake");
    run_step.dependOn(&run_cmd.step);
}
