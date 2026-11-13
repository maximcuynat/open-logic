#!/usr/bin/env bash
# Publishes build/export/web to the gh-pages branch (served by GitHub Pages).
# The Web preset is single-threaded so it runs without COOP/COEP headers.
source "$(dirname "$0")/lib.sh"
cd "$ROOT_DIR"

web="build/export/web"
[[ -f "$web/index.html" ]] || scripts/export.sh
remote="$(git remote get-url origin)" || die "no origin remote"

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
cp -R "$web/." "$tmp/"
touch "$tmp/.nojekyll"
(
  cd "$tmp"
  git init -q -b gh-pages
  git add -A
  git commit -q -m "chore(web): deploy $(project_version)"
  git push -q -f "$remote" gh-pages
)
info "Deployed to gh-pages"

# Enable GitHub Pages on first deploy.
repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
if ! gh api "repos/$repo/pages" >/dev/null 2>&1; then
  gh api -X POST "repos/$repo/pages" -f "source[branch]=gh-pages" -f "source[path]=/" --silent
  info "GitHub Pages enabled"
fi
info "Live soon at https://$(cut -d/ -f1 <<<"$repo").github.io/$(cut -d/ -f2 <<<"$repo")/"
