class_name CircuitSerializer
extends RefCounted
## Reads and writes circuits as versioned JSON documents.
##
## See docs/FILE_FORMAT.md for the specification.

const FORMAT := "open-logic"
const SCHEMA := 1


## Outcome of [method parse]: exactly one of [member circuit] or
## [member error] is set.
class LoadResult:
	var circuit: Circuit = null
	var error: String = ""

	static func ok(value: Circuit) -> LoadResult:
		var result := LoadResult.new()
		result.circuit = value
		return result

	static func fail(message: String) -> LoadResult:
		var result := LoadResult.new()
		result.error = message
		return result


static func stringify(circuit: Circuit) -> String:
	var wires: Array = []
	for wire in circuit.get_wires():
		wires.append({"a": [wire.a.x, wire.a.y], "b": [wire.b.x, wire.b.y]})
	return JSON.stringify({"format": FORMAT, "schema": SCHEMA, "wires": wires}, "  ")


static func parse(text: String) -> LoadResult:
	var json := JSON.new()
	if json.parse(text) != OK:
		return LoadResult.fail(
			"Invalid JSON at line %d: %s" % [json.get_error_line(), json.get_error_message()]
		)
	var data: Variant = json.data
	if not data is Dictionary:
		return LoadResult.fail("Root must be an object")
	if data.get("format") != FORMAT:
		return LoadResult.fail("Not an open-logic file")
	var schema: Variant = data.get("schema")
	if not _is_integer(schema) or int(schema) != SCHEMA:
		return LoadResult.fail("Unsupported schema version: %s" % str(schema))
	var wires: Variant = data.get("wires")
	if not wires is Array:
		return LoadResult.fail("'wires' must be an array")

	var circuit := Circuit.new()
	for i in wires.size():
		var wire := _parse_wire(wires[i])
		if wire == null:
			return LoadResult.fail("Invalid wire at index %d" % i)
		circuit.add_wire(wire)
	return LoadResult.ok(circuit)


static func _parse_wire(entry: Variant) -> WireSegment:
	if not entry is Dictionary:
		return null
	var a: Variant = _parse_cell(entry.get("a"))
	var b: Variant = _parse_cell(entry.get("b"))
	if a == null or b == null:
		return null
	return WireSegment.create(a, b)


static func _parse_cell(value: Variant) -> Variant:
	if not value is Array or value.size() != 2:
		return null
	if not _is_integer(value[0]) or not _is_integer(value[1]):
		return null
	return Vector2i(int(value[0]), int(value[1]))


static func _is_integer(value: Variant) -> bool:
	if value is int:
		return true
	return value is float and is_finite(value) and value == floorf(value)
