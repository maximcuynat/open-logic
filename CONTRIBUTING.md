# Contributing to open-logic

Thanks for your interest! The project is in early development and **external
pull requests are not accepted yet**. Bug reports, ideas and feedback are very
welcome through [issues](https://github.com/maximcuynat/open-logic/issues) and
[discussions](https://github.com/maximcuynat/open-logic/discussions).

The rest of this document describes the maintainer workflow, which will also
apply to contributors once the project opens up.

## Setup

```sh
make doctor   # verifies Godot 4.7, gdtoolkit, gitleaks, git-cliff, gh
make hooks    # installs .githooks (format, lint, secret scan, commit message)
```

## Workflow

1. Pick or open an issue; each issue belongs to a milestone of the
   [roadmap](docs/ROADMAP.md).
2. Work on `develop` (see [Branches](#branches)); for larger work, branch from
   it: `feat/<short-name>`, `fix/<short-name>`...
3. **Write a failing test first** for any change in `src/core/`.
4. Run `make check` (lint + tests + smoke test). There is no hosted CI: this
   command is the gate and must pass before pushing.
5. Open a pull request **against `develop`** using the template, then
   squash-merge (linear history).

## Branches

| Branch | Role |
|---|---|
| `develop` | Integration branch: all day-to-day work lands here |
| `main` | Released code only; every commit on it is (or leads to) a tagged release |
| `feat/*`, `fix/*` | Optional short-lived branches off `develop` |

`main` only moves forward by fast-forward from `develop` (`make promote`), then
`make release` adds the release commit and tag and fast-forwards `develop` back.

## Commit messages

[Conventional Commits](https://www.conventionalcommits.org/) are enforced by the
`commit-msg` hook and drive the changelog:

```
<type>(<scope>): <imperative description>

feat(editor): flip wire corner with Shift
fix(core): reject diagonal segments when loading files
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `style`,
`build`, `ci`, `revert`. Append `!` for breaking changes.

## Code style

- GDScript formatted with `gdformat` and linted with `gdlint` (`make fmt`, `make lint`).
- Static typing everywhere.
- `src/core/` must not depend on the scene tree (no `Node`), see
  [ADR 0002](docs/adr/0002-pure-core.md).
- Public methods get a `##` doc comment.

## Releases

Maintainers only: `make release BUMP=patch|minor|major` (use `DRY_RUN=1` first).
See [docs/RELEASING.md](docs/RELEASING.md).
