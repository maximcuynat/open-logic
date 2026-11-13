#!/usr/bin/env bash
# One-time (idempotent) GitHub configuration for open-logic. Requires `gh` logged
# in with the `repo` and `project` scopes:  gh auth refresh -s project
#
# Usage: scripts/github-setup.sh [--signed-commits] [--limit-interactions]
#   --signed-commits      require signed commits on main (configure signing first)
#   --limit-interactions  restrict issues/PRs/comments to collaborators for 6 months
source "$(dirname "$0")/lib.sh"
cd "$ROOT_DIR"

OWNER="maximcuynat"
REPO="open-logic"
R="$OWNER/$REPO"
SIGNED=0; LIMIT=0
for arg in "$@"; do
  case "$arg" in
    --signed-commits) SIGNED=1 ;;
    --limit-interactions) LIMIT=1 ;;
    *) die "unknown option $arg" ;;
  esac
done

command -v gh >/dev/null || die "gh is required"
gh auth status >/dev/null 2>&1 || die "run: gh auth login"
[[ -n "$(git log -1 --format=%H 2>/dev/null)" ]] || die "make a first commit before running this script"

# --- Repository ------------------------------------------------------------------
if gh repo view "$R" >/dev/null 2>&1; then
  info "Repository $R exists"
else
  info "Creating public repository $R"
  gh repo create "$R" --public --source . --remote origin --push \
    --description "Open-source digital logic circuit designer: from a NAND gate to a CPU." \
    --homepage "https://$OWNER.github.io/$REPO/"
fi

info "Repository settings"
gh repo edit "$R" \
  --enable-issues --enable-discussions --enable-projects --enable-wiki=false \
  --enable-squash-merge --enable-merge-commit=false --enable-rebase-merge=false \
  --delete-branch-on-merge --allow-update-branch \
  --add-topic godot --add-topic godot4 --add-topic gdscript --add-topic logic-simulator \
  --add-topic digital-logic --add-topic circuit-simulator --add-topic education --add-topic nand

# --- Security ----------------------------------------------------------------------
info "Security features"
gh api -X PUT "repos/$R/vulnerability-alerts" --silent
gh api -X PUT "repos/$R/private-vulnerability-reporting" --silent
gh api -X PATCH "repos/$R" --silent --input - <<'JSON'
{"security_and_analysis": {
  "secret_scanning": {"status": "enabled"},
  "secret_scanning_push_protection": {"status": "enabled"}
}}
JSON
if [[ "$LIMIT" == 1 ]]; then
  info "Limiting interactions to collaborators (6 months)"
  gh api -X PUT "repos/$R/interaction-limits" -f limit=collaborators_only -f expiry=six_months --silent
fi

# --- Rulesets ------------------------------------------------------------------------
upsert_ruleset() { # name, json
  local id
  id=$(gh api "repos/$R/rulesets" --jq ".[] | select(.name==\"$1\") | .id")
  if [[ -n "$id" ]]; then
    gh api -X PUT "repos/$R/rulesets/$id" --input - --silent <<<"$2"
  else
    gh api -X POST "repos/$R/rulesets" --input - --silent <<<"$2"
  fi
  info "Ruleset '$1' applied"
}

main_rules='{"type":"deletion"},{"type":"non_fast_forward"},{"type":"required_linear_history"}'
[[ "$SIGNED" == 1 ]] && main_rules="$main_rules,{\"type\":\"required_signatures\"}"
upsert_ruleset "protect-main" "{
  \"name\": \"protect-main\", \"target\": \"branch\", \"enforcement\": \"active\",
  \"conditions\": {\"ref_name\": {\"include\": [\"~DEFAULT_BRANCH\"], \"exclude\": []}},
  \"rules\": [$main_rules]
}"
upsert_ruleset "protect-develop" '{
  "name": "protect-develop", "target": "branch", "enforcement": "active",
  "conditions": {"ref_name": {"include": ["refs/heads/develop"], "exclude": []}},
  "rules": [{"type": "deletion"}, {"type": "non_fast_forward"}]
}'
upsert_ruleset "protect-release-tags" '{
  "name": "protect-release-tags", "target": "tag", "enforcement": "active",
  "conditions": {"ref_name": {"include": ["refs/tags/v*"], "exclude": []}},
  "rules": [{"type": "deletion"}, {"type": "update"}, {"type": "non_fast_forward"}]
}'

# --- Labels ----------------------------------------------------------------------------
info "Labels"
# GitHub occasionally answers 5xx on label updates: retry, then warn and go on.
label() {
  local attempt
  for attempt in 1 2 3; do
    gh label create "$1" --repo "$R" --color "$2" --description "$3" --force >/dev/null 2>&1 && return 0
    sleep $((attempt * 2))
  done
  warn "could not create/update label '$1' (re-run the script later)"
}
label "type:bug"        d73a4a "Something is broken"
label "type:feature"    a2eeef "New functionality"
label "type:docs"       0075ca "Documentation"
label "type:chore"      cfd3d7 "Tooling, maintenance"
label "type:perf"       fbca04 "Performance"
label "area:core"       5319e7 "src/core model"
label "area:editor"     1d76db "src/editor UI and input"
label "area:sim"        b60205 "Simulation engine"
label "area:pipeline"   006b75 "Build, release, tooling"
label "priority:high"   b60205 "Do next"
label "priority:low"    c2e0c6 "Nice to have"
label "status:triage"   ededed "Needs triage"
label "good first issue" 7057ff "Good for newcomers"
label "status:duplicate" cfd3d7 "Already reported"
label "status:wontfix"   ffffff "Will not be worked on"
label "status:question"  d876e3 "More information needed"

# GitHub's default labels duplicate the scheme above.
for default in bug documentation duplicate enhancement "help wanted" invalid question wontfix; do
  gh label delete "$default" --repo "$R" --yes >/dev/null 2>&1 && info "  removed default label '$default'" || true
done

# --- Milestones and issues from docs/ROADMAP.md ------------------------------------------
info "Milestones and roadmap issues"
current_milestone=""
milestone_id() { gh api "repos/$R/milestones?state=all&per_page=100" --jq ".[] | select(.title==\"$1\") | .number"; }
existing_titles=$(gh issue list --repo "$R" --state all --limit 500 --json title --jq '.[].title')
issue_urls=()

while IFS= read -r line; do
  if [[ "$line" =~ ^##\ (v[0-9]+\.[0-9]+)\ -\ (.*)$ ]]; then
    current_milestone="${BASH_REMATCH[1]}"
    title="${BASH_REMATCH[2]% \**}"
    if [[ -z "$(milestone_id "$current_milestone")" ]]; then
      gh api "repos/$R/milestones" -f title="$current_milestone" -f description="$title" --silent
    fi
    info "  $current_milestone - $title"
  elif [[ "$line" =~ ^-\ (.+)$ && -n "$current_milestone" ]]; then
    item="${BASH_REMATCH[1]}"
    grep -Fxq "$item" <<<"$existing_titles" && continue
    url=$(gh issue create --repo "$R" --title "$item" --milestone "$current_milestone" \
      --label "type:feature" --body "Roadmap item for **$current_milestone**. See [ROADMAP](docs/ROADMAP.md).")
    issue_urls+=("$url")
    # v0.1 items are delivered by this first version.
    [[ "$current_milestone" == "v0.1" ]] && gh issue close "$url" --reason completed --comment "Delivered in v0.1.0." >/dev/null
  fi
done < docs/ROADMAP.md

# --- Project board ----------------------------------------------------------------------
info "Project board"
project=$(gh project list --owner "$OWNER" --format json --jq ".projects[] | select(.title==\"open-logic roadmap\") | .number")
if [[ -z "$project" ]]; then
  project=$(gh project create --owner "$OWNER" --title "open-logic roadmap" --format json --jq .number)
  gh project link "$project" --owner "$OWNER" --repo "$R" >/dev/null
fi
for url in ${issue_urls[@]+"${issue_urls[@]}"}; do
  gh project item-add "$project" --owner "$OWNER" --url "$url" >/dev/null
done

info "Done: https://github.com/$R"
cat <<NEXT

Manual steps (not available in the API):
  - Project https://github.com/users/$OWNER/projects/$project : add a "Roadmap" view
    (Layout: Roadmap, group by Milestone) and a "Board" view (group by Status).
  - Pin the repository on your profile.
Then: make release BUMP=minor && make deploy-web
NEXT
