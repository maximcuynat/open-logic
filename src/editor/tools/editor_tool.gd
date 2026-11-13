class_name EditorTool
extends RefCounted
## Base class for canvas tools. A tool receives canvas input through
## [method handle_input] and may draw overlays in [method draw].

var view: CircuitView


func _init(owner_view: CircuitView) -> void:
	view = owner_view


func get_display_name() -> String:
	return ""


## Returns [code]true[/code] when the event was consumed.
func handle_input(_event: InputEvent) -> bool:
	return false


func draw() -> void:
	pass


func cancel() -> void:
	pass
