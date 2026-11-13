class_name WireGeometry
extends RefCounted
## World-space shapes used to render wires.


## Returns the filled rectangle of [param segment] drawn [param width] wide.
## [br]Each end extends by half the width ("square cap"), so two segments
## meeting at a corner form a sharp 90 degree angle with no notch or rounding.
static func segment_rect(segment: WireSegment, width: float) -> Rect2:
	var a := Grid.to_world(segment.a)
	var b := Grid.to_world(segment.b)
	var half := Vector2(width, width) / 2.0
	return Rect2(a - half, b - a + half * 2.0)
