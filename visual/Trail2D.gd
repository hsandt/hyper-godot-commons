extends Line2D
## 2D Trail
## It tracks a target and updates its Line2D points accordingly
## For N points, the first N-1 points are "frozen" in space, and the N-th point, as "floating point",
## follows the target
## Every [advance_to_next_floating_point_interval] seconds, the N-th point is frozen and a new, (N+1)-th point
## is created to keep following the target.
## This way, most of the trail remains stable, and only a short segment may move a little before
## being frozen. This is more reactive than waiting [advance_to_next_floating_point_interval] seconds
## without following the target at all and then add a segment to the target's last position
## all of a sudden.
## Since this Node2D is affected by its parent position, make sure not to place it under its own
## target, nor any other moving object.


@export_group("External nodes")

## Target to track
## Can be set in inspector or programmatically
@export var target: Node2D


@export_group("Parameters")

## Interval (s) between freezing of last point
@export var advance_to_next_floating_point_interval: float = 1.0

## Duration after which a given point will be smoothly removed from the trail
## Also the duration after which we will start to continuously move the oldest point
## from the trail, from the first one.
## Smooth removal is done by moving the oldest trail point toward the 2nd oldest point
## until the oldest segment is shrunk to a point, at which point we remove the oldest point.
@export var point_lifespan: float = 1.5


# State

var first_point_lifespan_timer: Timer
var oldest_point_smoothing_timer: Timer
var advance_to_next_floating_point_timer: Timer

## The trail only tracks target and adds new points when this flag is true
## Even when false, existing points will stay until oldest point smoothing
## finishes clearing the old points one by one
var should_track_target: bool

## Position of oldest point before starting its smooth motion, so we have a stable lerp
var oldest_point_smooth_lerp_start_position: Vector2


func _ready():
	# Prepare timer to detect end of lifespan of first point (to start oldest point smoothing)
	first_point_lifespan_timer = TimerUtils.create_one_shot_physics_timer_under(self,
		point_lifespan)

	# Prepare timer to know time left on oldest point smoothing period (to calculate progress ratio)
	# and also remove the oldest point at the end of each smoothing period (when smoothed oldest
	# point reached the next key point)
	# We cannot reuse advance_to_next_floating_point_timer because if point_lifespan is not
	# a multiple of advance_to_next_floating_point_interval, the oldest point smoothing
	# is offset compared to last point smoothing (does not reach a key point on the same frame)
	# Note that we could also store a float time incremented by delta every frame,
	# and subtract point_lifespan then apply modulo advance_to_next_floating_point_interval
	# to replace first_point_lifespan_timer and oldest_point_smoothing_timer,
	# but we'd need to check when oldest_point_smoothing_timer crosses
	# advance_to_next_floating_point_interval to call _remove_oldest_point
	oldest_point_smoothing_timer = TimerUtils.create_periodic_physics_timer_under(self,
		advance_to_next_floating_point_interval, _remove_oldest_point)

	# Prepare timer to periodically freeze the last point and start a new floating point
	advance_to_next_floating_point_timer = TimerUtils.create_periodic_physics_timer_under(self,
		advance_to_next_floating_point_interval, _advance_to_next_floating_point)

	clear_points()

	should_track_target = false


## Start tracking passed target, or previously set target if null is passed
func start_tracking_target(new_target: Node2D = null):
	if new_target != null:
		target = new_target
	elif target == null:
		push_error("[Trail2D] start_tracking_target: target is not set and no new_target has been passed")
		return

	should_track_target = true

	first_point_lifespan_timer.start()
	advance_to_next_floating_point_timer.start()

	# For initialization, prepare 2 points: the first frozen point, and the floating point
	# Since this is exactly the same operation
	_advance_to_next_floating_point()
	_advance_to_next_floating_point()
	oldest_point_smooth_lerp_start_position = points[0]


## Stop tracking target (without clearing target reference, in case we want to reuse it later)
func stop_tracking_target():
	should_track_target = false
	advance_to_next_floating_point_timer.stop()


func _process(delta: float):
	if not points:
		# we haven't started tracking target at all
		# (or we have stopped and let all the old points be removed)
		# so there is nothing to do, neither with old nor last point
		return

	# Start applying smooth motion of oldest point after lifespan has passed,
	# since it applies to the first point
	if first_point_lifespan_timer.is_stopped():
		# The first time we enter this, we must start the oldest point smoothing timer
		# so it can periodically remove points, and also so we can calculate progress ratio
		# of oldest point smoothing from its time left
		if oldest_point_smoothing_timer.is_stopped():
			oldest_point_smoothing_timer.start()

		# Apply smooth motion from oldest to 2nd oldest point, using the stored
		# oldest point position before
		var time_left := oldest_point_smoothing_timer.time_left
		# Note that we use the time *left*, so we must get the complementary
		var progress_ratio := 1.0 - time_left / advance_to_next_floating_point_interval
		set_point_position(0, oldest_point_smooth_lerp_start_position.lerp(points[1], progress_ratio))

	if should_track_target:
		# Apply smooth motion for last (most recent) point, following target immediately
		var n = get_point_count()
		set_point_position(n - 1, _get_relative_target_position())


func _advance_to_next_floating_point():
	# Adding a new point will automatically freeze the previous last one since _process
	# only moves the last point
	add_point(_get_relative_target_position())


## Return target global position, relative to self global position
func _get_relative_target_position():
	# We recommend working with self at the origin, but in case it is offset,
	# we subtract self global position to store point positions
	return target.global_position - global_position


func _remove_oldest_point():
	remove_point(0)

	# Update oldest_point_smooth_lerp_start_position to the next oldest
	# point position
	oldest_point_smooth_lerp_start_position = points[0]
