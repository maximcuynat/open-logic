extends GdUnitTestSuite


func test_same_point_yields_no_segment() -> void:
	assert_array(WireRouter.route(Vector2i(1, 1), Vector2i(1, 1))).is_empty()


func test_straight_line_yields_one_segment() -> void:
	var segs := WireRouter.route(Vector2i(0, 0), Vector2i(6, 0))
	assert_int(segs.size()).is_equal(1)
	assert_that(segs[0].a).is_equal(Vector2i(0, 0))
	assert_that(segs[0].b).is_equal(Vector2i(6, 0))


func test_l_route_horizontal_first() -> void:
	var segs := WireRouter.route(Vector2i(0, 0), Vector2i(4, 3), true)
	assert_int(segs.size()).is_equal(2)
	assert_bool(segs[0].is_horizontal()).is_true()
	assert_that(segs[0].b).is_equal(Vector2i(4, 0))
	assert_that(segs[1].a).is_equal(Vector2i(4, 0))
	assert_that(segs[1].b).is_equal(Vector2i(4, 3))


func test_l_route_vertical_first() -> void:
	var segs := WireRouter.route(Vector2i(0, 0), Vector2i(4, 3), false)
	assert_int(segs.size()).is_equal(2)
	assert_bool(segs[0].is_horizontal()).is_false()
	assert_that(segs[0].b).is_equal(Vector2i(0, 3))
	assert_that(segs[1].a).is_equal(Vector2i(0, 3))
	assert_that(segs[1].b).is_equal(Vector2i(4, 3))


func test_l_route_with_negative_direction() -> void:
	var segs := WireRouter.route(Vector2i(5, 5), Vector2i(1, 2), true)
	assert_int(segs.size()).is_equal(2)
	assert_that(segs[0].a).is_equal(Vector2i(1, 5))
	assert_that(segs[0].b).is_equal(Vector2i(5, 5))
	assert_that(segs[1].a).is_equal(Vector2i(1, 2))
	assert_that(segs[1].b).is_equal(Vector2i(1, 5))
