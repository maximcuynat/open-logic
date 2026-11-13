#!/usr/bin/env bash
# Promotes develop to main (fast-forward only) before a release.
# Leaves you on main, ready for `make release`. Usage: scripts/promote.sh
source "$(dirname "$0")/lib.sh"
cd "$ROOT_DIR"

[[ -z "$(git status --porcelain)" ]] || die "working tree is not clean"
info "Fetching origin"
git fetch -q origin
for branch in develop main; do
  if [[ "$(git rev-parse "$branch")" != "$(git rev-parse "origin/$branch")" ]]; then
    git merge-base --is-ancestor "origin/$branch" "$branch" \
      || die "$branch is behind origin/$branch: pull it first"
  fi
done

info "Running the local CI gate on develop"
git checkout -q develop
make --no-print-directory check

info "Fast-forwarding main to develop"
git checkout -q main
git merge --ff-only develop || die "main has commits that are not on develop: merge main into develop first"
git push origin main
info "main is now at $(git rev-parse --short HEAD). Next: make release BUMP=patch|minor|major"
