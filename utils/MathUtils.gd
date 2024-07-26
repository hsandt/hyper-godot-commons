class_name MathUtils
## Util static functions for math & geometry


## Return Vector2i corresponding to opposite horizontal direction
static func horizontal_direction_to_opposite(horizontal_direction: MathEnums.HorizontalDirection) -> MathEnums.HorizontalDirection:
	match horizontal_direction:
		MathEnums.HorizontalDirection.LEFT:
			return MathEnums.HorizontalDirection.RIGHT
		MathEnums.HorizontalDirection.RIGHT:
			return MathEnums.HorizontalDirection.LEFT
		_:
			push_error("[MathUtils] horizontal_direction_to_opposite: invalid horizontal_direction %d" %
				horizontal_direction)
			return MathEnums.HorizontalDirection.LEFT


## Return integer sign corresponding to horizontal direction X value
static func horizontal_direction_to_sign(horizontal_direction: MathEnums.HorizontalDirection) -> int:
	match horizontal_direction:
		MathEnums.HorizontalDirection.LEFT:
			return -1
		MathEnums.HorizontalDirection.RIGHT:
			return 1
		_:
			push_error("[MathUtils] horizontal_direction_to_sign: invalid horizontal_direction %d" %
				horizontal_direction)
			return 0


## Return Vector2i corresponding to horizontal direction
static func horizontal_direction_to_unit_vector2i(horizontal_direction: MathEnums.HorizontalDirection) -> Vector2i:
	match horizontal_direction:
		MathEnums.HorizontalDirection.LEFT:
			return Vector2i.LEFT
		MathEnums.HorizontalDirection.RIGHT:
			return Vector2i.RIGHT
		_:
			push_error("[MathUtils] horizontal_direction_to_unit_vector2i: invalid horizontal_direction %d" %
				horizontal_direction)
			return Vector2i.ZERO


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
static func cardinal_direction_to_unit_vector2i(cardinal_direction: MathEnums.CardinalDirection) -> Vector2i:
	match cardinal_direction:
		MathEnums.CardinalDirection.LEFT:
			return Vector2i.LEFT
		MathEnums.CardinalDirection.RIGHT:
			return Vector2i.RIGHT
		MathEnums.CardinalDirection.UP:
			return Vector2i.UP
		MathEnums.CardinalDirection.DOWN:
			return Vector2i.DOWN
		_:
			push_error("[MathUtils] cardinal_direction_to_unit_vector2i: invalid cardinal_direction %d" %
				cardinal_direction)
			return Vector2i.ZERO


## Return signed angle from Vector2.RIGHT to unit vector in cardinal_direction
static func cardinal_direction_to_angle(cardinal_direction: MathEnums.CardinalDirection) -> float:
	var unit_vector2 := cardinal_direction_to_unit_vector2i(cardinal_direction) as Vector2
	return unit_vector2.angle()


## Return dominant cardinal direction of passed vector i.e. the direction of the unit
## vector the closest to passed vector
## UB unless vector is not ZERO
## If vector's components have same absolute value (angle with cardinal direction
## of 45 degrees), select horizontal direction if flag prioritize_horizontal
## is true, vertical direction else
static func vector_to_dominant_cardinal_direction(vector: Vector2,
		prioritize_horizontal: bool = true) -> MathEnums.CardinalDirection:
	assert(vector != Vector2.ZERO, "[MathUtils] vector_to_dominant_cardinal_direction: vector is ZERO")

	# Godot provides max_axis_index => AXIS_X/Y which we could use
	# to avoid comparing abs_x and abs_y ourselves, unfortunately they
	# assume prioritize_horizontal=true, so for full flexibility it's better
	# to check for equality case ourselves
	var abs_x := absf(vector.x)
	var abs_y := absf(vector.y)
	if abs_x > abs_y or (abs_x == abs_y and prioritize_horizontal):
		return MathEnums.CardinalDirection.LEFT if vector.x < 0 else MathEnums.CardinalDirection.RIGHT
	else:
		return MathEnums.CardinalDirection.UP if vector.y < 0 else MathEnums.CardinalDirection.DOWN
