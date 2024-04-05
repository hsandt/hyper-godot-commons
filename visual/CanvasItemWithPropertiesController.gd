class_name CanvasItemWithPropertiesController
extends CanvasItem
## This script allows us to set shader parameters "brightness" and native modulate
## on the animated sprite material, which should use the shader custom_sprite_shader.gdshader.
## Each entity should have its own material instance, see shader_material doc comment for more
## details.


## When true, update material brightness to match state variable every frame
## When false, reset brightness
## You can set this to true via code of animation
@export var override_brightness: bool

## When override_brightness is true, this is used to update the shader material
## brightness parameter
## You can set this to true via code of animation
@export var target_brightness: float

## When true, update modulate to match state variable every frame
## When false, reset modulate
## You can set this to true via code of animation
@export var override_modulate: bool

## When override_modulate is true, this is used to update the shader material
## modulate
## You can set this to true via code of animation
@export var target_modulate: Color

## Timer used to change brightness for a given duration
var properties_override_timer: Timer


# Initial state

var initial_brightness: float
var initial_modulate: Color


# Current state

## Flag that tracks whether override_brightness was true last frame
## to detect when it becomes false, so we can reset properties to reach a clean state
var was_overriding_brightness: bool

## Flag that tracks whether override_modulate was true last frame
## to detect when it becomes false, so we can reset properties to reach a clean state
var was_overriding_modulate: bool


## Shader Material
## Each entity should have its own material instance
## If you share the same material via scene inheritance or resource reference,
## make sure to check Material > Resource > Local to Scene so it auto-generates
## unique instances (even at edit time)
@onready var shader_material = material as ShaderMaterial


func _ready():
	initialize()
	setup()


func initialize():
	properties_override_timer = Timer.new()
	properties_override_timer.one_shot = true
	properties_override_timer.timeout.connect(_on_properties_override_timer_timeout)
	add_child(properties_override_timer)

	if shader_material:
		initial_brightness = shader_material.get_shader_parameter("brightness")
		initial_modulate = modulate

func setup():
	override_brightness = false
	target_brightness = 0.0
	was_overriding_brightness = false

	override_modulate = false
	target_modulate = Color.WHITE
	was_overriding_modulate = false

	# On first frame and after restart, was_overriding_brightness/modulate is false
	# so _process will not clear brightness/modulate, so do clear it now
	if shader_material:
		shader_material.set_shader_parameter("brightness", initial_brightness)
		modulate = initial_modulate


func _process(_delta):
	if override_brightness:
		if shader_material:
			shader_material.set_shader_parameter("brightness", target_brightness)
	elif was_overriding_brightness:
		if shader_material:
			# Revert to initial value for consistency with setup
			shader_material.set_shader_parameter("brightness", initial_brightness)

	was_overriding_brightness = override_brightness

	if override_modulate:
		if shader_material:
			modulate = target_modulate
	elif was_overriding_modulate:
		if shader_material:
			# Revert to initial value for consistency with setup
			modulate = initial_modulate

	was_overriding_modulate = override_modulate


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
	properties_override_timer.start(duration)


func _on_properties_override_timer_timeout():
	stop_override_brightness()
	stop_override_modulate()
