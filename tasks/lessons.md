# Lessons

- gdUnit4 tests: do not `preload` a script into a constant that has the same
  name as its `class_name` (it shadows the global class). Use the class name directly.
- macOS ships bash 3.2: with `set -u`, expand possibly-empty arrays as
  `${arr[@]+"${arr[@]}"}`.
