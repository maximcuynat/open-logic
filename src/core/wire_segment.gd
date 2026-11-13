class_name WireSegment
extends RefCounted
## An axis-aligned wire segment between two grid cells.
##
## Instances are immutable value objects: endpoints are normalised so that
## [member a] is always the smaller endpoint, which makes equality independent
## of the drawing direction. Build them with [method create].

var a: Vector2i:
	get:
		return _a

var b: Vector2i:
	get:
		return _b

var _a: Vector2i
var _b: Vector2i


func _init(p: Vector2i, q: Vector2i) -> void:
	if q.x < p.x or q.y < p.y:
		_a = q
		_b = p
	else:
		_a = p
		_b = q


## Returns a new segment from [param p] to [param q], or [code]null[/code] when
## the segment would be empty or diagonal.
static func create(p: Vector2i, q: Vector2i) -> WireSegment:
	if p == q or (p.x != q.x and p.y != q.y):
		return null
	return WireSegment.new(p, q)


func is_horizontal() -> bool:
	return _a.y == _b.y


func length() -> int:
	return (_b.x - _a.x) + (_b.y - _a.y)


func equals(other: WireSegment) -> bool:
	return other != null and other.a == _a and other.b == _b


## Euclidean distance (in cell units) from [param point] to this segment.
func distance_to(point: Vector2) -> float:
	var closest := Geometry2D.get_closest_point_to_segment(point, Vector2(_a), Vector2(_b))
	return point.distance_to(closest)


func _to_string() -> String:
	return "WireSegment(%s -> %s)" % [_a, _b]
