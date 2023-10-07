extends GutTest

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

func test_cardinal_direction_to_vector2i_assert_left_gives_vector_left():
	assert_eq(MathUtils.cardinal_direction_to_vector2i(MathEnums.CardinalDirection.LEFT), Vector2i.LEFT)

func test_cardinal_direction_to_vector2i_assert_right_gives_vector_right():
	assert_eq(MathUtils.cardinal_direction_to_vector2i(MathEnums.CardinalDirection.RIGHT), Vector2i.RIGHT)

func test_cardinal_direction_to_vector2i_assert_up_gives_vector_up():
	assert_eq(MathUtils.cardinal_direction_to_vector2i(MathEnums.CardinalDirection.UP), Vector2i.UP)

func test_cardinal_direction_to_vector2i_assert_down_gives_vector_down():
	assert_eq(MathUtils.cardinal_direction_to_vector2i(MathEnums.CardinalDirection.DOWN), Vector2i.DOWN)

