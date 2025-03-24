const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "zui",
        .root_module = exe_mod,
    });

    exe.addIncludePath(b.path("vendor"));

    exe.addCSourceFiles(.{
        .root = b.path("vendor"),
        .files = &.{ "glad.c", "stb_image.c" },
        .language = .c,
    });
    exe.linkLibC();
    exe.linkSystemLibrary("glfw3");

    b.installArtifact(exe);
}
