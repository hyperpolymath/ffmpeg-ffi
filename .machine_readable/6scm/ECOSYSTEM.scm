;; SPDX-License-Identifier: PMPL-1.0-or-later
;; ECOSYSTEM.scm - Project ecosystem positioning

(ecosystem
  ((version . "1.0.0")
   (name . "zig-ffmpeg-ffi")
   (type . "library")
   (purpose . "FFI bindings for FFmpeg multimedia library")
   (position-in-ecosystem . "infrastructure")
   (related-projects
     ((zig-nickel-ffi . "sibling-ffi")))
   (what-this-is . ("Zig FFI bindings"))
   (what-this-is-not . ("A reimplementation"))))
