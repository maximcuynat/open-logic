# Releasing

Releases are cut locally; there is no hosted CI.

## Prerequisites

- `make doctor` is green, including Godot export templates.
- Your work is committed and pushed on `develop`.
- `gh auth status` is logged in.

## Steps

```sh
make promote                        # checks develop, fast-forwards main to it, pushes main
make release BUMP=minor DRY_RUN=1   # rehearsal: checks, changelog preview, builds
make release BUMP=minor             # real release (from main)
make deploy-web                     # update the browser build on GitHub Pages
```

`make promote` refuses to run if the tree is dirty, if a branch is behind its
remote, or if `main` has commits missing from `develop`. After a real release,
`develop` is fast-forwarded to `main` (it then contains the release commit and
the updated `CHANGELOG.md`) and you are switched back to `develop`.

`scripts/release.sh` runs `make check`, bumps `application/config/version`
in `project.godot`, regenerates `CHANGELOG.md` with git-cliff, commits
`chore(release): vX.Y.Z`, creates an annotated tag (signed when
`user.signingkey` is configured), exports all platforms, writes `SHA256SUMS`,
pushes and publishes the GitHub release with the changelog as notes.

## Versioning

[Semantic Versioning](https://semver.org/). Pre-1.0: `minor` for a roadmap
milestone, `patch` for fixes. Patch releases for an older minor are cut from a
`release/vX.Y` branch.
