;; SPDX-License-Identifier: PMPL-1.0-or-later
;; ECOSYSTEM.scm - Project ecosystem positioning for ffmpeg-ffi

(ecosystem
  ((version . "1.0.0")
   (name . "ffmpeg-ffi")
   (type . "library")
   (purpose . "Zig FFI bindings for FFmpeg multimedia libraries with Idris2 ABI proofs")
   (position-in-ecosystem . "infrastructure")
   (related-projects
     ((proven-servers . "sibling-ffi-pattern")
      (developer-ecosystem . "parent-ecosystem")))
   (what-this-is . ("Zig FFI bindings for FFmpeg"
                     "Idris2 ABI definitions with dependent type proofs"
                     "Rust shim for opaque struct field access"
                     "C-compatible FFI exports for multi-language consumption"))
   (what-this-is-not . ("A reimplementation of FFmpeg"
                         "A media processing framework"
                         "A command-line tool"))))
