class_name WireTool
extends EditorTool
## Draws orthogonal wires by click-and-drag.
##
## The first leg follows the initial drag direction; hold Shift to flip the
## corner. Right-click on a wire deletes it; Esc or right-click cancels a drag.

var _dragging := false
var _start := Vector2i.ZERO
var _end := Vector2i.ZERO
var _horizontal_first := true
var _direction_locked := false


func get_display_name() -> String:
	return "Wire"


func handle_input(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		return _handle_button(event)
	if event is InputEventMouseMotion and _dragging:
		_update_end()
		return true
	if event is InputEventKey and event.keycode == KEY_SHIFT and _dragging:
		view.queue_redraw()
		return true
	return false


func _handle_button(event: InputEventMouseButton) -> bool:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_direction_locked = false
			_start = view.mouse_cell()
			_end = _start
		elif _dragging:
			_dragging = false
			view.commands.add_wires(_preview())
		view.queue_redraw()
		return true
	if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if _dragging:
			cancel()
		else:
			view.delete_wire_at_mouse()
		return true
	return false


func _update_end() -> void:
	_end = view.mouse_cell()
	if not _direction_locked and _end != _start:
		var delta := _end - _start
		_horizontal_first = absi(delta.x) >= absi(delta.y)
		_direction_locked = true
	view.queue_redraw()


func _preview() -> Array[WireSegment]:
	var horizontal := _horizontal_first != Input.is_key_pressed(KEY_SHIFT)
	return WireRouter.route(_start, _end, horizontal)


func draw() -> void:
	if not _dragging:
		return
	for segment in _preview():
		view.draw_segment(segment, view.theme_colors.preview)
	view.draw_node_dot(_start, view.theme_colors.preview)


func cancel() -> void:
	_dragging = false
	view.queue_redraw()
