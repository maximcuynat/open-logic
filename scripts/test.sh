#!/usr/bin/env bash
# Runs the gdUnit4 suite headless. Extra arguments are passed to GdUnitCmdTool
# (e.g. scripts/test.sh -a res://tests/core/test_circuit.gd).
source "$(dirname "$0")/lib.sh"
cd "$ROOT_DIR"

args=("$@")
[[ ${#args[@]} -eq 0 ]] && args=(-a res://tests)

# --remote-debug to an unbound port prevents Godot's interactive debugger from
# hanging on script errors (see addons/gdUnit4/runtest.sh).
set +e
"$GODOT" --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 \
  res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode "${args[@]}"
status=$?
set -e
"$GODOT" --headless --path . --quiet -s res://addons/gdUnit4/bin/GdUnitCopyLog.gd >/dev/null 2>&1 || true
exit $status
