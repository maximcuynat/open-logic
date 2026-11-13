# open-logic - Project handoff

> Snapshot written on **2026-11-13** to start a fresh Claude Code session.
> Read this file first, then `CLAUDE.md`, then `docs/specs/v0.2-components.md`.
> The repo is the source of truth: if something here disagrees with the code,
> trust the code and update this file.

---

## 1. What the project is

**open-logic** is an open-source **digital logic circuit designer** built with
**Godot 4.7**. The idea: a faster, keyboard-friendly alternative to Logisim, in
the spirit of the game *Gate Singular* and the course *Nand2Tetris*: start from
a single primitive, the **NAND gate**, and build everything up to a working CPU.

- Owner / maintainer: GitHub user **maximcuynat** (personal project, "Max").
- Repository: https://github.com/maximcuynat/open-logic (public, **GPL-3.0**)
- Local path: `~/Perso/git/open-logic` (personal projects follow the
  `open-<name>` naming convention under `~/Perso/git/`).
- Language rule: **everything in the repo is in English** (code, comments,
  commits, docs, issues). Conversations with Max are in **French**.
- Released: **v0.1.0** (grid and wires). Work in progress: **v0.2** (components).

---

## 2. Decisions already made (do not re-litigate)

| Topic | Decision | Where it is recorded |
|---|---|---|
| Engine | Godot 4.7.2 + GDScript, GL Compatibility renderer | ADR 0001 |
| Architecture | Model in a **pure core** (`RefCounted`, no `Node`), editor renders it | ADR 0002 |
| CI | **No GitHub Actions**. Local pipeline: Makefile + scripts + git hooks | ADR 0003 |
| License | GPL-3.0 (forks cannot be disabled on a public repo; GPL keeps derivatives open) | `LICENSE` |
| Tests | gdUnit4 v6.2.3 vendored in `addons/gdUnit4`, **TDD for core** | `CLAUDE.md` |
| Branches | Work on `develop`; `main` only receives releases (`make promote`) | `CONTRIBUTING.md` |
| Commits | Conventional Commits, enforced by hook. **No `Co-Authored-By`** | `CLAUDE.md` |
| Versioning | SemVer; pre-1.0: `minor` = roadmap milestone, `patch` = fixes/polish | `docs/RELEASING.md` |
| Visual style | **Deep dark** theme, grey grid, **sharp 90 degree corners everywhere**, no round shapes | `src/editor/palette.gd` |
| Canvas colours | **Opaque only** (overlapping translucent shapes darkened L corners) | test in `tests/editor/` |
| Window | Opens **maximized**; View > Toggle Fullscreen (`F11`) | `project.godot` |
| File format | `.olc`, versioned JSON, strict validation (reject whole file on error) | `docs/FILE_FORMAT.md` |
| v0.2 gates | **Labelled rectangles** ("NAND"); library is data-driven, more gates later | v0.2 spec |
| v0.2 moving | **Attached wires follow** moved/rotated components (L reroute) | v0.2 spec 1.4.1 |
| v0.2 palette | **Left palette panel** + shortcuts `V W 1 2 3` | v0.2 spec 2.1 |
| v0.2 junctions | **T junction connects, crossing does not**, square junction marker | v0.2 spec 1.5 |

---

## 3. Repository map

```
open-logic/
├─ project.godot              # app version = application/config/version (source of truth)
├─ src/
│  ├─ core/                   # PURE model, unit-tested, no Node/scene/input
│  │  ├─ grid.gd              # Grid: world px <-> cells (CELL_SIZE = 16)
│  │  ├─ wire_segment.gd      # WireSegment: immutable axis-aligned segment, normalized a<b
│  │  ├─ wire_router.gd       # WireRouter: drag -> 1 or 2 segments (L routing)
│  │  ├─ wire_geometry.gd     # WireGeometry: segment -> Rect2 with square caps (sharp corners)
│  │  ├─ circuit.gd           # Circuit: wire set, `changed` signal, hit testing
│  │  ├─ circuit_commands.gd  # CircuitCommands: all mutations via UndoRedo, dirty tracking
│  │  └─ circuit_serializer.gd# CircuitSerializer: JSON schema 1, strict parse -> LoadResult
│  └─ editor/
│     ├─ main.tscn / main.gd  # App shell: UI, menus + ALL shortcuts, files, autosave, guards
│     ├─ circuit_view.gd      # CircuitView (Node2D): draws grid/wires, selection, hover, tools
│     ├─ camera_controller.gd # Pan (middle/space+drag/trackpad), zoom around cursor
│     ├─ palette.gd           # Palette: the ONLY place colours are defined
│     ├─ grid_style.gd        # GridStyle: minor/major(every 8)/axis lines, zoom fade
│     ├─ app_theme.gd         # AppTheme: deep dark UI theme built from Palette
│     └─ tools/               # EditorTool base, WireTool, SelectTool
├─ tests/
│  ├─ core/                   # one gdUnit4 suite per core class
│  └─ editor/                 # pure editor helpers (GridStyle, Palette opacity)
├─ tools/screenshot.gd        # renders docs/images/screenshot.png (`make screenshot`)
├─ scripts/                   # local pipeline (see section 5)
├─ .githooks/                 # pre-commit (gdformat/gdlint/gitleaks), commit-msg (CC)
├─ docs/
│  ├─ ROADMAP.md              # milestones v0.1..v1.0; bullets == GitHub issue titles
│  ├─ ARCHITECTURE.md         # classes, data flow, rendering rules
│  ├─ FILE_FORMAT.md          # .olc schema 1 (schema 2 specified in v0.2 spec)
│  ├─ RELEASING.md            # promote + release + deploy-web
│  ├─ specs/v0.2-components.md# ACCEPTED spec for the next milestone
│  ├─ adr/0001..0003          # engine, pure core, local CI
│  └─ .gdignore               # keeps Godot from importing docs images
├─ .github/                   # issue forms, PR template, CODEOWNERS (@maximcuynat)
├─ export_presets.cfg         # macOS universal, Windows x86_64, Linux x86_64, Web (no threads)
├─ Makefile, cliff.toml, gdlintrc, .gitleaks.toml, .editorconfig, .gitattributes
├─ README.md, CHANGELOG.md, CONTRIBUTING.md, SECURITY.md, CODE_OF_CONDUCT.md, LICENSE
├─ CLAUDE.md                  # rules for Claude sessions (read automatically)
└─ tasks/                     # todo.md (progress), lessons.md (mistakes to avoid), handoff.md
```

Size: about 1,300 lines of GDScript in `src/`, **47 tests**, all green.

Data flow:

```
input -> CircuitView -> active EditorTool -> CircuitCommands -> Circuit
              ^                                                   |
              └──────────── changed signal (redraw) ──────────────┘
```

---

## 4. Current features (v0.1 + unreleased polish on `develop`)

- Infinite grid, pan and zoom (mouse, Space+drag, trackpad pinch and scroll).
- Wire tool (`W`): click-drag draws an L; first leg follows the drag
  direction, `Shift` flips the corner, `Esc`/right-click cancels, right-click
  on a wire deletes it.
- Select tool (`V`): click selects (orange), hover highlights (light blue),
  `Backspace`/`Delete` deletes.
- Undo/redo (`Cmd/Ctrl+Z`, `Cmd/Ctrl+Shift+Z`), dirty marker `*` in title.
- File menu: New, Open, Save, Save As (native dialogs), unsaved-changes guard,
  autosave to `user://autosave.olc` restored at launch.
- Help > About shows the version.
- Rendering (on `develop`, not yet released): wires are opaque filled
  rectangles with square caps; deep dark palette; grey grid with minor lines
  fading out when zoomed out; square cursor; no grey flash at boot.
- On macOS the menu bar is the native global menu.

---

## 5. Local pipeline (there is NO hosted CI)

| Command | What it does |
|---|---|
| `make doctor` | Checks Godot, gdtoolkit, gitleaks, git-cliff, gh, zip, export templates, hooks |
| `make hooks` | `git config core.hooksPath .githooks` |
| `make fmt` / `make lint` | gdformat / gdformat --check + gdlint (line length 100) |
| `make test` | gdUnit4 headless (`scripts/test.sh`, extra args passed through) |
| `make smoke` | Boots the main scene headless, fails on script errors (log: `build/smoke.log`) |
| `make check` | lint + test + smoke: **the gate before every push** |
| `make run` | Launches the app |
| `make screenshot` | Renders `docs/images/screenshot.png` (needs a GUI session) |
| `make export` | Exports 4 platforms + zips + `SHA256SUMS` in `build/release/` |
| `make promote` | Checks develop, fast-forwards `main` to `develop`, pushes main |
| `make release BUMP=patch\|minor\|major [DRY_RUN=1]` | From `main`: check, bump, git-cliff changelog, commit, tag, export, push, `gh release create`, then fast-forward `develop` back |
| `make deploy-web` | Pushes the Web build to `gh-pages` and enables GitHub Pages |

Git hooks: `pre-commit` runs gdformat --check, gdlint and `gitleaks git --staged`;
`commit-msg` enforces `<type>(<scope>)!: <description>` (max 72 chars).

Godot binary: `/Applications/Godot.app/Contents/MacOS/Godot` (also
`/opt/homebrew/bin/godot`, same 4.7.2). Export templates 4.7.2 are installed
(macOS, Windows x86_64, Linux x86_64, Web mono-thread).

---

## 6. GitHub setup (done via `scripts/github-setup.sh`, idempotent)

- Public repo, Discussions on, wiki off, squash-merge only, topics set.
- Security: vulnerability alerts, secret scanning + push protection, private
  vulnerability reporting, `SECURITY.md`.
- Rulesets: `protect-main` (no deletion, no force push, linear history),
  `protect-develop` (no deletion, no force push), `protect-release-tags`
  (`v*` cannot be deleted or moved).
- Labels: `type:*`, `area:*`, `priority:*`, `status:*`, `good first issue`
  (GitHub defaults removed). A stray `accessibility` label exists (not ours).
- Milestones v0.1 to v1.0 with one issue per roadmap bullet. **Issues are
  matched by exact title**: when a ROADMAP bullet is reworded, rename the issue
  (`gh issue edit <n> --title`) or a duplicate is created.
- v0.1 issues are closed. Open v0.2 issues: **#7** component model, **#8** NAND,
  **#9** switch and LED, **#11** connectivity, **#12** schema 2, **#30**
  place/move/rotate/delete (wires follow), **#31** palette panel. (#10 closed
  as duplicate of #30.) v0.3 includes **#32** built-in gate library.
- Project board: https://github.com/users/maximcuynat/projects/3 (Roadmap and
  Board views still to be created manually in the UI).
- Release **v0.1.0** published with 4 zips + `SHA256SUMS`.

---

## 7. Git state at handoff

- `develop` = `origin/develop` at `93e8085`, clean tree. Ahead of `main` by
  6 commits: deep dark theme, branch flow, v0.2 spec, github-setup fixes, roadmap.
- `main` = `origin/main` at `3121949` (v0.1.0 + sharp-corner rendering).
- Tag `v0.1.0` on `de9146b`. `project.godot` version: `0.1.0`.
- Commit identity used: `maximcuynat <93578199+maximcuynat@users.noreply.github.com>`,
  commits are not signed.

---

## 8. What is pending

Short, maintainer-side:
- [ ] `make screenshot` (current `docs/images/screenshot.png` shows the OLD v0.1
      render and an autosaved scribble), commit on `develop`.
- [ ] Optional **v0.1.1** release with the new rendering: `make promote` then
      `make release BUMP=patch`.
- [ ] `make deploy-web` (GitHub Pages not deployed yet; README links to it).
- [ ] Create Roadmap/Board views on the Project; verify `F11` on macOS
      (may be taken by the OS; fallback `Ctrl+Cmd+F`).
- [ ] Verify the single-key menu shortcuts `W`/`V` with the native macOS menu.

Main work: **implement v0.2** following `docs/specs/v0.2-components.md`,
in this order, tests first, one commit per step on `develop`:

1. `ComponentType`, `ComponentLibrary`, `Component` (rotation `(x,y)->(-y,x)`,
   pin cells, rotated body, occupied cells). Footprints: NAND body (-1,-2)..(1,2),
   pins A(-2,-1) B(-2,1) in, Y(2,0) out; SWITCH body (-1,-1)..(1,1), Y(2,0) out;
   LED body (-1,-1)..(1,1), A(-2,0) in.
2. Components in `Circuit` + placement rule (no body overlap, no pin in a body),
   monotonic ids.
3. `WireFollower.reattach(circuit, before, after) -> {remove, add}` (L reroute,
   last leg aligned with pin facing, both-ends translation, degenerate routes),
   then undoable `place/remove/move/rotate_component`, `toggle_switch`.
4. `NetlistBuilder` (union-find over wire endpoints + pin cells; one test per
   row of the connection table; conflict = more than one OUT pin; floating = none).
5. `CircuitSerializer` schema 2 (`components: [{id, type, at, rot, props}]`),
   schema 1 migration, strict validation.
6. Editor: left palette panel, placement tool with ghost (`R` rotates, red if
   invalid), select/move with live wire preview, rotate, delete, double-click
   toggles a switch.
7. Rendering: bodies (`COMPONENT_BODY`/`COMPONENT_BORDER` to add to Palette,
   opaque), pin stubs grey/blue by connection, square junction markers, opaque ghosts.
8. Docs: `FILE_FORMAT.md` schema 2, `ARCHITECTURE.md`, screenshot.

Then report to Max after the core (steps 1 to 5) before starting the editor.

---

## 9. Claude Code sandbox: constraints and workarounds

The Claude sandbox on Max's Mac blocks several things. Known workarounds:

| Blocked | Workaround |
|---|---|
| `~/.gitconfig`, keychain, `~/.config/gh` | Run git with `GIT_CONFIG_GLOBAL=/dev/null`; commit with `git -c user.name=maximcuynat -c user.email=93578199+maximcuynat@users.noreply.github.com commit ...`. **Push and all `gh` commands must be run by Max** (`! <cmd>` or his alias `gp`) |
| `~/Library` (Godot `user://`, editor settings, caches) | Headless Godot still works; the errors about `user://`, `editor_settings`, certificates are noise |
| Window server (GUI, screenshots) | Cannot run `make run`/`make screenshot`; Max does visual checks. For colour work, a pure-Python PNG mock renderer exists in `build/mock/render.py` (gitignored); write mocks under `build/` to be able to read them |
| `brew`/`pipx` installs | Ask Max. For local verification, gdtoolkit lives in a venv: `python3 -m venv $TMPDIR/venv && $TMPDIR/venv/bin/pip install "gdtoolkit==4.*"` |
| gdtoolkit cache in `~/Library/Caches` | Run with `HOME=$TMPDIR/home` |
| `mktemp` in some scripts | Use paths under `build/` instead |
| Reading outside the project | Put generated files under `build/` |

Typical verification command inside the sandbox:

```sh
cd /Users/mcuynat/Perso/git/open-logic && \
  export HOME=$TMPDIR/home PATH="$TMPDIR/venv/bin:$PATH" GIT_CONFIG_GLOBAL=/dev/null && \
  make check
```

---

## 10. Lessons learned (also in `tasks/lessons.md`)

- Never leave the shell in a subfolder: a command starting with `cd sub &&`
  moves the session, and Max's `!` commands then run there (`make release`
  printed "Nothing to be done"). Use `( cd sub && ... )` or absolute paths.
- gdUnit4: do not `preload` a script into a constant named like its
  `class_name` (shadows the global class); use the class name directly.
- macOS bash 3.2 + `set -u`: expand maybe-empty arrays as `${a[@]+"${a[@]}"}`.
- macOS `universal` export needs `rendering/textures/vram_compression/import_etc2_astc=true`.
- `.gdignore` in non-game folders; fail fast on missing export templates.
- Translucent canvas colours stack where shapes overlap: keep them opaque.
- `github-setup.sh` matches issues by title: rename issues with roadmap bullets.

---

## 11. Working agreement with Max

- Answer in **French**; no em dash in written French text.
- Plan before non-trivial work; write failing tests first for core; prove it
  works (`make check`) before saying done; be explicit about what could not be
  verified (GUI).
- Commit on `develop` when Max asks (he has asked for commits on `develop` in
  this phase); never commit on `main`; never add `Co-Authored-By`.
- Suggest a Conventional Commit message at the end of each task.
- After any correction from Max, add the pattern to `tasks/lessons.md`.

---

## 12. Suggested first prompt for the new session

> Lis `tasks/handoff.md`, `CLAUDE.md` et `docs/specs/v0.2-components.md`.
> Vérifie l'état (`git status`, `make check`), puis implémente la v0.2 dans
> l'ordre de la section 8, tests d'abord, un commit par étape sur `develop`.
> Fais-moi un point après le cœur (étapes 1 à 5).
