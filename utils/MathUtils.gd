class_name MathUtils


## Return a random float in [0; 1)
static func exclusive_randf() -> float:
		# up to 15 decimals under zero, 0.999... is not 1.0 yet
		return min(randf(), 0.999999999999999)


## Return true if passed cardinal direction is horizontal, false if vertical
static func is_cardinal_direction_horizontal(cardinal_direction: MathEnums.CardinalDirection) -> bool:
	# To avoid relying on enum exact order, we do not check cardinal_direction as int % 2
	# and prefer an explicit value check
	return cardinal_direction == MathEnums.CardinalDirection.LEFT or \
		cardinal_direction == MathEnums.CardinalDirection.RIGHT


## Return the cardinal direction corresponding to a non-zero horizontal axis value
static func horizontal_axis_value_to_cardinal_direction(value: float) -> MathEnums.CardinalDirection:
	if value < 0.0:
		return MathEnums.CardinalDirection.LEFT
	elif value > 0.0:
		return MathEnums.CardinalDirection.RIGHT
	else:
		push_error("[MathUtils] horizontal_axis_value_to_cardinal_direction: invalid value 0.0")
		return MathEnums.CardinalDirection.LEFT


## Return the cardinal direction corresponding to a non-zero vertical axis value
static func vertical_axis_value_to_cardinal_direction(value: float) -> MathEnums.CardinalDirection:
	if value < 0.0:
		return MathEnums.CardinalDirection.UP
	elif value > 0.0:
		return MathEnums.CardinalDirection.DOWN
	else:
		push_error("[MathUtils] vertical_axis_value_to_cardinal_direction: invalid value 0.0")
		return MathEnums.CardinalDirection.LEFT


## Return Vector2i corresponding to cardinal direction
static func cardinal_direction_to_vector2i(cardinal_direction: MathEnums.CardinalDirection) -> Vector2i:
	match cardinal_direction:
		MathEnums.CardinalDirection.LEFT:
			return Vector2i(-1, 0)
		MathEnums.CardinalDirection.RIGHT:
			return Vector2i(1, 0)
		MathEnums.CardinalDirection.UP:
			return Vector2i(0, -1)
		MathEnums.CardinalDirection.DOWN:
			return Vector2i(0, 1)
		_:
			push_error("[MathUtils] cardinal_direction_to_vector2i: invalid cardinal_direction %d" %
				cardinal_direction)
			return Vector2i.ZERO
