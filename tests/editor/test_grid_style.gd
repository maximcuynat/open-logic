extends GdUnitTestSuite


func test_minor_lines_hidden_when_cells_are_tiny() -> void:
	assert_float(GridStyle.minor_weight(0.0)).is_equal(0.0)
	assert_float(GridStyle.minor_weight(GridStyle.MINOR_FADE_START_PX)).is_equal(0.0)


func test_minor_lines_fully_visible_when_cells_are_large() -> void:
	assert_float(GridStyle.minor_weight(GridStyle.MINOR_FADE_END_PX)).is_equal(1.0)
	assert_float(GridStyle.minor_weight(500.0)).is_equal(1.0)


func test_minor_lines_fade_linearly_in_between() -> void:
	var middle := (GridStyle.MINOR_FADE_START_PX + GridStyle.MINOR_FADE_END_PX) / 2.0
	assert_float(GridStyle.minor_weight(middle)).is_equal_approx(0.5, 0.0001)


func test_minor_color_blends_from_background() -> void:
	assert_that(GridStyle.minor_color(0.0)).is_equal(Palette.CANVAS_BG)
	assert_that(GridStyle.minor_color(1000.0)).is_equal(Palette.GRID_MINOR)


func test_line_kind() -> void:
	assert_int(GridStyle.line_kind(0)).is_equal(GridStyle.LineKind.AXIS)
	assert_int(GridStyle.line_kind(GridStyle.MAJOR_EVERY)).is_equal(GridStyle.LineKind.MAJOR)
	assert_int(GridStyle.line_kind(-GridStyle.MAJOR_EVERY * 3)).is_equal(GridStyle.LineKind.MAJOR)
	assert_int(GridStyle.line_kind(3)).is_equal(GridStyle.LineKind.MINOR)
	assert_int(GridStyle.line_kind(-5)).is_equal(GridStyle.LineKind.MINOR)


func test_canvas_colors_are_opaque() -> void:
	# Overlapping wire rectangles (L corners) must not darken: no translucency.
	for color: Color in [
		Palette.WIRE,
		Palette.WIRE_HOVER,
		Palette.WIRE_SELECTED,
		Palette.WIRE_PREVIEW,
		Palette.GRID_MINOR,
		Palette.GRID_MAJOR,
		Palette.GRID_AXIS,
		Palette.CANVAS_BG,
	]:
		assert_float(color.a).is_equal(1.0)
