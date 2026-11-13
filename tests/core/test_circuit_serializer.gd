extends GdUnitTestSuite


func test_round_trip_preserves_wires() -> void:
	var circuit := Circuit.new()
	circuit.add_wire(WireSegment.create(Vector2i(-3, 2), Vector2i(4, 2)))
	circuit.add_wire(WireSegment.create(Vector2i(4, 2), Vector2i(4, -7)))
	var result := CircuitSerializer.parse(CircuitSerializer.stringify(circuit))
	assert_str(result.error).is_empty()
	assert_int(result.circuit.wire_count()).is_equal(2)
	for wire: WireSegment in circuit.get_wires():
		assert_bool(result.circuit.has_wire(wire)).is_true()


func test_output_declares_format_and_schema() -> void:
	var data: Dictionary = JSON.parse_string(CircuitSerializer.stringify(Circuit.new()))
	assert_str(data["format"]).is_equal(CircuitSerializer.FORMAT)
	assert_int(int(data["schema"])).is_equal(CircuitSerializer.SCHEMA)


func test_rejects_invalid_json() -> void:
	var result := CircuitSerializer.parse("{not json")
	assert_object(result.circuit).is_null()
	assert_str(result.error).is_not_empty()


func test_rejects_wrong_format() -> void:
	var result := CircuitSerializer.parse('{"format":"other","schema":1,"wires":[]}')
	assert_object(result.circuit).is_null()


func test_rejects_unknown_schema() -> void:
	var result := CircuitSerializer.parse('{"format":"open-logic","schema":99,"wires":[]}')
	assert_object(result.circuit).is_null()
	assert_str(result.error).contains("schema")


func test_rejects_malformed_wire() -> void:
	for wires: String in [
		'[{"a":[0,0]}]',
		'[{"a":[0,0],"b":[1.5,0]}]',
		'[{"a":[0,0],"b":[3,4]}]',
		'[{"a":[0,0],"b":[0,0]}]',
		'["oops"]',
	]:
		var result := CircuitSerializer.parse(
			'{"format":"open-logic","schema":1,"wires":%s}' % wires
		)
		assert_object(result.circuit).override_failure_message("should reject %s" % wires).is_null()
