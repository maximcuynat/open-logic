class_name CircuitView
extends Node2D
## Renders the grid and the circuit, and routes canvas input to the active tool.

signal selection_changed
signal tool_changed

const HIT_TOLERANCE_PX := 6.0

var circuit: Circuit
var commands: CircuitCommands
var camera: CameraController

var selected_wire: WireSegment = null:
	set(value):
		if value == selected_wire or (value != null and value.equals(selected_wire)):
			return
		selected_wire = value
		selection_changed.emit()
		queue_redraw()

## Wire under the cursor, highlighted while the select tool is active.
var hovered_wire: WireSegment = null:
	set(value):
		if value == hovered_wire or (value != null and value.equals(hovered_wire)):
			return
		hovered_wire = value
		queue_redraw()

var active_tool: EditorTool:
	get:
		return _tool

var _tool: EditorTool
var _tools: Dictionary = {}


func setup(p_circuit: Circuit, p_commands: CircuitCommands, p_camera: CameraController) -> void:
	circuit = p_circuit
	commands = p_commands
	camera = p_camera
	circuit.changed.connect(_on_circuit_changed)
	camera.view_changed.connect(queue_redraw)
	get_viewport().size_changed.connect(queue_redraw)
	_tools = {"wire": WireTool.new(self), "select": SelectTool.new(self)}
	set_tool("wire")


func set_tool(tool_id: String) -> void:
	if _tool != null:
		_tool.cancel()
	_tool = _tools[tool_id]
	_update_hover()
	tool_changed.emit()
	queue_redraw()


func mouse_cell() -> Vector2i:
	return Grid.snap(get_global_mouse_position())


func wire_at_mouse() -> WireSegment:
	var tolerance := HIT_TOLERANCE_PX / (Grid.CELL_SIZE * camera.zoom.x)
	return circuit.find_wire_at(Grid.to_cell_space(get_global_mouse_position()), tolerance)


func delete_wire_at_mouse() -> void:
	var wire := wire_at_mouse()
	if wire != null:
		commands.remove_wire(wire)


func delete_selection() -> void:
	if selected_wire != null:
		commands.remove_wire(selected_wire)


func _unhandled_input(event: InputEvent) -> void:
	if camera.is_panning or Input.is_key_pressed(KEY_SPACE):
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_tool.cancel()
		selected_wire = null
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseMotion:
		_update_hover()
		queue_redraw()  # cursor indicator
	if _tool.handle_input(event):
		get_viewport().set_input_as_handled()


func _on_circuit_changed() -> void:
	if selected_wire != null and not circuit.has_wire(selected_wire):
		selected_wire = null
	_update_hover()
	queue_redraw()


func _update_hover() -> void:
	hovered_wire = wire_at_mouse() if _tool is SelectTool else null


# --- Drawing -----------------------------------------------------------------


func _draw() -> void:
	if circuit == null:
		return
	var visible := _visible_world_rect()
	draw_rect(visible, Palette.CANVAS_BG)
	_draw_grid(visible)
	for wire in circuit.get_wires():
		draw_segment(wire, _wire_color(wire))
	_tool.draw()
	_draw_cursor()


## Draws [param segment] as a crisp filled rectangle with square ends. Colours
## must be opaque so that overlapping segments stay uniform.
func draw_segment(segment: WireSegment, color: Color) -> void:
	draw_rect(WireGeometry.segment_rect(segment, _wire_width()), color, true)


func _wire_color(wire: WireSegment) -> Color:
	if wire.equals(selected_wire):
		return Palette.WIRE_SELECTED
	if wire.equals(hovered_wire):
		return Palette.WIRE_HOVER
	return Palette.WIRE


## Wire thickness in world units: a quarter of a cell, at least 1.5 screen pixels.
func _wire_width() -> float:
	return maxf(Grid.CELL_SIZE / 4.0, 1.5 / camera.zoom.x)


func _draw_cursor() -> void:
	var size := Vector2(7, 7) / camera.zoom.x + Vector2.ONE * _wire_width()
	var rect := Rect2(Grid.to_world(mouse_cell()) - size / 2.0, size)
	draw_rect(rect, Palette.CURSOR, false, 1.0 / camera.zoom.x)


func _visible_world_rect() -> Rect2:
	var inverse := get_canvas_transform().affine_inverse()
	return inverse * Rect2(Vector2.ZERO, get_viewport_rect().size)


## Minor lines every cell (faded out when zoomed out), major lines every
## [constant GridStyle.MAJOR_EVERY] cells, and the two axes on top.
func _draw_grid(visible: Rect2) -> void:
	var cell_px := Grid.CELL_SIZE * camera.zoom.x
	var draw_minor := GridStyle.minor_weight(cell_px) > 0.0
	var first := Grid.snap(visible.position) - Vector2i.ONE
	var last := Grid.snap(visible.end) + Vector2i.ONE
	var lines := {
		GridStyle.LineKind.MINOR: PackedVector2Array(),
		GridStyle.LineKind.MAJOR: PackedVector2Array(),
		GridStyle.LineKind.AXIS: PackedVector2Array(),
	}
	for x in range(first.x, last.x + 1):
		var kind := GridStyle.line_kind(x)
		if kind != GridStyle.LineKind.MINOR or draw_minor:
			lines[kind].append(Vector2(x * Grid.CELL_SIZE, visible.position.y))
			lines[kind].append(Vector2(x * Grid.CELL_SIZE, visible.end.y))
	for y in range(first.y, last.y + 1):
		var kind := GridStyle.line_kind(y)
		if kind != GridStyle.LineKind.MINOR or draw_minor:
			lines[kind].append(Vector2(visible.position.x, y * Grid.CELL_SIZE))
			lines[kind].append(Vector2(visible.end.x, y * Grid.CELL_SIZE))
	var colors := {
		GridStyle.LineKind.MINOR: GridStyle.minor_color(cell_px),
		GridStyle.LineKind.MAJOR: Palette.GRID_MAJOR,
		GridStyle.LineKind.AXIS: Palette.GRID_AXIS,
	}
	for kind: GridStyle.LineKind in [
		GridStyle.LineKind.MINOR, GridStyle.LineKind.MAJOR, GridStyle.LineKind.AXIS
	]:
		var points: PackedVector2Array = lines[kind]
		if not points.is_empty():
			draw_multiline(points, colors[kind])
