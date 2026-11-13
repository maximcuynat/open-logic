class_name Grid
extends RefCounted
## Conversions between world space (pixels) and grid space (cells).
##
## Cell coordinates are integers; one cell is [constant CELL_SIZE] world units wide.

const CELL_SIZE: float = 16.0


## Returns the grid cell closest to [param world].
static func snap(world: Vector2) -> Vector2i:
	return Vector2i(roundi(world.x / CELL_SIZE), roundi(world.y / CELL_SIZE))


## Returns the world position of [param cell].
static func to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell) * CELL_SIZE


## Returns [param world] expressed in (fractional) cell units.
static func to_cell_space(world: Vector2) -> Vector2:
	return world / CELL_SIZE
