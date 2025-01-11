class_name ShaderParameterController
extends Node
## This script can modify the material shader parameters, as well as native modulate,
## on a list of assigned canvas items (or their parents), at runtime.
## Each canvas item should use material with a shader that supports the controlled parameters.
## Each entity should have its own material instance (Make Unique to distinguish from other scene
## nodes, Local to Scene to distinguish from other scene instances including after scene reload),
## see shader_material member doc comment
## for more details.
##
## Currently, the only supported shader parameter is "brightness" and is modified via hardcoded
## methods. Later, this may be replaced with a generic dictionary that supports any parameter
## name (but we'll lose support for animations of exported vars)


## List of parent Node2D under which to recursively search canvas item children
## to change shader parameters
## Consider checking Use Parent Material on each item instead (along the hierarchy
## if using recursive children), and then adding just the common parent to canvas_items
## so the script only changes this shared material, instead of changing every individual
## material instance, for less work
@export var canvas_item_parents: Array[Node2D]

## List of canvas items to change shader parameters of
## Note: Each entity should have its own Shader Material instance
## If you share the same material via scene inheritance or resource reference,
## make sure to check Material > Resource > Local to Scene so it auto-generates
## unique instances (even at edit time)
## Note 2: they will be added besides canvas_item_parents' canvas item children
## (and they shouldn't contain duplicates)
@export var canvas_items: Array[CanvasItem]

## Initial brightness to set
@export var initial_brightness: float = 0.0

## When true, update material brightness to match state variable every frame
## When false, reset brightness
## You can set this to true via code or animation
@export var override_brightness: bool

## When override_brightness is true, this is used to update the shader material
## brightness parameter
## You can set this to true via code or animation
@export var target_brightness: float

## Initial modulate to set
@export var initial_modulate: Color = Color.WHITE

## When true, update modulate to match state variable every frame
## When false, reset modulate
## You can set this to true via code or animation
@export var override_modulate: bool

## When override_modulate is true, this is used to update the shader material
## modulate
## You can set this to true via code or animation
@export var target_modulate: Color

## Timer used to change shader parameters for a given duration
var shader_parameter_override_timer: Timer


# Current state

## Flag that tracks whether override_brightness was true last frame
## to detect when it becomes false, so we can reset properties to reach a clean state
var was_overriding_brightness: bool

## Flag that tracks whether override_modulate was true last frame
## to detect when it becomes false, so we can reset properties to reach a clean state
var was_overriding_modulate: bool


## Cached list of canvas items to control
var cached_canvas_items: Array[CanvasItem]


func _ready():
	initialize()
	setup()


func initialize():
	for canvas_item_parent in canvas_item_parents:
		var canvas_item_recursive_children := canvas_item_parent.find_children("*", "CanvasItem")
		for canvas_item_recursive_child in canvas_item_recursive_children:
			register_canvas_item(canvas_item_recursive_child)

	for canvas_item in canvas_items:
		register_canvas_item(canvas_item)

	# Create and initialize the override timer
	shader_parameter_override_timer = Timer.new()
	shader_parameter_override_timer.one_shot = true
	shader_parameter_override_timer.timeout.connect(_on_shader_parameter_override_timer_timeout)
	add_child(shader_parameter_override_timer)


func register_canvas_item(canvas_item: CanvasItem):
	if canvas_item not in cached_canvas_items:
		cached_canvas_items.append(canvas_item)
	else:
		push_error("[ShaderParameterController] register_canvas_item: canvas_item '%s' is already in cached_canvas_items, " %
			canvas_item.get_path(),
			"please verify that canvas_items doesn't contain a recursive child of an element of canvas_item_parents")


func setup():
	override_brightness = false
	target_brightness = 0.0
	was_overriding_brightness = false

	override_modulate = false
	target_modulate = Color.WHITE
	was_overriding_modulate = false

	# On first frame and after restart, was_overriding_brightness/modulate is false
	# so _process will not clear brightness/modulate, so do clear it now
	# Note that this also avoids issues of brightness not being reset after scene reload
	# during brightness change, even if Material Local to Scene is not checked
	# (but it is recommended to check it anyway)
	set_shader_brightness_on_all_canvas_items(initial_brightness)
	set_modulate_on_all_canvas_items(initial_modulate)


func _process(_delta):
	if override_brightness:
		set_shader_brightness_on_all_canvas_items(target_brightness)
	elif was_overriding_brightness:
		# Revert to initial value for consistency with setup
		set_shader_brightness_on_all_canvas_items(initial_brightness)

	was_overriding_brightness = override_brightness

	if override_modulate:
		set_modulate_on_all_canvas_items(target_modulate)
	elif was_overriding_modulate:
		# Revert to initial value for consistency with setup
		set_modulate_on_all_canvas_items(initial_modulate)

	was_overriding_modulate = override_modulate


func set_shader_brightness_on_all_canvas_items(new_brightness: float):
	for cached_canvas_item in cached_canvas_items:
		var shader_material := cached_canvas_item.material as ShaderMaterial
		if shader_material:
			shader_material.set_shader_parameter("brightness", new_brightness)
		else:
			push_error("[ShaderParameterController] set_shader_brightness_on_all_canvas_items: canvas item '%s' has no ShaderMaterial assigned, " %
					cached_canvas_item.get_path(),
				"skipping it.")


func set_modulate_on_all_canvas_items(new_modulate: Color):
	for cached_canvas_item in cached_canvas_items:
		cached_canvas_item.modulate = new_modulate


## Enable brightness override and set target brightness
func start_override_brightness(brightness: float):
	override_brightness = true
	target_brightness = brightness


## Disable brightness override and clear target brightness (for cleanup)
func stop_override_brightness():
	override_brightness = false
	target_brightness = 0.0


## Enable modulate override and set target modulate
func start_override_modulate(new_target_modulate: Color):
	override_modulate = true
	target_modulate = new_target_modulate


## Disable modulate override and clear target modulate (for cleanup)
func stop_override_modulate():
	override_modulate = false
	target_modulate = Color.WHITE


## Enable properties override and set target properties for passed duration
## If no duration is passed, use properties override timer default duration
func override_properties_for_duration(brightness: float, new_target_modulate: Color,
		duration: float = -1):
	start_override_brightness(brightness)
	start_override_modulate(new_target_modulate)
	shader_parameter_override_timer.start(duration)


func _on_shader_parameter_override_timer_timeout():
	stop_override_brightness()
	stop_override_modulate()
