#!/usr/bin/env bash
# Cuts a release from main: checks, version bump, changelog, signed tag,
# exports, GitHub release. Usage: BUMP=patch|minor|major [DRY_RUN=1] scripts/release.sh
source "$(dirname "$0")/lib.sh"
cd "$ROOT_DIR"

BUMP="${BUMP:-patch}"
DRY_RUN="${DRY_RUN:-0}"
run() { if [[ "$DRY_RUN" == 1 ]]; then printf '  [dry-run] %s\n' "$*"; else "$@"; fi; }

# --- Preconditions ------------------------------------------------------------
[[ "$(git branch --show-current)" == main ]] || die "releases are cut from main"
[[ -z "$(git status --porcelain)" ]] || die "working tree is not clean"
for tool in git-cliff gh zip; do command -v "$tool" >/dev/null || die "$tool is required (make doctor)"; done

current="$(project_version)"
IFS=. read -r major minor patch <<<"$current"
case "$BUMP" in
  major) next="$((major + 1)).0.0" ;;
  minor) next="$major.$((minor + 1)).0" ;;
  patch) next="$major.$minor.$((patch + 1))" ;;
  *) die "BUMP must be patch, minor or major" ;;
esac
tag="v$next"
git rev-parse -q --verify "refs/tags/$tag" >/dev/null && die "tag $tag already exists"
info "Releasing $current -> $next (dry-run: $DRY_RUN)"

# --- Gate -----------------------------------------------------------------------
info "Running the local CI gate"
make --no-print-directory check

# --- Version, changelog, tag ----------------------------------------------------
info "Bumping version and changelog"
if [[ "$DRY_RUN" == 1 ]]; then
  git-cliff --unreleased --tag "$tag" | head -40
else
  sed -i.bak "s/^config\/version=\".*\"$/config\/version=\"$next\"/" project.godot && rm project.godot.bak
  git-cliff --tag "$tag" -o CHANGELOG.md
  git add project.godot CHANGELOG.md
  git commit -m "chore(release): $tag"
  sign=()
  git config --get user.signingkey >/dev/null && sign=(-s)
  git tag ${sign[@]+"${sign[@]}"} -a "$tag" -m "open-logic $tag"
fi

# --- Build ------------------------------------------------------------------------
scripts/export.sh "$next"

# --- Publish ----------------------------------------------------------------------
notes="$(mktemp)"; trap 'rm -f "$notes"' EXIT
git-cliff --latest --strip header > "$notes" 2>/dev/null || git-cliff --unreleased --tag "$tag" --strip header > "$notes"
run git push origin main "$tag"
run gh release create "$tag" build/release/*.zip build/release/SHA256SUMS \
  --title "open-logic $tag" --notes-file "$notes" --verify-tag

info "Done. Publish the playable Web build with: make deploy-web"
