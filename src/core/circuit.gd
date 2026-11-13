class_name Circuit
extends RefCounted
## The document model: the set of wires drawn on the grid.
##
## Pure data, no scene-tree dependency, so it can be unit-tested headless and
## later ported to a native module.

## Emitted after any modification.
signal changed

var _wires: Array[WireSegment] = []


func wire_count() -> int:
	return _wires.size()


## Returns a copy of the wire list; mutating it does not affect the circuit.
func get_wires() -> Array[WireSegment]:
	return _wires.duplicate()


func has_wire(wire: WireSegment) -> bool:
	return _index_of(wire) != -1


## Adds [param wire]. Returns [code]false[/code] for [code]null[/code] or an
## exact duplicate.
func add_wire(wire: WireSegment) -> bool:
	if wire == null or has_wire(wire):
		return false
	_wires.append(wire)
	changed.emit()
	return true


## Removes the wire equal to [param wire]. Returns [code]false[/code] if absent.
func remove_wire(wire: WireSegment) -> bool:
	var index := _index_of(wire)
	if index == -1:
		return false
	_wires.remove_at(index)
	changed.emit()
	return true


func clear() -> void:
	if _wires.is_empty():
		return
	_wires.clear()
	changed.emit()


## Returns the wire closest to [param point] (cell units) if it lies within
## [param tolerance], otherwise [code]null[/code].
func find_wire_at(point: Vector2, tolerance: float) -> WireSegment:
	var best: WireSegment = null
	var best_distance := tolerance
	for wire in _wires:
		var distance := wire.distance_to(point)
		if distance <= best_distance:
			best = wire
			best_distance = distance
	return best


func _index_of(wire: WireSegment) -> int:
	if wire == null:
		return -1
	for i in _wires.size():
		if _wires[i].equals(wire):
			return i
	return -1
