# Roadmap

Each version is a GitHub milestone; each bullet is an issue. Progress is tracked
on the [project board](https://github.com/users/maximcuynat/projects).

## v0.1 - Grid & wires *(current)*
- Infinite grid with pan and zoom (mouse + trackpad)
- Orthogonal wire drawing with L routing
- Wire selection and deletion
- Undo / redo
- Save / open `.olc` files, autosave
- Local CI pipeline, release tooling, GitHub setup

## v0.2 - Components
- Component model (position, rotation, pins) in the core
- NAND gate primitive
- Input switch and output LED
- Place, move, rotate and delete components (attached wires follow)
- Component palette panel
- Connectivity: compute nets from wires and pins (split wires at T-junctions)
- File format schema 2 with migration from schema 1

## v0.3 - Simulation
- Event-driven net propagation
- Step / run / pause controls
- Clock built by the user, plus an optional clock source component
- Wire colouring by signal state
- Built-in gate library: NOT, AND, OR, NOR, XOR, XNOR, buffer (labelled rectangles)

## v0.4 - Subcircuits
- Turn a selection into a reusable block with named pins
- Block library panel; editing a block updates every instance
- Built-in challenge pack: NOT, AND, OR, XOR from NAND

## v0.5 - Productivity
- Multi-selection, box selection, move
- Copy / paste between documents
- ROM component with a hex editor
- Buses (multi-bit wires)

## v0.6 - Web & performance
- Public Web build on GitHub Pages
- Profiling on large circuits (100k+ gates)
- Native simulation core (C++ GDExtension) if profiling requires it

## v1.0 - Stable
- Frozen file format (schema compatibility guarantee)
- User documentation
- Guided challenge mode from NAND to a working CPU
