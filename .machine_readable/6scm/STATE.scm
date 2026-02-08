;; SPDX-License-Identifier: PMPL-1.0-or-later
;; STATE.scm - Project state for zig-ffmpeg-ffi

(state
  (metadata
    (version "0.1.0")
    (schema-version "1.0")
    (created "2025-01-03")
    (updated "2025-01-03")
    (project "zig-ffmpeg-ffi")
    (repo "hyperpolymath/zig-ffmpeg-ffi"))

  (project-context
    (name "zig-ffmpeg-ffi")
    (tagline "Zig FFI bindings for FFmpeg")
    (tech-stack "Zig" "FFmpeg" "libavformat" "libavcodec"))

  (current-position
    (phase "initial-implementation")
    (overall-completion 30)
    (components
      (core-bindings 80)
      (c-ffi-exports 70)
      (examples 50)
      (tests 20)
      (documentation 60)))

  (route-to-mvp
    (milestone "v0.1.0 - Core Functionality"
      (items
        ("Complete probe() function" done)
        ("Add C FFI exports" done)
        ("Write example" done)
        ("Add unit tests" pending)
        ("Test on real video files" pending))))

  (critical-next-actions
    (immediate
      ("Test with FFmpeg installed")
      ("Verify C FFI exports work"))))
