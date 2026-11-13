# Releasing

Releases are cut locally; there is no hosted CI.

## Prerequisites

- `make doctor` is green, including Godot export templates.
- You are on an up-to-date, clean `main`.
- `gh auth status` is logged in.

## Steps

```sh
make release BUMP=minor DRY_RUN=1   # rehearsal: checks, changelog preview, builds
make release BUMP=minor             # real release
make deploy-web                     # update the browser build on GitHub Pages
```

`scripts/release.sh` runs `make check`, bumps `application/config/version`
in `project.godot`, regenerates `CHANGELOG.md` with git-cliff, commits
`chore(release): vX.Y.Z`, creates an annotated tag (signed when
`user.signingkey` is configured), exports all platforms, writes `SHA256SUMS`,
pushes and publishes the GitHub release with the changelog as notes.

## Versioning

[Semantic Versioning](https://semver.org/). Pre-1.0: `minor` for a roadmap
milestone, `patch` for fixes. Patch releases for an older minor are cut from a
`release/vX.Y` branch.
