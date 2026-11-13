# ADR 0001: Build on Godot 4

- Status: accepted
- Date: 2026-11-13

## Context

open-logic needs a fast 2D canvas, a desktop-grade UI (menus, dialogs,
shortcuts), and distribution on macOS, Windows, Linux and the Web.

## Decision

Use Godot 4.7 with GDScript. The Godot editor itself is built with Godot's UI
system, which shows it is suited to tool development. Exports cover the four
target platforms from one codebase.

## Consequences

- Fast iteration, small binaries, Web build for free.
- GDScript is slow for heavy computation: mitigated by ADR 0002.
- Testing requires a third-party framework (gdUnit4, vendored in `addons/`).
