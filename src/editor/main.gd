extends Node
## Application shell: builds the editor UI and handles documents
## (new / open / save / autosave) and menu commands.

enum MenuId {
	NEW,
	OPEN,
	SAVE,
	SAVE_AS,
	QUIT,
	UNDO,
	REDO,
	DELETE,
	TOOL_WIRE,
	TOOL_SELECT,
	RESET_VIEW,
	TOGGLE_FULLSCREEN,
	ABOUT,
}

const FILE_FILTER := "*.olc ; open-logic circuit"
const AUTOSAVE_PATH := "user://autosave.olc"
const AUTOSAVE_DELAY := 1.0

var _circuit := Circuit.new()
var _commands := CircuitCommands.new(_circuit)
var _current_path := ""
var _pending_action := Callable()
var _last_mouse := Vector2.INF

var _view: CircuitView
var _camera: CameraController
var _status: Label
var _file_dialog: FileDialog
var _confirm: ConfirmationDialog
var _about: AcceptDialog
var _autosave_timer: Timer


func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	_build_canvas()
	_build_ui()
	_restore_autosave()
	_circuit.changed.connect(_on_circuit_changed)
	_refresh()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_guard_unsaved(func() -> void: get_tree().quit())


# --- UI construction -----------------------------------------------------------


func _build_canvas() -> void:
	RenderingServer.set_default_clear_color(CircuitView.Palette.new().background)
	_camera = CameraController.new()
	add_child(_camera)
	_view = CircuitView.new()
	add_child(_view)
	_view.setup(_circuit, _commands, _camera)
	_view.tool_changed.connect(_refresh)
	_view.selection_changed.connect(_refresh)
	_camera.view_changed.connect(_refresh)

	_autosave_timer = Timer.new()
	_autosave_timer.one_shot = true
	_autosave_timer.wait_time = AUTOSAVE_DELAY
	_autosave_timer.timeout.connect(_write_autosave)
	add_child(_autosave_timer)


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	var menu_bar := MenuBar.new()
	root.add_child(menu_bar)
	_add_menu(
		menu_bar,
		"File",
		[
			[MenuId.NEW, "New", KEY_N],
			[MenuId.OPEN, "Open...", KEY_O],
			[],
			[MenuId.SAVE, "Save", KEY_S],
			[MenuId.SAVE_AS, "Save As...", KEY_S, KEY_MASK_SHIFT],
			[],
			[MenuId.QUIT, "Quit", KEY_Q],
		]
	)
	_add_menu(
		menu_bar,
		"Edit",
		[
			[MenuId.UNDO, "Undo", KEY_Z],
			[MenuId.REDO, "Redo", KEY_Z, KEY_MASK_SHIFT],
			[],
			[MenuId.DELETE, "Delete", [KEY_BACKSPACE, KEY_DELETE], -1],
		]
	)
	_add_menu(
		menu_bar,
		"View",
		[
			[MenuId.TOOL_WIRE, "Wire Tool", KEY_W, -1],
			[MenuId.TOOL_SELECT, "Select Tool", KEY_V, -1],
			[],
			[MenuId.RESET_VIEW, "Reset View", KEY_0],
			[MenuId.TOGGLE_FULLSCREEN, "Toggle Fullscreen", KEY_F11, -1],
		]
	)
	_add_menu(menu_bar, "Help", [[MenuId.ABOUT, "About open-logic"]])

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(spacer)

	var bar := PanelContainer.new()
	root.add_child(bar)
	_status = Label.new()
	bar.add_child(_status)

	_file_dialog = FileDialog.new()
	_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_file_dialog.use_native_dialog = true
	_file_dialog.filters = PackedStringArray([FILE_FILTER])
	_file_dialog.file_selected.connect(_on_file_selected)
	add_child(_file_dialog)

	_confirm = ConfirmationDialog.new()
	_confirm.dialog_text = "You have unsaved changes. Discard them?"
	_confirm.ok_button_text = "Discard"
	_confirm.confirmed.connect(func() -> void: _run_pending())
	add_child(_confirm)

	_about = AcceptDialog.new()
	_about.title = "About open-logic"
	_about.dialog_text = (
		"open-logic %s\nOpen-source digital logic circuit designer.\nLicensed under GPL-3.0."
		% _version()
	)
	add_child(_about)


## Each item is [id, label, keycode(s)?, modifiers?]. An empty array is a
## separator. Modifiers default to Cmd/Ctrl; pass -1 for a bare key.
func _add_menu(bar: MenuBar, title: String, items: Array) -> void:
	var popup := PopupMenu.new()
	popup.name = title
	bar.add_child(popup)
	for item: Array in items:
		if item.is_empty():
			popup.add_separator()
			continue
		if item.size() < 3:
			popup.add_item(item[1], item[0])
			continue
		var keycodes: Array = item[2] if item[2] is Array else [item[2]]
		var extra: int = item[3] if item.size() > 3 else 0
		var shortcut := Shortcut.new()
		for keycode: int in keycodes:
			var key := InputEventKey.new()
			key.keycode = keycode
			if extra != -1:
				key.command_or_control_autoremap = true
				key.shift_pressed = extra & KEY_MASK_SHIFT != 0
			shortcut.events.append(key)
		popup.add_shortcut(shortcut, item[0], true)
		popup.set_item_text(popup.get_item_index(item[0]), item[1])
	popup.id_pressed.connect(_on_menu)


# --- Commands ------------------------------------------------------------------


func _on_menu(id: int) -> void:
	match id:
		MenuId.NEW:
			_guard_unsaved(_new_document)
		MenuId.OPEN:
			_guard_unsaved(func() -> void: _show_file_dialog(FileDialog.FILE_MODE_OPEN_FILE))
		MenuId.SAVE:
			_save()
		MenuId.SAVE_AS:
			_show_file_dialog(FileDialog.FILE_MODE_SAVE_FILE)
		MenuId.QUIT:
			_guard_unsaved(func() -> void: get_tree().quit())
		MenuId.UNDO:
			_commands.undo()
		MenuId.REDO:
			_commands.redo()
		MenuId.DELETE:
			_view.delete_selection()
		MenuId.TOOL_WIRE:
			_view.set_tool("wire")
		MenuId.TOOL_SELECT:
			_view.set_tool("select")
		MenuId.RESET_VIEW:
			_camera.reset_view()
		MenuId.TOGGLE_FULLSCREEN:
			_toggle_fullscreen()
		MenuId.ABOUT:
			_about.popup_centered()


func _toggle_fullscreen() -> void:
	var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_MAXIMIZED if fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN
	)


func _guard_unsaved(action: Callable) -> void:
	if not _commands.is_dirty():
		action.call()
		return
	_pending_action = action
	_confirm.popup_centered()


func _run_pending() -> void:
	var action := _pending_action
	_pending_action = Callable()
	if action.is_valid():
		action.call()


func _new_document() -> void:
	_replace_circuit(Circuit.new())
	_current_path = ""
	_refresh()


func _show_file_dialog(mode: FileDialog.FileMode) -> void:
	_file_dialog.file_mode = mode
	_file_dialog.title = (
		"Open Circuit" if mode == FileDialog.FILE_MODE_OPEN_FILE else "Save Circuit"
	)
	_file_dialog.popup_centered_ratio(0.6)


func _on_file_selected(path: String) -> void:
	if _file_dialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		_open(path)
	else:
		_save_to(path)


func _save() -> void:
	if _current_path.is_empty():
		_show_file_dialog(FileDialog.FILE_MODE_SAVE_FILE)
	else:
		_save_to(_current_path)


func _save_to(path: String) -> void:
	if not path.ends_with(".olc"):
		path += ".olc"
	var error := _write_file(path, CircuitSerializer.stringify(_circuit))
	if error != OK:
		_show_error("Could not save %s (%s)." % [path, error_string(error)])
		return
	_current_path = path
	_commands.mark_saved()
	_refresh()


func _open(path: String) -> void:
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty() and FileAccess.get_open_error() != OK:
		_show_error("Could not read %s (%s)." % [path, error_string(FileAccess.get_open_error())])
		return
	var result := CircuitSerializer.parse(text)
	if result.circuit == null:
		_show_error("Could not open %s: %s" % [path.get_file(), result.error])
		return
	_replace_circuit(result.circuit)
	_current_path = path
	_refresh()


## Swaps the document content in place so every component keeps its reference.
func _replace_circuit(source: Circuit) -> void:
	_circuit.clear()
	for wire in source.get_wires():
		_circuit.add_wire(wire)
	_commands.reset()


# --- Autosave ------------------------------------------------------------------


func _on_circuit_changed() -> void:
	_autosave_timer.start()
	_refresh()


func _write_autosave() -> void:
	var error := _write_file(AUTOSAVE_PATH, CircuitSerializer.stringify(_circuit))
	if error != OK:
		push_warning("Autosave failed: %s" % error_string(error))


func _restore_autosave() -> void:
	if not FileAccess.file_exists(AUTOSAVE_PATH):
		return
	var result := CircuitSerializer.parse(FileAccess.get_file_as_string(AUTOSAVE_PATH))
	if result.circuit != null:
		_replace_circuit(result.circuit)


# --- Helpers ---------------------------------------------------------------------


func _write_file(path: String, content: String) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(content)
	file.close()
	return OK


func _show_error(message: String) -> void:
	push_error(message)
	var dialog := AcceptDialog.new()
	dialog.title = "Error"
	dialog.dialog_text = message
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered()


func _refresh() -> void:
	if _status == null:
		return
	var cell := _view.mouse_cell()
	_status.text = (
		"  %s tool  |  cell (%d, %d)  |  zoom %d%%  |  %d wires%s"
		% [
			_view.active_tool.get_display_name(),
			cell.x,
			cell.y,
			roundi(_camera.zoom.x * 100),
			_circuit.wire_count(),
			"  |  1 selected" if _view.selected_wire != null else "",
		]
	)
	var name := _current_path.get_file() if not _current_path.is_empty() else "Untitled"
	get_window().title = "open-logic - %s%s" % [name, " *" if _commands.is_dirty() else ""]


func _version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", "dev"))


func _process(_delta: float) -> void:
	# Keep the cursor coordinates in the status bar live.
	if get_viewport().get_mouse_position() != _last_mouse:
		_last_mouse = get_viewport().get_mouse_position()
		_refresh()
