# v0.1 - Grid & wires

## 1. Scaffolding
- [x] git repo, layout, GPL-3.0 and Contributor Covenant 2.1 (official texts)
- [x] project.godot (Godot 4.7, GL Compatibility), .gitignore, .gitattributes, .editorconfig
- [x] gdUnit4 v6.2.3 vendored (requires Godot >= 4.5)
- [x] Makefile, scripts (doctor, test, smoke, export, release, deploy-web, github-setup)
- [x] Git hooks: gdformat/gdlint + gitleaks (pre-commit), Conventional Commits (commit-msg)
- [x] Docs: README, CONTRIBUTING, SECURITY, ROADMAP, ARCHITECTURE, FILE_FORMAT, RELEASING, ADR 0001-0003
- [x] GitHub templates: issue forms, PR template, CODEOWNERS
- [ ] Maintainer: install git-cliff and gdtoolkit (blocked by the Claude sandbox)

## 2. Core (TDD)
- [x] Grid, WireSegment, WireRouter, Circuit, CircuitSerializer: tests first (red), then green
- [x] CircuitCommands (undo/redo, dirty tracking): tests first (red), then green

## 3. Editor
- [x] Camera (wheel/pinch zoom around cursor, middle/space/two-finger pan)
- [x] Wire tool (L routing, Shift flips, right-click deletes), select tool
- [x] Menus with shortcuts (native global menu on macOS), status bar, window title with dirty marker
- [x] New / Open / Save / Save As, autosave, unsaved-changes confirmation
- [ ] Maintainer: manual checklist below

## 4. Release pipeline
- [x] export_presets.cfg (macOS universal, Windows, Linux, Web single-threaded)
- [ ] Maintainer: install export templates 4.7.2, then `make release BUMP=minor DRY_RUN=1`

## 5. GitHub
- [ ] Maintainer: first commit, `scripts/github-setup.sh`, `make release BUMP=minor`, `make deploy-web`

## Manual checklist (`make run`)
- [ ] Drag draws an L-shaped wire; Shift flips the corner; Esc cancels
- [ ] Wheel and pinch zoom around the cursor; middle drag / Space+drag / two-finger scroll pan
- [ ] `V` then click selects (orange); Backspace deletes; right-click deletes
- [ ] Cmd+Z / Cmd+Shift+Z undo and redo; title shows `*` when dirty
- [ ] Save, New, Open restores the circuit; quit with changes asks for confirmation
- [ ] Relaunch restores the autosaved circuit
- [ ] Single-key shortcuts `W` / `V` work with the native macOS menu (to verify)

## Review
- `make check` green in the sandbox: gdformat + gdlint clean, 38/38 tests, smoke test passes.
- Verified negative paths: smoke test fails on an injected parse error; commit-msg
  rejects malformed messages; pre-commit blocks a planted AWS/GitHub token.
- Not verifiable in the sandbox: GUI interaction, screenshot, exports (no templates
  or no access to them), anything touching GitHub.
