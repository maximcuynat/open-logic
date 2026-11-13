extends GdUnitTestSuite

var _circuit: Circuit
var _commands: CircuitCommands


func before_test() -> void:
	_circuit = Circuit.new()
	_commands = CircuitCommands.new(_circuit)


func _seg(ax: int, ay: int, bx: int, by: int) -> WireSegment:
	return WireSegment.create(Vector2i(ax, ay), Vector2i(bx, by))


func test_add_wires_is_a_single_undoable_action() -> void:
	_commands.add_wires([_seg(0, 0, 4, 0), _seg(4, 0, 4, 3)])
	assert_int(_circuit.wire_count()).is_equal(2)
	assert_bool(_commands.undo()).is_true()
	assert_int(_circuit.wire_count()).is_equal(0)
	assert_bool(_commands.redo()).is_true()
	assert_int(_circuit.wire_count()).is_equal(2)


func test_add_wires_skips_existing_and_empty_batches() -> void:
	_commands.add_wires([_seg(0, 0, 4, 0)])
	assert_bool(_commands.add_wires([_seg(4, 0, 0, 0)])).is_false()
	assert_bool(_commands.add_wires([])).is_false()
	_commands.undo()
	assert_int(_circuit.wire_count()).is_equal(0)
	assert_bool(_commands.has_undo()).is_false()


func test_undo_of_partial_batch_keeps_preexisting_wire() -> void:
	_commands.add_wires([_seg(0, 0, 4, 0)])
	_commands.add_wires([_seg(0, 0, 4, 0), _seg(4, 0, 4, 3)])
	_commands.undo()
	assert_int(_circuit.wire_count()).is_equal(1)
	assert_bool(_circuit.has_wire(_seg(0, 0, 4, 0))).is_true()


func test_remove_wire_is_undoable() -> void:
	_commands.add_wires([_seg(0, 0, 4, 0)])
	assert_bool(_commands.remove_wire(_seg(0, 0, 4, 0))).is_true()
	assert_int(_circuit.wire_count()).is_equal(0)
	_commands.undo()
	assert_int(_circuit.wire_count()).is_equal(1)


func test_remove_missing_wire_records_nothing() -> void:
	assert_bool(_commands.remove_wire(_seg(0, 0, 4, 0))).is_false()
	assert_bool(_commands.has_undo()).is_false()


func test_undo_redo_on_empty_history() -> void:
	assert_bool(_commands.undo()).is_false()
	assert_bool(_commands.redo()).is_false()


func test_dirty_tracking() -> void:
	assert_bool(_commands.is_dirty()).is_false()
	_commands.add_wires([_seg(0, 0, 4, 0)])
	assert_bool(_commands.is_dirty()).is_true()
	_commands.mark_saved()
	assert_bool(_commands.is_dirty()).is_false()
	_commands.undo()
	assert_bool(_commands.is_dirty()).is_true()
	_commands.redo()
	assert_bool(_commands.is_dirty()).is_false()


func test_reset_clears_history_and_dirty_flag() -> void:
	_commands.add_wires([_seg(0, 0, 4, 0)])
	_commands.reset()
	assert_bool(_commands.has_undo()).is_false()
	assert_bool(_commands.is_dirty()).is_false()
