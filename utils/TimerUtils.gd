class_name TimerUtils
## Util static functions for Timer nodes


## Create a periodic physics timer with optional interval and optional callback
## under given parent (often passing self), and return it
## If no interval is passed, a dummy wait_time of 1.0 is assigned, so you must
## make sure to always call timer.start passing a custom interval.
static func create_periodic_physics_timer_under(parent: Node, interval: float = 1.0,
		callback: Callable = Callable()) -> Timer:
	var timer := Timer.new()
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	timer.wait_time = interval

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


## Create a SceneTreeTimer using physics time, and return its timeout signal (to be awaited)
## We need context_node to call `get_tree()`, but any node will do, so just pass `self`
## (when calling this method from a Node script)
## Usage:
## `await TimerUtils.physics_timeout(self, time_sec)`
static func physics_timeout(context_node: Node, time_sec: float) -> Signal:
	return context_node.get_tree().create_timer(time_sec, false, true).timeout
