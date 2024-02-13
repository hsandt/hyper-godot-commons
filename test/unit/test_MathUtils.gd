extends GutTest

func test_horizontal_direction_to_unit_vector2i_assert_left_gives_vector_left():
	assert_eq(MathUtils.horizontal_direction_to_unit_vector2i(MathEnums.HorizontalDirection.LEFT), Vector2i.LEFT)

func test_horizontal_direction_to_unit_vector2i_assert_right_gives_vector_right():
	assert_eq(MathUtils.horizontal_direction_to_unit_vector2i(MathEnums.HorizontalDirection.RIGHT), Vector2i.RIGHT)

func test_is_cardinal_direction_horizontal_assert_left_is_horizontal():
	assert_eq(MathUtils.is_cardinal_direction_horizontal(MathEnums.CardinalDirection.LEFT), true)

func test_is_cardinal_direction_horizontal_assert_right_is_horizontal():
	assert_eq(MathUtils.is_cardinal_direction_horizontal(MathEnums.CardinalDirection.LEFT), true)

func test_is_cardinal_direction_horizontal_assert_up_is_not_horizontal():
	assert_eq(MathUtils.is_cardinal_direction_horizontal(MathEnums.CardinalDirection.UP), false)

func test_is_cardinal_direction_horizontal_assert_down_is_not_horizontal():
	assert_eq(MathUtils.is_cardinal_direction_horizontal(MathEnums.CardinalDirection.DOWN), false)

func test_horizontal_axis_value_to_cardinal_direction_assert_negative_gives_left():
	assert_eq(MathUtils.horizontal_axis_value_to_cardinal_direction(-1.0), MathEnums.CardinalDirection.LEFT)

func test_horizontal_axis_value_to_cardinal_direction_assert_positive_gives_right():
	assert_eq(MathUtils.horizontal_axis_value_to_cardinal_direction(1.0), MathEnums.CardinalDirection.RIGHT)

func test_vertical_axis_value_to_cardinal_direction_assert_negative_gives_up():
	assert_eq(MathUtils.vertical_axis_value_to_cardinal_direction(-1.0), MathEnums.CardinalDirection.UP)

func test_vertical_axis_value_to_cardinal_direction_assert_positive_gives_down():
	assert_eq(MathUtils.vertical_axis_value_to_cardinal_direction(1.0), MathEnums.CardinalDirection.DOWN)

func test_cardinal_direction_to_unit_vector2i_assert_left_gives_vector_left():
	assert_eq(MathUtils.cardinal_direction_to_unit_vector2i(MathEnums.CardinalDirection.LEFT), Vector2i.LEFT)

func test_cardinal_direction_to_unit_vector2i_assert_right_gives_vector_right():
	assert_eq(MathUtils.cardinal_direction_to_unit_vector2i(MathEnums.CardinalDirection.RIGHT), Vector2i.RIGHT)

func test_cardinal_direction_to_unit_vector2i_assert_up_gives_vector_up():
	assert_eq(MathUtils.cardinal_direction_to_unit_vector2i(MathEnums.CardinalDirection.UP), Vector2i.UP)

func test_cardinal_direction_to_unit_vector2i_assert_down_gives_vector_down():
	assert_eq(MathUtils.cardinal_direction_to_unit_vector2i(MathEnums.CardinalDirection.DOWN), Vector2i.DOWN)

func test_cardinal_direction_to_angle_assert_left_gives_pi():
	assert_almost_eq(MathUtils.cardinal_direction_to_angle(MathEnums.CardinalDirection.LEFT), PI, 1e-7)

func test_cardinal_direction_to_angle_assert_right_gives_0():
	assert_eq(MathUtils.cardinal_direction_to_angle(MathEnums.CardinalDirection.RIGHT), 0.0)

func test_cardinal_direction_to_angle_assert_up_gives_vector_minus_pi_on_2():
	assert_almost_eq(MathUtils.cardinal_direction_to_angle(MathEnums.CardinalDirection.UP), - PI / 2.0, 1e-7)

func test_cardinal_direction_to_angle_assert_down_gives_vector_pi_on_2():
	assert_almost_eq(MathUtils.cardinal_direction_to_angle(MathEnums.CardinalDirection.DOWN), PI / 2.0, 1e-7)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_left_gives_left():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i.LEFT), MathEnums.CardinalDirection.LEFT)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_right_gives_right():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i.RIGHT), MathEnums.CardinalDirection.RIGHT)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_up_gives_up():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i.UP), MathEnums.CardinalDirection.UP)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_down_gives_down():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i.DOWN), MathEnums.CardinalDirection.DOWN)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_2left_1up_gives_left():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i(-2, -1)), MathEnums.CardinalDirection.LEFT)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_2left_1down_gives_left():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i(-2, 1)), MathEnums.CardinalDirection.LEFT)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_2right_1up_gives_right():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i(2, -1)), MathEnums.CardinalDirection.RIGHT)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_2right_1down_gives_right():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i(2, 1)), MathEnums.CardinalDirection.RIGHT)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_2up_1left_gives_up():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i(-1, -2)), MathEnums.CardinalDirection.UP)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_2up_1right_gives_up():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i(1, -2)), MathEnums.CardinalDirection.UP)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_2down_1left_gives_down():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i(-1, 2)), MathEnums.CardinalDirection.DOWN)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_2down_1right_gives_down():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i(1, 2)), MathEnums.CardinalDirection.DOWN)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_1left_1up_prioritize_horizontal_gives_left():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i(-1, -1), true), MathEnums.CardinalDirection.LEFT)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_1left_1up_prioritize_vertical_gives_up():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i(-1, -1), false), MathEnums.CardinalDirection.UP)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_1left_1down_prioritize_horizontal_gives_left():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i(-1, 1), true), MathEnums.CardinalDirection.LEFT)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_1left_1down_prioritize_vertical_gives_down():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i(-1, 1), false), MathEnums.CardinalDirection.DOWN)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_1right_1up_prioritize_horizontal_gives_right():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i(1, -1), true), MathEnums.CardinalDirection.RIGHT)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_1right_1up_prioritize_vertical_gives_up():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i(1, -1), false), MathEnums.CardinalDirection.UP)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_1right_1down_prioritize_horizontal_gives_right():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i(1, 1), true), MathEnums.CardinalDirection.RIGHT)

func test_vector2i_to_dominant_cardinal_direction_assert_vector_1right_1down_prioritize_vertical_gives_down():
	assert_eq(MathUtils.vector2i_to_dominant_cardinal_direction(Vector2i(1, 1), false), MathEnums.CardinalDirection.DOWN)
