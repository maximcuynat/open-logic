class_name CircuitCommands
extends RefCounted
## Undoable editing operations on a [Circuit].
##
## Every user-visible mutation goes through this class so that it can be
## undone, redone and tracked for unsaved changes.

var _circuit: Circuit
var _history := UndoRedo.new()
var _saved_version: int


func _init(circuit: Circuit) -> void:
	_circuit = circuit
	_saved_version = _history.get_version()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_history.free()


## Adds the wires not already present as one undoable action.
## Returns [code]false[/code] when nothing new was added.
func add_wires(wires: Array) -> bool:
	var fresh: Array[WireSegment] = []
	for wire: WireSegment in wires:
		if wire != null and not _circuit.has_wire(wire) and not _contains(fresh, wire):
			fresh.append(wire)
	if fresh.is_empty():
		return false
	_history.create_action("Add wire" if fresh.size() == 1 else "Add wires")
	for wire in fresh:
		_history.add_do_method(_circuit.add_wire.bind(wire))
		_history.add_undo_method(_circuit.remove_wire.bind(wire))
	_history.commit_action()
	return true


func remove_wire(wire: WireSegment) -> bool:
	if not _circuit.has_wire(wire):
		return false
	_history.create_action("Remove wire")
	_history.add_do_method(_circuit.remove_wire.bind(wire))
	_history.add_undo_method(_circuit.add_wire.bind(wire))
	_history.commit_action()
	return true


func undo() -> bool:
	return _history.undo()


func redo() -> bool:
	return _history.redo()


func has_undo() -> bool:
	return _history.has_undo()


func has_redo() -> bool:
	return _history.has_redo()


func is_dirty() -> bool:
	return _history.get_version() != _saved_version


func mark_saved() -> void:
	_saved_version = _history.get_version()


## Forgets the whole history, e.g. after loading or creating a document.
func reset() -> void:
	_history.clear_history()
	_saved_version = _history.get_version()


static func _contains(list: Array[WireSegment], wire: WireSegment) -> bool:
	for item in list:
		if item.equals(wire):
			return true
	return false
