class_name AppTheme
extends RefCounted
## Builds the deep dark UI theme from [Palette]. Sharp corners everywhere, to
## match the square wire rendering.

const FONT_SIZE := 14


static func build() -> Theme:
	var theme := Theme.new()
	theme.default_font_size = FONT_SIZE

	theme.set_color("font_color", "Label", Palette.UI_TEXT)

	var bar := _box(Palette.UI_PANEL, 10, 5)
	bar.border_width_top = 1
	bar.border_color = Palette.UI_BORDER
	theme.set_stylebox("panel", "PanelContainer", bar)
	theme.set_stylebox("panel", "Panel", _box(Palette.UI_PANEL))

	_menus(theme)
	_buttons(theme)
	_windows(theme)
	_inputs(theme)
	return theme


static func _menus(theme: Theme) -> void:
	var popup := _box(Palette.UI_PANEL_RAISED, 4, 4)
	_border(popup, Palette.UI_BORDER)
	theme.set_stylebox("panel", "PopupMenu", popup)
	theme.set_stylebox("hover", "PopupMenu", _box(Palette.UI_HOVER))
	var separator := StyleBoxLine.new()
	separator.color = Palette.UI_BORDER
	theme.set_stylebox("separator", "PopupMenu", separator)
	theme.set_color("font_color", "PopupMenu", Palette.UI_TEXT)
	theme.set_color("font_hover_color", "PopupMenu", Palette.UI_TEXT)
	theme.set_color("font_disabled_color", "PopupMenu", Palette.UI_TEXT_DIM)
	theme.set_color("font_accelerator_color", "PopupMenu", Palette.UI_TEXT_DIM)

	# MenuBar is only visible where there is no native global menu (not macOS).
	theme.set_stylebox("normal", "MenuBar", _box(Palette.UI_PANEL, 10, 4))
	theme.set_stylebox("hover", "MenuBar", _box(Palette.UI_HOVER, 10, 4))
	theme.set_stylebox("pressed", "MenuBar", _box(Palette.UI_HOVER, 10, 4))
	theme.set_color("font_color", "MenuBar", Palette.UI_TEXT)
	theme.set_color("font_hover_color", "MenuBar", Palette.UI_TEXT)
	theme.set_color("font_pressed_color", "MenuBar", Palette.UI_TEXT)


static func _buttons(theme: Theme) -> void:
	var normal := _box(Palette.UI_PANEL_RAISED, 14, 6)
	_border(normal, Palette.UI_BORDER)
	var hover := _box(Palette.UI_HOVER, 14, 6)
	_border(hover, Palette.UI_BORDER)
	var focus := _box(Color.TRANSPARENT, 14, 6)
	focus.draw_center = false
	_border(focus, Palette.UI_ACCENT)
	theme.set_stylebox("normal", "Button", normal)
	theme.set_stylebox("hover", "Button", hover)
	theme.set_stylebox("pressed", "Button", hover)
	theme.set_stylebox("disabled", "Button", _box(Palette.UI_PANEL, 14, 6))
	theme.set_stylebox("focus", "Button", focus)
	for state: String in [
		"font_color", "font_hover_color", "font_pressed_color", "font_focus_color"
	]:
		theme.set_color(state, "Button", Palette.UI_TEXT)
	theme.set_color("font_disabled_color", "Button", Palette.UI_TEXT_DIM)


static func _windows(theme: Theme) -> void:
	theme.set_stylebox("panel", "AcceptDialog", _box(Palette.UI_PANEL, 14, 12))
	var frame := _box(Palette.UI_PANEL)
	_border(frame, Palette.UI_BORDER)
	frame.expand_margin_left = 1
	frame.expand_margin_right = 1
	frame.expand_margin_bottom = 1
	frame.expand_margin_top = 28
	theme.set_stylebox("embedded_border", "Window", frame)
	theme.set_stylebox("embedded_unfocused_border", "Window", frame)
	theme.set_color("title_color", "Window", Palette.UI_TEXT)
	theme.set_constant("title_height", "Window", 28)


static func _inputs(theme: Theme) -> void:
	var normal := _box(Palette.CANVAS_BG, 8, 5)
	_border(normal, Palette.UI_BORDER)
	var focus := _box(Palette.CANVAS_BG, 8, 5)
	_border(focus, Palette.UI_ACCENT)
	theme.set_stylebox("normal", "LineEdit", normal)
	theme.set_stylebox("focus", "LineEdit", focus)
	theme.set_color("font_color", "LineEdit", Palette.UI_TEXT)
	theme.set_color("caret_color", "LineEdit", Palette.UI_ACCENT)
	var tooltip := _box(Palette.UI_PANEL_RAISED, 8, 4)
	_border(tooltip, Palette.UI_BORDER)
	theme.set_stylebox("panel", "TooltipPanel", tooltip)
	theme.set_color("font_color", "TooltipLabel", Palette.UI_TEXT)


static func _box(color: Color, margin_h: float = 0.0, margin_v: float = 0.0) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(0)
	box.content_margin_left = margin_h
	box.content_margin_right = margin_h
	box.content_margin_top = margin_v
	box.content_margin_bottom = margin_v
	return box


static func _border(box: StyleBoxFlat, color: Color) -> void:
	box.border_color = color
	box.set_border_width_all(1)
