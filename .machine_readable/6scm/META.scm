;; SPDX-License-Identifier: PMPL-1.0-or-later
;; META.scm - Project metadata and architectural decisions

(define project-meta
  `((version . "1.0.0")
    (architecture-decisions
      ((adr-001
        (status . "accepted")
        (date . "2025-01-03")
        (context . "Need Zig bindings for ffmpeg")
        (decision . "Use Zig extern C declarations linking to native library")
        (consequences . "Direct FFI, no intermediate layers"))))
    (development-practices
      ((code-style . "zig-fmt")
       (security . "openssf-scorecard")
       (testing . "zig-test")
       (versioning . "semver")
       (documentation . "asciidoc")
       (branching . "trunk-based")))
    (design-rationale . ())))
