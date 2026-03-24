extends Node
## Scene Manager
##
## Dependencies:
## - TransitionScreen singleton (see Usage in TransitionScreen.gd)
##
## Usage:
## - register SceneManager.tscn as autoload singleton scene
##   (it has no parameters to tune so there is no template to copy into project)


## Reload current scene safely at the end of the frame
func reload_current_scene():
	get_tree().reload_current_scene.call_deferred()


## Reload current scene with fade out screen and back in
func reload_current_scene_with_fade_async(fade_out_speed: float = 1.0, fade_in_speed: float = 1.0):
	await TransitionScreen.fade_out_async(fade_out_speed)
	# await should wait for end of frame, so we can safely call get_tree().reload_current_scene here
	get_tree().reload_current_scene()
	await TransitionScreen.fade_in_async(fade_in_speed)


## Change scene safely at the end of the frame
func change_scene(new_scene: PackedScene):
	# No need to defer call since the native change_scene methods already defer current scene node
	# deletion to end of frame
	_change_scene_immediate(new_scene)


## Change scene with fade out screen and back in
func change_scene_with_fade_async(scene: PackedScene,
		fade_out_speed: float = 1.0, fade_in_speed: float = 1.0):
	await TransitionScreen.fade_out_async(fade_out_speed)
	# await should wait for end of frame, so we can safely call _change_scene_immediate here
	_change_scene_immediate(scene)
	await TransitionScreen.fade_in_async(fade_in_speed)


func _change_scene_immediate(scene: PackedScene):
	get_tree().change_scene_to_packed(scene)
