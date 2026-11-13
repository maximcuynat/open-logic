extends GdUnitTestSuite


func test_create_rejects_zero_length() -> void:
	assert_object(WireSegment.create(Vector2i(2, 2), Vector2i(2, 2))).is_null()


func test_create_rejects_diagonal() -> void:
	assert_object(WireSegment.create(Vector2i(0, 0), Vector2i(3, 1))).is_null()


func test_create_normalizes_endpoint_order() -> void:
	var seg := WireSegment.create(Vector2i(5, 1), Vector2i(-2, 1))
	assert_that(seg.a).is_equal(Vector2i(-2, 1))
	assert_that(seg.b).is_equal(Vector2i(5, 1))
	var vert := WireSegment.create(Vector2i(0, 9), Vector2i(0, 3))
	assert_that(vert.a).is_equal(Vector2i(0, 3))
	assert_that(vert.b).is_equal(Vector2i(0, 9))


func test_orientation() -> void:
	assert_bool(WireSegment.create(Vector2i(0, 0), Vector2i(4, 0)).is_horizontal()).is_true()
	assert_bool(WireSegment.create(Vector2i(0, 0), Vector2i(0, 4)).is_horizontal()).is_false()


func test_equals_ignores_creation_order() -> void:
	var s1 := WireSegment.create(Vector2i(0, 0), Vector2i(4, 0))
	var s2 := WireSegment.create(Vector2i(4, 0), Vector2i(0, 0))
	var s3 := WireSegment.create(Vector2i(0, 0), Vector2i(5, 0))
	assert_bool(s1.equals(s2)).is_true()
	assert_bool(s1.equals(s3)).is_false()
	assert_bool(s1.equals(null)).is_false()


func test_length() -> void:
	assert_int(WireSegment.create(Vector2i(-3, 2), Vector2i(4, 2)).length()).is_equal(7)


func test_distance_to_point() -> void:
	var seg := WireSegment.create(Vector2i(0, 0), Vector2i(10, 0))
	assert_float(seg.distance_to(Vector2(5, 0))).is_equal_approx(0.0, 0.0001)
	assert_float(seg.distance_to(Vector2(5, 2))).is_equal_approx(2.0, 0.0001)
	# Beyond an endpoint, distance is measured to that endpoint.
	assert_float(seg.distance_to(Vector2(13, 4))).is_equal_approx(5.0, 0.0001)
	assert_float(seg.distance_to(Vector2(-3, -4))).is_equal_approx(5.0, 0.0001)
