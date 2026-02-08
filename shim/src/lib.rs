// SPDX-License-Identifier: AGPL-3.0-or-later
//! Rust shim for FFmpeg - exposes struct field accessors via C ABI
//!
//! This allows Zig to use FFmpeg without @cImport by providing
//! stable accessor functions for opaque struct fields.

use ffmpeg_sys_next as ff;
use std::ffi::CStr;
use std::os::raw::{c_char, c_int, c_uint};

/// Rational number (matches Zig's AVRational)
#[repr(C)]
pub struct Rational {
    pub num: c_int,
    pub den: c_int,
}

#[no_mangle]
pub extern "C" fn ffmpeg_shim_init() {
    // FFmpeg 5.0+ doesn't require av_register_all()
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_nb_streams(ctx: *const ff::AVFormatContext) -> c_uint {
    (*ctx).nb_streams
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_duration(ctx: *const ff::AVFormatContext) -> i64 {
    (*ctx).duration
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_bit_rate(ctx: *const ff::AVFormatContext) -> i64 {
    (*ctx).bit_rate
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_iformat(
    ctx: *const ff::AVFormatContext,
) -> *const ff::AVInputFormat {
    (*ctx).iformat
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_metadata(
    ctx: *const ff::AVFormatContext,
) -> *mut ff::AVDictionary {
    (*ctx).metadata
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_stream(
    ctx: *const ff::AVFormatContext,
    index: c_uint,
) -> *mut ff::AVStream {
    if index >= (*ctx).nb_streams {
        return std::ptr::null_mut();
    }
    *(*ctx).streams.add(index as usize)
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_stream_codecpar(
    stream: *const ff::AVStream,
) -> *mut ff::AVCodecParameters {
    (*stream).codecpar
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_stream_time_base(stream: *const ff::AVStream) -> Rational {
    let tb = (*stream).time_base;
    Rational {
        num: tb.num,
        den: tb.den,
    }
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_stream_duration(stream: *const ff::AVStream) -> i64 {
    (*stream).duration
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_stream_avg_frame_rate(
    stream: *const ff::AVStream,
) -> Rational {
    let fr = (*stream).avg_frame_rate;
    Rational {
        num: fr.num,
        den: fr.den,
    }
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_codecpar_codec_type(
    par: *const ff::AVCodecParameters,
) -> c_int {
    (*par).codec_type as c_int
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_codecpar_codec_id(
    par: *const ff::AVCodecParameters,
) -> c_int {
    (*par).codec_id as c_int
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_codecpar_width(par: *const ff::AVCodecParameters) -> c_int {
    (*par).width
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_codecpar_height(
    par: *const ff::AVCodecParameters,
) -> c_int {
    (*par).height
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_codecpar_sample_rate(
    par: *const ff::AVCodecParameters,
) -> c_int {
    (*par).sample_rate
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_codecpar_channels(
    par: *const ff::AVCodecParameters,
) -> c_int {
    // FFmpeg 5.1+ uses ch_layout, older uses channels
    #[cfg(feature = "ffmpeg_5_1")]
    {
        (*par).ch_layout.nb_channels
    }
    #[cfg(not(feature = "ffmpeg_5_1"))]
    {
        (*par).channels
    }
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_codecpar_bit_rate(
    par: *const ff::AVCodecParameters,
) -> i64 {
    (*par).bit_rate
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_codec_name(codec: *const ff::AVCodec) -> *const c_char {
    (*codec).name
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_codec_long_name(
    codec: *const ff::AVCodec,
) -> *const c_char {
    (*codec).long_name
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_iformat_name(
    fmt: *const ff::AVInputFormat,
) -> *const c_char {
    (*fmt).name
}

#[no_mangle]
pub unsafe extern "C" fn ffmpeg_shim_get_iformat_long_name(
    fmt: *const ff::AVInputFormat,
) -> *const c_char {
    (*fmt).long_name
}
