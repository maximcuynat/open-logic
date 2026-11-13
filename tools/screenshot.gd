extends SceneTree
## Renders the editor with a demo circuit and saves a PNG.
## Usage: godot --path . -s res://tools/screenshot.gd -- <output.png>


func _initialize() -> void:
	var main: Node = load("res://src/editor/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	var commands: CircuitCommands = main.get("_commands")
	commands.add_wires(WireRouter.route(Vector2i(-20, -8), Vector2i(-4, 6)))
	commands.add_wires(WireRouter.route(Vector2i(-4, 6), Vector2i(14, -2), false))
	commands.add_wires(WireRouter.route(Vector2i(-20, 10), Vector2i(20, 10)))
	commands.add_wires(WireRouter.route(Vector2i(6, -12), Vector2i(6, 10)))
	var view: CircuitView = main.get("_view")
	view.selected_wire = WireSegment.create(Vector2i(-20, 10), Vector2i(20, 10))
	for i in 10:
		await process_frame
	var args := OS.get_cmdline_user_args()
	var output := args[0] if not args.is_empty() else "screenshot.png"
	var error := root.get_texture().get_image().save_png(output)
	print("saved %s (%s)" % [output, error_string(error)])
	quit(error)
