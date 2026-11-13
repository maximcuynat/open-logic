extends GdUnitTestSuite

const C := Grid.CELL_SIZE


func _seg(ax: int, ay: int, bx: int, by: int) -> WireSegment:
	return WireSegment.create(Vector2i(ax, ay), Vector2i(bx, by))


func test_horizontal_segment_extends_half_width_past_both_ends() -> void:
	var rect := WireGeometry.segment_rect(_seg(0, 0, 4, 0), 4.0)
	assert_that(rect.position).is_equal(Vector2(-2, -2))
	assert_that(rect.size).is_equal(Vector2(4 * C + 4, 4))


func test_vertical_segment_extends_half_width_past_both_ends() -> void:
	var rect := WireGeometry.segment_rect(_seg(1, 3, 1, -2), 4.0)
	assert_that(rect.position).is_equal(Vector2(C - 2, -2 * C - 2))
	assert_that(rect.size).is_equal(Vector2(4, 5 * C + 4))


func test_l_corner_is_fully_covered_with_square_outer_edge() -> void:
	# Corner at (4, 0): both rectangles must cover the whole square around it,
	# so the outer corner is a sharp 90 degree angle instead of a notch.
	var h := WireGeometry.segment_rect(_seg(0, 0, 4, 0), 4.0)
	var v := WireGeometry.segment_rect(_seg(4, 0, 4, 3), 4.0)
	var corner := Rect2(Vector2(4 * C - 2, -2), Vector2(4, 4))
	assert_bool(h.encloses(corner)).is_true()
	assert_bool(v.encloses(corner)).is_true()
	assert_float(h.end.x).is_equal(v.end.x)
	assert_float(h.position.y).is_equal(v.position.y)
