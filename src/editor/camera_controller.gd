class_name CameraController
extends Camera2D
## Pan and zoom for the circuit canvas.
##
## Mouse: wheel zooms around the cursor, middle button or Space + left button
## pans. Trackpad: two-finger scroll pans, pinch zooms.

signal view_changed

const MIN_ZOOM := 0.2
const MAX_ZOOM := 5.0
const WHEEL_STEP := 1.15

var is_panning: bool:
	get:
		return _dragging

var _dragging := false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_button(event)
	elif event is InputEventMouseMotion and _dragging:
		position -= event.relative / zoom
		_notify()
		get_viewport().set_input_as_handled()
	elif event is InputEventPanGesture:
		position += event.delta * 20.0 / zoom
		_notify()
		get_viewport().set_input_as_handled()
	elif event is InputEventMagnifyGesture:
		zoom_at(event.factor, get_viewport().get_mouse_position())
		get_viewport().set_input_as_handled()


func _handle_button(event: InputEventMouseButton) -> void:
	match event.button_index:
		MOUSE_BUTTON_WHEEL_UP when event.pressed:
			zoom_at(WHEEL_STEP, event.position)
		MOUSE_BUTTON_WHEEL_DOWN when event.pressed:
			zoom_at(1.0 / WHEEL_STEP, event.position)
		MOUSE_BUTTON_MIDDLE:
			_dragging = event.pressed
		MOUSE_BUTTON_LEFT when Input.is_key_pressed(KEY_SPACE) or (_dragging and not event.pressed):
			_dragging = event.pressed
		_:
			return
	get_viewport().set_input_as_handled()


## Multiplies the zoom by [param factor] keeping the world point under
## [param screen_point] fixed.
func zoom_at(factor: float, screen_point: Vector2) -> void:
	var before := _screen_to_world(screen_point)
	var level := clampf(zoom.x * factor, MIN_ZOOM, MAX_ZOOM)
	zoom = Vector2(level, level)
	position += before - _screen_to_world(screen_point)
	_notify()


func reset_view() -> void:
	position = Vector2.ZERO
	zoom = Vector2.ONE
	_notify()


func _screen_to_world(screen_point: Vector2) -> Vector2:
	var half := get_viewport_rect().size / 2.0
	return position + (screen_point - half) / zoom


func _notify() -> void:
	view_changed.emit()
