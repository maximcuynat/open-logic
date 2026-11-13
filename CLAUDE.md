# open-logic - notes for Claude Code sessions

Godot 4.7 digital logic circuit editor. GPL-3.0. Everything in the repo
(code, comments, commits, docs) is written in **English**.

## Commands

- `make check` - lint + gdUnit4 tests + headless smoke test (the CI gate)
- `make test` / `scripts/test.sh -a res://tests/core/test_x.gd` - tests
- `make fmt` - format GDScript; `make run` - launch the app
- Godot binary: `/Applications/Godot.app/Contents/MacOS/Godot` (override with `GODOT=`)

## Rules

- `src/core/` is pure `RefCounted` GDScript: never reference `Node`, scenes or
  input there (ADR 0002). Every mutation goes through `CircuitCommands`.
- TDD for core: write the failing gdUnit4 test in `tests/core/` first.
- Keyboard shortcuts are declared only on menu items in `src/editor/main.gd`.
- Static typing everywhere; `gdformat`/`gdlint` must pass (line length 100).
- Conventional Commits (enforced by `.githooks/commit-msg`). No
  `Co-Authored-By` lines. Commit only when the maintainer asks.
- Day-to-day work happens on `develop`; `main` only receives releases
  (`make promote` then `make release`). Never commit directly on `main`.
- No GitHub Actions (ADR 0003). Releases via `make release`.

## Sandbox notes

- `user://`, `~/Library` and the window server are blocked in the Claude sandbox:
  headless Godot works, GUI runs and screenshots must be launched by the user.
- gdtoolkit needs a writable cache: run it with `HOME=$TMPDIR/home` in the sandbox.
- `git` needs `GIT_CONFIG_GLOBAL=/dev/null` in the sandbox; the maintainer
  commits, signs and pushes from his own shell.
