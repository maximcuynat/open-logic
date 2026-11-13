# Lessons

- gdUnit4 tests: do not `preload` a script into a constant that has the same
  name as its `class_name` (it shadows the global class). Use the class name directly.
- macOS ships bash 3.2: with `set -u`, expand possibly-empty arrays as
  `${arr[@]+"${arr[@]}"}`.
- Godot macOS `universal` (or x86_64) export requires
  `rendering/textures/vram_compression/import_etc2_astc=true` in project.godot.
- Put a `.gdignore` in non-game folders (`docs/`) so Godot does not import their images.
- Fail fast on missing export templates instead of letting Godot print a cryptic list.
