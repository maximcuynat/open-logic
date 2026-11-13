class_name WireRouter
extends RefCounted
## Turns a drag gesture between two cells into orthogonal wire segments.


## Routes a wire from [param start] to [param end] as an L shape.
## [br]Returns no segment when both points are equal, one segment when they are
## aligned, otherwise two segments meeting at a corner. With
## [param horizontal_first] the horizontal leg starts at [param start].
static func route(
	start: Vector2i, end: Vector2i, horizontal_first: bool = true
) -> Array[WireSegment]:
	var segments: Array[WireSegment] = []
	if start == end:
		return segments
	if start.x == end.x or start.y == end.y:
		segments.append(WireSegment.create(start, end))
		return segments
	var corner := Vector2i(end.x, start.y) if horizontal_first else Vector2i(start.x, end.y)
	segments.append(WireSegment.create(start, corner))
	segments.append(WireSegment.create(corner, end))
	return segments
