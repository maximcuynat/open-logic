#!/usr/bin/env bash
# Verifies the local toolchain. Exit code is non-zero if a required tool is missing.
source "$(dirname "$0")/lib.sh"

missing=0
check() { # name, command, required(1/0), install hint
  if command -v "$2" >/dev/null 2>&1; then
    printf '  \033[32mok\033[0m       %-12s %s\n' "$1" "$(command -v "$2")"
  elif [[ "$3" == 1 ]]; then
    printf '  \033[31mmissing\033[0m  %-12s -> %s\n' "$1" "$4"; missing=1
  else
    printf '  \033[33moptional\033[0m %-12s -> %s\n' "$1" "$4"
  fi
}

info "Toolchain"
if [[ -x "$GODOT" ]]; then
  printf '  \033[32mok\033[0m       %-12s %s (%s)\n' godot "$GODOT" "$("$GODOT" --version)"
else
  printf '  \033[31mmissing\033[0m  %-12s -> https://godotengine.org/download\n' godot; missing=1
fi
check gdformat  gdformat  1 "pipx install 'gdtoolkit==4.*'"
check gdlint    gdlint    1 "pipx install 'gdtoolkit==4.*'"
check gitleaks  gitleaks  1 "brew install gitleaks"
check git-cliff git-cliff 1 "brew install git-cliff"
check gh        gh        1 "brew install gh && gh auth login"
check zip       zip       1 "should ship with macOS"

info "Export templates"
if [[ -x "$GODOT" ]]; then
  tdir="$(export_templates_dir)"
  if [[ -d "$tdir" ]]; then
    printf '  \033[32mok\033[0m       %s\n' "$tdir"
  else
    printf '  \033[33mmissing\033[0m  %s\n' "$tdir"
    printf '           -> Godot editor: Editor > Manage Export Templates > Download and Install\n'
    printf '              (only needed for `make export` / `make release`)\n'
  fi
fi

info "Git hooks"
if [[ "$(git -C "$ROOT_DIR" config core.hooksPath || true)" == ".githooks" ]]; then
  printf '  \033[32mok\033[0m       core.hooksPath=.githooks\n'
else
  printf '  \033[33mmissing\033[0m  run `make hooks`\n'
fi

exit $missing
