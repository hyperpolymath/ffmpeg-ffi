;; SPDX-License-Identifier: PMPL-1.0-or-later
;; STATE.scm - Project state for ffmpeg-ffi

(state
  (metadata
    (version "0.1.0")
    (schema-version "1.0")
    (created "2025-01-03")
    (updated "2026-03-02")
    (project "ffmpeg-ffi")
    (repo "hyperpolymath/ffmpeg-ffi"))

  (project-context
    (name "ffmpeg-ffi")
    (tagline "Zig FFI bindings for FFmpeg with Idris2 ABI proofs")
    (tech-stack "Zig" "Idris2" "Rust" "FFmpeg" "libavformat" "libavcodec" "libavutil"))

  (current-position
    (phase "initial-implementation")
    (overall-completion 50)
    (components
      (core-zig-bindings 90)
      (c-ffi-exports 80)
      (rust-shim 90)
      (idris2-abi-definitions 70)
      (ffi-zig-template 60)
      (examples 70)
      (tests 30)
      (documentation 60)))

  (route-to-mvp
    (milestone "v0.1.0 - Core Functionality"
      (items
        ("Complete probe() function" done)
        ("Add C FFI exports" done)
        ("Write example" done)
        ("Rust shim for opaque structs" done)
        ("Idris2 ABI type definitions" done)
        ("RSR compliance audit" done)
        ("Add unit tests" pending)
        ("Test on real video files" pending)
        ("Generate C headers from Idris2" pending)
        ("Connect Idris2 ABI to Zig FFI" pending))))

  (critical-next-actions
    (immediate
      ("Test with FFmpeg installed on Fedora")
      ("Verify C FFI exports work from external consumers")
      ("Resolve Idris2 proof holes in Layout.idr"))))

;; Updated: 2026-03-02
;; RSR compliance audit complete: SPDX headers, LICENSE, template placeholders fixed
;; Idris2 ABI definitions present but contain template/example code needing specialisation
