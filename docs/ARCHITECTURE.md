# Architecture

```
src/
├─ core/     Pure model. RefCounted classes, no scene tree. Unit-tested.
└─ editor/   Godot scenes/nodes: rendering, input, menus, files.
tests/core/  gdUnit4 suites, one per core class.
tools/       Developer utilities (screenshot renderer).
scripts/     Local pipeline (doctor, test, smoke, export, release, deploy).
```

## Core (`src/core/`)

| Class | Responsibility |
|---|---|
| `Grid` | World (pixels) to grid (cells) conversions |
| `WireSegment` | Immutable axis-aligned segment, normalised endpoints, distance queries |
| `WireRouter` | Turns a drag gesture into one or two orthogonal segments (L routing) |
| `Circuit` | The document: set of wires, `changed` signal, hit testing |
| `CircuitCommands` | Every mutation as an undoable action (`UndoRedo`), dirty tracking |
| `CircuitSerializer` | Versioned JSON read/write with strict validation |

Rule: **core never references `Node`, scenes or input**. This keeps it testable
headless and makes a later native port (GDExtension) possible, see
[ADR 0002](adr/0002-pure-core.md).

## Editor (`src/editor/`)

| File | Responsibility |
|---|---|
| `main.gd` | Application shell: builds UI, menus and shortcuts, documents, autosave |
| `circuit_view.gd` | Draws grid and circuit, owns selection, routes input to the active tool |
| `camera_controller.gd` | Pan and zoom around the cursor |
| `tools/*.gd` | `EditorTool` subclasses: `WireTool`, `SelectTool` |

Data flow:

```
input ──> CircuitView ──> active EditorTool ──> CircuitCommands ──> Circuit
                ^                                                     │
                └────────────── changed signal (redraw) ──────────────┘
```

All keyboard shortcuts are declared once, on the menu items in `main.gd`.
On macOS the menu bar is the native global menu.
