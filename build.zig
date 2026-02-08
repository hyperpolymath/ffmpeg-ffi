// SPDX-License-Identifier: AGPL-3.0-or-later
//! Build configuration for zig-ffmpeg-ffi
//!
//! Requires FFmpeg development libraries:
//! - Fedora: sudo dnf install ffmpeg-free-devel
//! - Ubuntu: sudo apt install libavformat-dev libavcodec-dev libavutil-dev
//! - macOS: brew install ffmpeg

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Main library
    const lib = b.addStaticLibrary(.{
        .name = "zig-ffmpeg-ffi",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Link FFmpeg libraries
    lib.linkSystemLibrary("avformat");
    lib.linkSystemLibrary("avcodec");
    lib.linkSystemLibrary("avutil");
    lib.linkSystemLibrary("swresample");
    lib.linkSystemLibrary("swscale");
    lib.linkLibC();

    b.installArtifact(lib);

    // Shared library for FFI consumers
    const shared_lib = b.addSharedLibrary(.{
        .name = "ffmpeg_ffi",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    shared_lib.linkSystemLibrary("avformat");
    shared_lib.linkSystemLibrary("avcodec");
    shared_lib.linkSystemLibrary("avutil");
    shared_lib.linkSystemLibrary("swresample");
    shared_lib.linkSystemLibrary("swscale");
    shared_lib.linkLibC();

    b.installArtifact(shared_lib);

    // Example executable
    const example = b.addExecutable(.{
        .name = "ffmpeg-example",
        .root_source_file = b.path("examples/probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    example.root_module.addImport("ffmpeg", &lib.root_module);
    example.linkSystemLibrary("avformat");
    example.linkSystemLibrary("avcodec");
    example.linkSystemLibrary("avutil");
    example.linkLibC();

    const run_example = b.addRunArtifact(example);
    if (b.args) |args| {
        run_example.addArgs(args);
    }

    const run_step = b.step("run", "Run the example");
    run_step.dependOn(&run_example.step);

    // Tests
    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    unit_tests.linkSystemLibrary("avformat");
    unit_tests.linkSystemLibrary("avcodec");
    unit_tests.linkSystemLibrary("avutil");
    unit_tests.linkLibC();

    const run_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);
}
