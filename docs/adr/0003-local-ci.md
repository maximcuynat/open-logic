# ADR 0003: Local CI instead of GitHub Actions

- Status: accepted
- Date: 2026-11-13

## Context

The maintainer wants the pipeline to run without GitHub Actions.

## Decision

The pipeline is a `Makefile` plus scripts and git hooks:
`make check` (lint, tests, smoke test) is the gate before every push, and
`make release` produces and publishes releases from the maintainer's machine.

## Consequences

- No hosted runner, no secrets stored on GitHub, fully reproducible locally.
- Discipline is required: nothing blocks a push that skipped `make check`.
  Mitigated by the pre-commit hook and the release script, which refuses to
  release if `make check` fails.
- Can be mirrored to a hosted CI later by calling the same `make` targets.
