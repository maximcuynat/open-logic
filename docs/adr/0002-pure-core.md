# ADR 0002: Keep the model in a scene-free core

- Status: accepted
- Date: 2026-11-13

## Context

Simulating large circuits (millions of gates) will exceed what GDScript can do
in real time, and model code mixed with nodes is hard to test.

## Decision

Everything under `src/core/` is plain `RefCounted` GDScript with no dependency on
`Node`, scenes or input. The editor only renders the model and mutates it
through `CircuitCommands`.

## Consequences

- The core is unit-tested headless in milliseconds.
- The simulation engine can later be rewritten in C++ (GDExtension) behind the
  same interface without touching the editor.
