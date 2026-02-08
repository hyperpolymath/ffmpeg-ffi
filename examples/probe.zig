// SPDX-License-Identifier: AGPL-3.0-or-later
//! Example: Probe a media file and print metadata
//!
//! Usage: zig build run -- /path/to/video.mp4

const std = @import("std");
const ffmpeg = @import("ffmpeg");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} <media_file>\n", .{args[0]});
        std.debug.print("\nFFmpeg version: {s}\n", .{ffmpeg.version()});
        return;
    }

    const path = args[1];
    std.debug.print("Probing: {s}\n\n", .{path});

    var info = ffmpeg.probe(allocator, path) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return;
    };
    defer info.deinit();

    // Format info
    std.debug.print("Format: {s}\n", .{info.format_name orelse "unknown"});
    std.debug.print("Duration: {d:.2} seconds\n", .{info.duration_seconds});
    std.debug.print("Bit rate: {} bps\n", .{info.bit_rate});
    std.debug.print("Streams: {}\n\n", .{info.streams.len});

    // Stream details
    for (info.streams) |stream| {
        std.debug.print("Stream #{}: {s}\n", .{ stream.index, @tagName(stream.stream_type) });
        if (stream.codec_name) |codec| {
            std.debug.print("  Codec: {s}\n", .{codec});
        }
        if (stream.width) |w| {
            std.debug.print("  Resolution: {}x{}\n", .{ w, stream.height orelse 0 });
        }
        if (stream.sample_rate) |sr| {
            std.debug.print("  Sample rate: {} Hz, {} channels\n", .{ sr, stream.channels orelse 0 });
        }
        if (stream.frame_rate) |fr| {
            std.debug.print("  Frame rate: {d:.2} fps\n", .{fr});
        }
        std.debug.print("  Duration: {d:.2}s\n\n", .{stream.duration_seconds});
    }

    // Metadata
    std.debug.print("Metadata:\n", .{});
    var it = info.metadata.iterator();
    while (it.next()) |entry| {
        std.debug.print("  {s}: {s}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }
}
