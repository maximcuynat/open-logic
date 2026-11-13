extends GdUnitTestSuite


func test_snap_rounds_to_nearest_cell() -> void:
	assert_that(Grid.snap(Vector2(0, 0))).is_equal(Vector2i(0, 0))
	assert_that(Grid.snap(Vector2(7.9, 8.1))).is_equal(Vector2i(0, 1))
	assert_that(Grid.snap(Vector2(Grid.CELL_SIZE * 3, Grid.CELL_SIZE * -2))).is_equal(
		Vector2i(3, -2)
	)


func test_snap_handles_negative_coordinates() -> void:
	assert_that(Grid.snap(Vector2(-7.9, -8.1))).is_equal(Vector2i(0, -1))
	assert_that(Grid.snap(Vector2(-24.1, 0))).is_equal(Vector2i(-2, 0))


func test_to_world_is_inverse_of_snap_on_cell_centres() -> void:
	for cell: Vector2i in [Vector2i(0, 0), Vector2i(5, -3), Vector2i(-12, 40)]:
		assert_that(Grid.snap(Grid.to_world(cell))).is_equal(cell)


func test_to_cell_space_keeps_fractional_part() -> void:
	assert_that(Grid.to_cell_space(Vector2(Grid.CELL_SIZE * 1.5, 0))).is_equal(Vector2(1.5, 0))
