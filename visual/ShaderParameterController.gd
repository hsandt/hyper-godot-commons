class_name ShaderParameterController
extends Node
## This script can modify the material shader parameters, as well as native modulate,
## on a list of assigned canvas items, at runtime.
## Each canvas item should use material with a shader that supports the controlled parameters.
## Each entity should have its own material instance, see shader_material member doc comment
## for more details.
##
## Currently, the only supported shader parameter is "brightness" and is modified via hardcoded
## methods. Later, this may be replaced with a generic dictionary that supports any parameter
## name (but we'll lose support for animations of exported vars)


## List of canvas items to change shader parameters of
## Note: Each entity should have its own Shader Material instance
## If you share the same material via scene inheritance or resource reference,
## make sure to check Material > Resource > Local to Scene so it auto-generates
## unique instances (even at edit time)
@export var canvas_items: Array[CanvasItem]

## Initial brightness to set
@export var initial_brightness: float = 0.0

## When true, update material brightness to match state variable every frame
## When false, reset brightness
## You can set this to true via code of animation
@export var override_brightness: bool

## When override_brightness is true, this is used to update the shader material
## brightness parameter
## You can set this to true via code of animation
@export var target_brightness: float

## Initial modulate to set
@export var initial_modulate: Color = Color.WHITE

## When true, update modulate to match state variable every frame
## When false, reset modulate
## You can set this to true via code of animation
@export var override_modulate: bool

## When override_modulate is true, this is used to update the shader material
## modulate
## You can set this to true via code of animation
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


## Cached list of Shader Materials for each controlled canvas items
var cached_shader_materials: Array[ShaderMaterial]


func _ready():
	initialize()
	setup()


func initialize():
	for canvas_item in canvas_items:
		var shader_material := canvas_item.material as ShaderMaterial
		if shader_material:
			cached_shader_materials.append(shader_material)
		else:
			push_error("[ShaderParameterController] initialize: canvas_item '%s' has no ShaderMaterial assigned, " %
					canvas_item.get_path(),
				"skipping it.")

	# Create and initialize the override timer
	shader_parameter_override_timer = Timer.new()
	shader_parameter_override_timer.one_shot = true
	shader_parameter_override_timer.timeout.connect(_on_shader_parameter_override_timer_timeout)
	add_child(shader_parameter_override_timer)


func setup():
	override_brightness = false
	target_brightness = 0.0
	was_overriding_brightness = false

	override_modulate = false
	target_modulate = Color.WHITE
	was_overriding_modulate = false

	# On first frame and after restart, was_overriding_brightness/modulate is false
	# so _process will not clear brightness/modulate, so do clear it now
	set_shader_parameter_on_all_canvas_items(initial_brightness)
	set_modulate_on_all_canvas_items(initial_modulate)


func _process(_delta):
	if override_brightness:
		set_shader_parameter_on_all_canvas_items(target_brightness)
	elif was_overriding_brightness:
		# Revert to initial value for consistency with setup
		set_shader_parameter_on_all_canvas_items(initial_brightness)

	was_overriding_brightness = override_brightness

	if override_modulate:
		set_modulate_on_all_canvas_items(target_modulate)
	elif was_overriding_modulate:
		# Revert to initial value for consistency with setup
		set_modulate_on_all_canvas_items(initial_modulate)

	was_overriding_modulate = override_modulate


func set_shader_parameter_on_all_canvas_items(new_brightness: float):
	for canvas_item in canvas_items:
		var shader_material := canvas_item.material as ShaderMaterial
		shader_material.set_shader_parameter("brightness", target_brightness)


func set_modulate_on_all_canvas_items(new_modulate: Color):
	for canvas_item in canvas_items:
		canvas_item.modulate = new_modulate


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
