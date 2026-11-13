class_name CircuitView
extends Node2D
## Renders the grid and the circuit, and routes canvas input to the active tool.

signal selection_changed
signal tool_changed

const HIT_TOLERANCE_PX := 6.0
const MIN_GRID_SPACING_PX := 10.0
const MAJOR_EVERY := 8


## Palette used by the canvas.
class Palette:
	var background := Color("#16181d")
	var grid_minor := Color(1, 1, 1, 0.05)
	var grid_major := Color(1, 1, 1, 0.11)
	var axis := Color(1, 1, 1, 0.2)
	var wire := Color("#4fc1ff")
	var selected := Color("#ffb454")
	var preview := Color(0.31, 0.76, 1.0, 0.55)
	var cursor := Color(1, 1, 1, 0.35)


var circuit: Circuit
var commands: CircuitCommands
var camera: CameraController
var theme_colors := Palette.new()

var selected_wire: WireSegment = null:
	set(value):
		if value == selected_wire or (value != null and value.equals(selected_wire)):
			return
		selected_wire = value
		selection_changed.emit()
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
		queue_redraw()  # cursor indicator
	if _tool.handle_input(event):
		get_viewport().set_input_as_handled()


func _on_circuit_changed() -> void:
	if selected_wire != null and not circuit.has_wire(selected_wire):
		selected_wire = null
	queue_redraw()


# --- Drawing -----------------------------------------------------------------


func _draw() -> void:
	if circuit == null:
		return
	var visible := _visible_world_rect()
	draw_rect(visible, theme_colors.background)
	_draw_grid(visible)
	for wire in circuit.get_wires():
		var color := theme_colors.selected if wire.equals(selected_wire) else theme_colors.wire
		draw_segment(wire, color)
		draw_node_dot(wire.a, color)
		draw_node_dot(wire.b, color)
	_tool.draw()
	draw_arc(Grid.to_world(mouse_cell()), 3.0, 0.0, TAU, 16, theme_colors.cursor, 1.0, true)


func draw_segment(segment: WireSegment, color: Color) -> void:
	draw_line(Grid.to_world(segment.a), Grid.to_world(segment.b), color, _wire_width(), true)


func draw_node_dot(cell: Vector2i, color: Color) -> void:
	draw_circle(Grid.to_world(cell), _wire_width() * 0.9, color)


func _wire_width() -> float:
	return maxf(3.0, 1.5 / camera.zoom.x)


func _visible_world_rect() -> Rect2:
	var inverse := get_canvas_transform().affine_inverse()
	return inverse * Rect2(Vector2.ZERO, get_viewport_rect().size)


func _draw_grid(visible: Rect2) -> void:
	var spacing_px := Grid.CELL_SIZE * camera.zoom.x
	var step := 1
	while spacing_px * step < MIN_GRID_SPACING_PX:
		step *= 2
	var first := Grid.snap(visible.position) - Vector2i.ONE
	var last := Grid.snap(visible.end) + Vector2i.ONE
	first = Vector2i(floori(first.x / float(step)) * step, floori(first.y / float(step)) * step)

	var minor := PackedVector2Array()
	var major := PackedVector2Array()
	for x in range(first.x, last.x + 1, step):
		var target := major if x % MAJOR_EVERY == 0 else minor
		target.append(Vector2(x * Grid.CELL_SIZE, visible.position.y))
		target.append(Vector2(x * Grid.CELL_SIZE, visible.end.y))
	for y in range(first.y, last.y + 1, step):
		var target := major if y % MAJOR_EVERY == 0 else minor
		target.append(Vector2(visible.position.x, y * Grid.CELL_SIZE))
		target.append(Vector2(visible.end.x, y * Grid.CELL_SIZE))
	if not minor.is_empty():
		draw_multiline(minor, theme_colors.grid_minor)
	if not major.is_empty():
		draw_multiline(major, theme_colors.grid_major)
	draw_line(Vector2(visible.position.x, 0), Vector2(visible.end.x, 0), theme_colors.axis)
	draw_line(Vector2(0, visible.position.y), Vector2(0, visible.end.y), theme_colors.axis)
