// SPDX-License-Identifier: AGPL-3.0-or-later
//! Zig FFI bindings for FFmpeg (libavformat, libavcodec, libavutil)
//!
//! Provides high-level Zig interface for video/audio metadata extraction
//! and format operations, replacing subprocess calls to ffprobe/ffmpeg.
//!
//! C-free: Uses extern "C" declarations linking directly to FFmpeg libraries.
//! No @cImport, no C headers at build time.

const std = @import("std");

// =============================================================================
// FFmpeg extern declarations (C ABI)
// =============================================================================

// Opaque types
const AVFormatContext = opaque {};
const AVCodecContext = opaque {};
const AVCodec = opaque {};
const AVStream = opaque {};
const AVCodecParameters = opaque {};
const AVDictionary = opaque {};
const AVDictionaryEntry = extern struct {
    key: [*:0]const u8,
    value: [*:0]const u8,
};
const AVInputFormat = opaque {};

const AVRational = extern struct {
    num: c_int,
    den: c_int,
};

const AVChannelLayout = extern struct {
    // Simplified - just need nb_channels
    order: c_int,
    nb_channels: c_int,
    // ... other fields we don't use
};

// Media types
const AVMEDIA_TYPE_UNKNOWN: c_int = -1;
const AVMEDIA_TYPE_VIDEO: c_int = 0;
const AVMEDIA_TYPE_AUDIO: c_int = 1;
const AVMEDIA_TYPE_DATA: c_int = 2;
const AVMEDIA_TYPE_SUBTITLE: c_int = 3;
const AVMEDIA_TYPE_ATTACHMENT: c_int = 4;

// Constants
const AV_NOPTS_VALUE: i64 = @bitCast(@as(u64, 0x8000000000000000));
const AV_TIME_BASE: c_int = 1000000;
const AV_DICT_IGNORE_SUFFIX: c_int = 2;

// libavformat functions
extern "C" fn avformat_open_input(
    ps: *?*AVFormatContext,
    url: [*:0]const u8,
    fmt: ?*const AVInputFormat,
    options: ?*?*AVDictionary,
) c_int;

extern "C" fn avformat_find_stream_info(
    ic: *AVFormatContext,
    options: ?*?*AVDictionary,
) c_int;

extern "C" fn avformat_close_input(ps: *?*AVFormatContext) void;

extern "C" fn av_dump_format(
    ic: *AVFormatContext,
    index: c_int,
    url: [*:0]const u8,
    is_output: c_int,
) void;

// libavcodec functions
extern "C" fn avcodec_find_decoder(id: c_int) ?*const AVCodec;

// libavutil functions
extern "C" fn av_dict_get(
    m: ?*const AVDictionary,
    key: [*:0]const u8,
    prev: ?*const AVDictionaryEntry,
    flags: c_int,
) ?*const AVDictionaryEntry;

extern "C" fn av_version_info() [*:0]const u8;

// Accessor functions for opaque struct fields (we'll implement these in a shim or use offsets)
// For now, we'll create a Rust shim that exposes these

// Rust shim functions (from libffmpeg_shim.so)
extern "C" fn ffmpeg_shim_init() void;
extern "C" fn ffmpeg_shim_get_nb_streams(ctx: *AVFormatContext) c_uint;
extern "C" fn ffmpeg_shim_get_duration(ctx: *AVFormatContext) i64;
extern "C" fn ffmpeg_shim_get_bit_rate(ctx: *AVFormatContext) i64;
extern "C" fn ffmpeg_shim_get_iformat(ctx: *AVFormatContext) ?*const AVInputFormat;
extern "C" fn ffmpeg_shim_get_metadata(ctx: *AVFormatContext) ?*AVDictionary;
extern "C" fn ffmpeg_shim_get_stream(ctx: *AVFormatContext, index: c_uint) ?*AVStream;
extern "C" fn ffmpeg_shim_get_stream_codecpar(stream: *AVStream) *AVCodecParameters;
extern "C" fn ffmpeg_shim_get_stream_time_base(stream: *AVStream) AVRational;
extern "C" fn ffmpeg_shim_get_stream_duration(stream: *AVStream) i64;
extern "C" fn ffmpeg_shim_get_stream_avg_frame_rate(stream: *AVStream) AVRational;
extern "C" fn ffmpeg_shim_get_codecpar_codec_type(par: *AVCodecParameters) c_int;
extern "C" fn ffmpeg_shim_get_codecpar_codec_id(par: *AVCodecParameters) c_int;
extern "C" fn ffmpeg_shim_get_codecpar_width(par: *AVCodecParameters) c_int;
extern "C" fn ffmpeg_shim_get_codecpar_height(par: *AVCodecParameters) c_int;
extern "C" fn ffmpeg_shim_get_codecpar_sample_rate(par: *AVCodecParameters) c_int;
extern "C" fn ffmpeg_shim_get_codecpar_channels(par: *AVCodecParameters) c_int;
extern "C" fn ffmpeg_shim_get_codecpar_bit_rate(par: *AVCodecParameters) i64;
extern "C" fn ffmpeg_shim_get_codec_name(codec: *const AVCodec) [*:0]const u8;
extern "C" fn ffmpeg_shim_get_codec_long_name(codec: *const AVCodec) [*:0]const u8;
extern "C" fn ffmpeg_shim_get_iformat_name(fmt: *const AVInputFormat) [*:0]const u8;
extern "C" fn ffmpeg_shim_get_iformat_long_name(fmt: *const AVInputFormat) [*:0]const u8;

// =============================================================================
// Zig API
// =============================================================================

pub const Error = error{
    OpenFailed,
    StreamInfoFailed,
    NoStreams,
    InvalidStream,
    CodecNotFound,
    AllocationFailed,
};

/// Media stream type
pub const StreamType = enum {
    video,
    audio,
    subtitle,
    data,
    attachment,
    unknown,

    pub fn fromAvMediaType(media_type: c_int) StreamType {
        return switch (media_type) {
            AVMEDIA_TYPE_VIDEO => .video,
            AVMEDIA_TYPE_AUDIO => .audio,
            AVMEDIA_TYPE_SUBTITLE => .subtitle,
            AVMEDIA_TYPE_DATA => .data,
            AVMEDIA_TYPE_ATTACHMENT => .attachment,
            else => .unknown,
        };
    }
};

/// Stream information
pub const StreamInfo = struct {
    index: u32,
    stream_type: StreamType,
    codec_name: ?[]const u8,
    codec_long_name: ?[]const u8,
    width: ?u32,
    height: ?u32,
    sample_rate: ?u32,
    channels: ?u32,
    bit_rate: i64,
    duration_seconds: f64,
    frame_rate: ?f64,
};

/// Media file metadata
pub const MediaInfo = struct {
    format_name: ?[]const u8,
    format_long_name: ?[]const u8,
    duration_seconds: f64,
    bit_rate: i64,
    streams: []StreamInfo,
    metadata: std.StringHashMap([]const u8),

    allocator: std.mem.Allocator,
    format_ctx: *AVFormatContext,

    pub fn deinit(self: *MediaInfo) void {
        self.metadata.deinit();
        self.allocator.free(self.streams);
        var ctx: ?*AVFormatContext = self.format_ctx;
        avformat_close_input(&ctx);
    }
};

/// Probe a media file and extract metadata
/// Equivalent to: ffprobe -show_format -show_streams
pub fn probe(allocator: std.mem.Allocator, path: []const u8) Error!MediaInfo {
    var format_ctx: ?*AVFormatContext = null;

    // Open input file
    const path_z = allocator.dupeZ(u8, path) catch return Error.AllocationFailed;
    defer allocator.free(path_z);

    if (avformat_open_input(&format_ctx, path_z.ptr, null, null) < 0) {
        return Error.OpenFailed;
    }
    errdefer {
        var ctx = format_ctx;
        avformat_close_input(&ctx);
    }

    const ctx = format_ctx orelse return Error.OpenFailed;

    // Get stream info
    if (avformat_find_stream_info(ctx, null) < 0) {
        return Error.StreamInfoFailed;
    }

    const nb_streams = ffmpeg_shim_get_nb_streams(ctx);
    if (nb_streams == 0) {
        return Error.NoStreams;
    }

    // Extract stream information
    var streams = allocator.alloc(StreamInfo, nb_streams) catch return Error.AllocationFailed;
    errdefer allocator.free(streams);

    for (0..nb_streams) |i| {
        const stream = ffmpeg_shim_get_stream(ctx, @intCast(i)) orelse continue;
        const codecpar = ffmpeg_shim_get_stream_codecpar(stream);

        const codec_id = ffmpeg_shim_get_codecpar_codec_id(codecpar);
        const codec = avcodec_find_decoder(codec_id);

        const width = ffmpeg_shim_get_codecpar_width(codecpar);
        const height = ffmpeg_shim_get_codecpar_height(codecpar);
        const sample_rate = ffmpeg_shim_get_codecpar_sample_rate(codecpar);
        const channels = ffmpeg_shim_get_codecpar_channels(codecpar);
        const time_base = ffmpeg_shim_get_stream_time_base(stream);
        const duration = ffmpeg_shim_get_stream_duration(stream);
        const frame_rate = ffmpeg_shim_get_stream_avg_frame_rate(stream);

        streams[i] = StreamInfo{
            .index = @intCast(i),
            .stream_type = StreamType.fromAvMediaType(ffmpeg_shim_get_codecpar_codec_type(codecpar)),
            .codec_name = if (codec) |c| std.mem.span(ffmpeg_shim_get_codec_name(c)) else null,
            .codec_long_name = if (codec) |c| std.mem.span(ffmpeg_shim_get_codec_long_name(c)) else null,
            .width = if (width > 0) @intCast(width) else null,
            .height = if (height > 0) @intCast(height) else null,
            .sample_rate = if (sample_rate > 0) @intCast(sample_rate) else null,
            .channels = if (channels > 0) @intCast(channels) else null,
            .bit_rate = ffmpeg_shim_get_codecpar_bit_rate(codecpar),
            .duration_seconds = timeToSeconds(duration, time_base),
            .frame_rate = rationalToFloat(frame_rate),
        };
    }

    // Extract metadata
    var metadata = std.StringHashMap([]const u8).init(allocator);
    const dict = ffmpeg_shim_get_metadata(ctx);
    var entry: ?*const AVDictionaryEntry = null;
    while (true) {
        entry = av_dict_get(dict, "", entry, AV_DICT_IGNORE_SUFFIX);
        if (entry) |e| {
            const key = std.mem.span(e.key);
            const value = std.mem.span(e.value);
            metadata.put(key, value) catch {};
        } else break;
    }

    const iformat = ffmpeg_shim_get_iformat(ctx);
    const ctx_duration = ffmpeg_shim_get_duration(ctx);

    return MediaInfo{
        .format_name = if (iformat) |fmt| std.mem.span(ffmpeg_shim_get_iformat_name(fmt)) else null,
        .format_long_name = if (iformat) |fmt| std.mem.span(ffmpeg_shim_get_iformat_long_name(fmt)) else null,
        .duration_seconds = timeToSeconds(ctx_duration, .{ .num = 1, .den = AV_TIME_BASE }),
        .bit_rate = ffmpeg_shim_get_bit_rate(ctx),
        .streams = streams,
        .metadata = metadata,
        .allocator = allocator,
        .format_ctx = ctx,
    };
}

/// Get FFmpeg version string
pub fn version() []const u8 {
    return std.mem.span(av_version_info());
}

/// Convert AVRational to float
fn rationalToFloat(r: AVRational) ?f64 {
    if (r.den == 0) return null;
    return @as(f64, @floatFromInt(r.num)) / @as(f64, @floatFromInt(r.den));
}

/// Convert timestamp to seconds
fn timeToSeconds(pts: i64, time_base: AVRational) f64 {
    if (pts == AV_NOPTS_VALUE or time_base.den == 0) {
        return 0.0;
    }
    return @as(f64, @floatFromInt(pts)) * @as(f64, @floatFromInt(time_base.num)) / @as(f64, @floatFromInt(time_base.den));
}

// =============================================================================
// C FFI exports for Rust/Deno/ReScript consumers
// =============================================================================

/// Opaque handle for MediaInfo
pub const FFIMediaInfo = opaque {};

/// C-compatible stream info
pub const CStreamInfo = extern struct {
    index: u32,
    stream_type: u32, // 0=video, 1=audio, 2=subtitle, 3=data, 4=attachment, 5=unknown
    width: u32,
    height: u32,
    sample_rate: u32,
    channels: u32,
    bit_rate: i64,
    duration_seconds: f64,
    frame_rate: f64,
};

var global_allocator: std.mem.Allocator = std.heap.c_allocator;

/// Probe a file and return opaque handle
export fn ffmpeg_probe(path: [*:0]const u8) ?*FFIMediaInfo {
    const info = probe(global_allocator, std.mem.span(path)) catch return null;
    const ptr = global_allocator.create(MediaInfo) catch return null;
    ptr.* = info;
    return @ptrCast(ptr);
}

/// Get duration in seconds
export fn ffmpeg_get_duration(handle: *FFIMediaInfo) f64 {
    const info: *MediaInfo = @ptrCast(@alignCast(handle));
    return info.duration_seconds;
}

/// Get bit rate
export fn ffmpeg_get_bitrate(handle: *FFIMediaInfo) i64 {
    const info: *MediaInfo = @ptrCast(@alignCast(handle));
    return info.bit_rate;
}

/// Get stream count
export fn ffmpeg_get_stream_count(handle: *FFIMediaInfo) u32 {
    const info: *MediaInfo = @ptrCast(@alignCast(handle));
    return @intCast(info.streams.len);
}

/// Get stream info by index
export fn ffmpeg_get_stream(handle: *FFIMediaInfo, index: u32, out: *CStreamInfo) bool {
    const info: *MediaInfo = @ptrCast(@alignCast(handle));
    if (index >= info.streams.len) return false;

    const stream = info.streams[index];
    out.* = CStreamInfo{
        .index = stream.index,
        .stream_type = @intFromEnum(stream.stream_type),
        .width = stream.width orelse 0,
        .height = stream.height orelse 0,
        .sample_rate = stream.sample_rate orelse 0,
        .channels = stream.channels orelse 0,
        .bit_rate = stream.bit_rate,
        .duration_seconds = stream.duration_seconds,
        .frame_rate = stream.frame_rate orelse 0.0,
    };
    return true;
}

/// Free media info handle
export fn ffmpeg_free(handle: *FFIMediaInfo) void {
    const info: *MediaInfo = @ptrCast(@alignCast(handle));
    info.deinit();
    global_allocator.destroy(info);
}

/// Get FFmpeg version
export fn ffmpeg_version() [*:0]const u8 {
    return av_version_info();
}

// =============================================================================
// Tests
// =============================================================================

test "version returns non-empty string" {
    const ver = version();
    try std.testing.expect(ver.len > 0);
}
