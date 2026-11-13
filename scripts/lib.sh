#!/usr/bin/env bash
# Shared helpers for open-logic scripts. Source it, do not execute it.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT:-$(command -v godot 2>/dev/null || echo /Applications/Godot.app/Contents/MacOS/Godot)}"
APP_NAME="open-logic"

info()  { printf '\033[36m==>\033[0m %s\n' "$*"; }
warn()  { printf '\033[33mwarning:\033[0m %s\n' "$*" >&2; }
die()   { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# Reads application/config/version from project.godot.
project_version() {
  sed -n 's/^config\/version="\(.*\)"$/\1/p' "$ROOT_DIR/project.godot"
}

# Godot version string as used by export template folders, e.g. 4.7.2.stable
godot_template_version() {
  "$GODOT" --version | sed -E 's/^([0-9]+\.[0-9]+(\.[0-9]+)?\.[a-z0-9]+).*/\1/'
}
