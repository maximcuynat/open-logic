class_name SelectTool
extends EditorTool
## Selects a wire on click. Deletion is done through Edit > Delete.


func get_display_name() -> String:
	return "Select"


func handle_input(event: InputEvent) -> bool:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			view.selected_wire = view.wire_at_mouse()
			return true
		if event.button_index == MOUSE_BUTTON_RIGHT:
			view.delete_wire_at_mouse()
			return true
	return false
