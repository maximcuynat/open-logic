#!/usr/bin/env bash
# Boots the main scene headless for a few frames. Godot exits 0 even on script
# errors, so the log is scanned for them.
source "$(dirname "$0")/lib.sh"
cd "$ROOT_DIR"

mkdir -p build
log="build/smoke.log"
"$GODOT" --headless --path . --quit-after 120 >"$log" 2>&1 || true
if grep -E "SCRIPT ERROR|Parse Error|Failed to load script" "$log"; then
  die "smoke test failed: script errors while booting the main scene (see $log)"
fi
info "smoke test passed"
