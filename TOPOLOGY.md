<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->
<!-- TOPOLOGY.md — Project architecture map and completion dashboard -->
<!-- Last updated: 2026-02-19 -->

# ffmpeg-ffi — Project Topology

## System Architecture

```
                        ┌─────────────────────────────────────────┐
                        │              FFI CONSUMERS              │
                        │        (Rust, Elixir, ReScript, etc.)   │
                        └───────────────────┬─────────────────────┘
                                            │ C ABI Bridge
                                            ▼
                        ┌─────────────────────────────────────────┐
                        │           ZIG FFI WRAPPER               │
                        │  ┌───────────┐  ┌───────────────────┐  │
                        │  │  src/     │  │  src/abi          │  │
                        │  │  main.zig │  │  (Idris2 Proofs)  │  │
                        │  └─────┬─────┘  └────────┬──────────┘  │
                        └────────│─────────────────│──────────────┘
                                 │                 │
                                 ▼                 ▼
                        ┌─────────────────────────────────────────┐
                        │           SYSTEM FFmpeg LIBS            │
                        │  ┌───────────┐  ┌───────────┐  ┌───────┐│
                        │  │ avformat  │  │ avcodec   │  │ avutil││
                        │  └───────────┘  └───────────┘  └───────┘│
                        │  ┌───────────┐  ┌───────────┐  ┌───────┐│
                        │  │ swresample│  │ swscale   │  │ libc  ││
                        │  └───────────┘  └───────────┘  └───────┘│
                        └─────────────────────────────────────────┘

                        ┌─────────────────────────────────────────┐
                        │          REPO INFRASTRUCTURE            │
                        │  build.zig          .machine_readable/  │
                        │  .bot_directives/   ABI-FFI Standards   │
                        └─────────────────────────────────────────┘
```

## Completion Dashboard

```
COMPONENT                          STATUS              NOTES
─────────────────────────────────  ──────────────────  ─────────────────────────────────
CORE WRAPPER (ZIG)
  avformat bindings                 ██████████ 100%    Container formats stable
  avcodec bindings                  ██████████ 100%    Codec handling verified
  avutil / swscale                  ████████░░  80%    Scaling logic refining
  Memory Safety Bridge              ██████████ 100%    Zig safety verified

ABI & PROOFS
  Idris2 ABI Definitions            ██████████ 100%    Type-level layout verified
  C Header Generation               ██████████ 100%    Auto-generated from Idris2
  Wait-free Primitives              ████████░░  80%    IPC refining

REPO INFRASTRUCTURE
  build.zig                         ██████████ 100%    Static/Shared targets stable
  .machine_readable/                ██████████ 100%    STATE tracking active
  Examples (probe.zig)              ██████████ 100%    Basic metadata probing verified

─────────────────────────────────────────────────────────────────────────────
OVERALL:                            █████████░  ~90%   FFmpeg bridge production-ready
```

## Key Dependencies

```
Idris2 ABI ──────► Zig FFI Wrapper ──────► FFmpeg Shared Libs
     │                 │                      │
     ▼                 ▼                      ▼
Generated Header ──► Static/Shared ────────► Binary Distribution
```

## Update Protocol

This file is maintained by both humans and AI agents. When updating:

1. **After completing a component**: Change its bar and percentage
2. **After adding a component**: Add a new row in the appropriate section
3. **After architectural changes**: Update the ASCII diagram
4. **Date**: Update the `Last updated` comment at the top of this file

Progress bars use: `█` (filled) and `░` (empty), 10 characters wide.
Percentages: 0%, 10%, 20%, ... 100% (in 10% increments).
