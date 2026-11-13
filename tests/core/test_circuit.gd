extends GdUnitTestSuite

var _circuit: Circuit
var _changes: int


func before_test() -> void:
	_circuit = Circuit.new()
	_changes = 0
	_circuit.changed.connect(func() -> void: _changes += 1)


func _seg(ax: int, ay: int, bx: int, by: int) -> WireSegment:
	return WireSegment.create(Vector2i(ax, ay), Vector2i(bx, by))


func test_starts_empty() -> void:
	assert_int(_circuit.wire_count()).is_equal(0)


func test_add_wire() -> void:
	assert_bool(_circuit.add_wire(_seg(0, 0, 3, 0))).is_true()
	assert_int(_circuit.wire_count()).is_equal(1)
	assert_int(_changes).is_equal(1)


func test_add_rejects_null_and_duplicates() -> void:
	_circuit.add_wire(_seg(0, 0, 3, 0))
	assert_bool(_circuit.add_wire(null)).is_false()
	assert_bool(_circuit.add_wire(_seg(3, 0, 0, 0))).is_false()
	assert_int(_circuit.wire_count()).is_equal(1)
	assert_int(_changes).is_equal(1)


func test_remove_wire_by_value() -> void:
	_circuit.add_wire(_seg(0, 0, 3, 0))
	assert_bool(_circuit.remove_wire(_seg(3, 0, 0, 0))).is_true()
	assert_int(_circuit.wire_count()).is_equal(0)
	assert_bool(_circuit.remove_wire(_seg(3, 0, 0, 0))).is_false()
	assert_int(_changes).is_equal(2)


func test_get_wires_returns_a_copy() -> void:
	_circuit.add_wire(_seg(0, 0, 3, 0))
	var wires := _circuit.get_wires()
	wires.clear()
	assert_int(_circuit.wire_count()).is_equal(1)


func test_clear() -> void:
	_circuit.add_wire(_seg(0, 0, 3, 0))
	_circuit.add_wire(_seg(0, 0, 0, 3))
	_circuit.clear()
	assert_int(_circuit.wire_count()).is_equal(0)
	assert_int(_changes).is_equal(3)


func test_clear_on_empty_circuit_emits_nothing() -> void:
	_circuit.clear()
	assert_int(_changes).is_equal(0)


func test_find_wire_at_returns_closest_within_tolerance() -> void:
	var h := _seg(0, 0, 10, 0)
	var v := _seg(5, 1, 5, 10)
	_circuit.add_wire(h)
	_circuit.add_wire(v)
	assert_bool(_circuit.find_wire_at(Vector2(2, 0.2), 0.5).equals(h)).is_true()
	assert_bool(_circuit.find_wire_at(Vector2(5.1, 6), 0.5).equals(v)).is_true()
	assert_object(_circuit.find_wire_at(Vector2(2, 3), 0.5)).is_null()
