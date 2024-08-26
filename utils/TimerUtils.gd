class_name TimerUtils
## Util static functions for Timer nodes


## Create a periodic physics timer with optional duration and optional callback
## under given parent (often passing self), and return it
## If no duration is passed, a dummy wait_time of 1.0 is assigned, so you must
## make sure to always call timer.start passing a custom duration.
static func create_periodic_physics_timer_under(parent: Node, duration: float = 1.0,
		callback: Callable = Callable()) -> Timer:
	var timer := Timer.new()
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	timer.wait_time = duration

	# Callable is not nullable, so default is empty Callable() and check uses `is_valid`
	if callback.is_valid():
		timer.timeout.connect(callback)

	parent.add_child(timer)
	return timer


## Create a one-shot physics timer with optional duration and optional callback
## under given parent (often passing self), and return it
## If no duration is passed, a dummy wait_time of 1.0 is assigned, so you must
## make sure to always call timer.start passing a custom duration.
static func create_one_shot_physics_timer_under(parent: Node, duration: float = 1.0,
		callback: Callable = Callable()) -> Timer:
	var timer := create_periodic_physics_timer_under(parent, duration, callback)
	timer.one_shot = true
	return timer
