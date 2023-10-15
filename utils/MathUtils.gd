class_name MathUtils
## Util static functions for math & geometry


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
			return Vector2i(-1, 0)
		MathEnums.CardinalDirection.RIGHT:
			return Vector2i(1, 0)
		MathEnums.CardinalDirection.UP:
			return Vector2i(0, -1)
		MathEnums.CardinalDirection.DOWN:
			return Vector2i(0, 1)
		_:
			push_error("[MathUtils] cardinal_direction_to_unit_vector2i: invalid cardinal_direction %d" %
				cardinal_direction)
			return Vector2i.ZERO


## Return dominant cardinal direction of vector2i
## (applying cardinal_direction_to_unit_vector2i to this value would return
## the unit Vector2i whose angle with vector2i is minimal)
## UB unless vector2i is not ZERO
## If vector2i's components have same absolute value (angle with cardinal direction
## of 45 degrees), select horizontal direction if flag prioritize_horizontal
## is true, vertical direction else
static func vector2i_to_dominant_cardinal_direction(vector2i: Vector2i, prioritize_horizontal: bool = true):
	# Godot provides min/max_axis_index => AXIS_X/Y which we could use
	# to avoid comparing abs_x and abs_y ourselves, unfortunately they
	# assume prioritize_horizontal=true for for full flexibility it's better
	# to check for equality case ourselves
	var abs_x = abs(vector2i.x)
	var abs_y = abs(vector2i.y)
	if abs_x > abs_y or (abs_x == abs_y and prioritize_horizontal):
		return MathEnums.CardinalDirection.LEFT if vector2i.x < 0 else MathEnums.CardinalDirection.RIGHT
	else:
		return MathEnums.CardinalDirection.UP if vector2i.y < 0 else MathEnums.CardinalDirection.DOWN
