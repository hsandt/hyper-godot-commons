class_name TimerUtils
## Util static functions for Timer nodes


## Create a one-shot physics timer with given duration and optional callback
## under given parent (often passing self), and return it
static func create_one_shot_physics_timer_under(parent: Node, duration: float,
		callback: Callable = Callable()) -> Timer:
	var timer := Timer.new()
	timer.one_shot = true
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	timer.wait_time = duration

	# Callable is not nullable, so default is empty Callable() and check uses `is_valid`
	if callback.is_valid():
		timer.timeout.connect(callback)

	parent.add_child(timer)
	return timer
