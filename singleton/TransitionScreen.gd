extends CanvasLayer
## Transition Screen singleton
##
## Usage:
## - create scene TransitionScreen.tscn and register it as autoload singleton scene
##   (the easiest is to copy TransitionScreenTemplate.tscn as TransitionTemplate.tscn
##   in some game project folder, and also re-save the associated animation library
##   as some custom resource to avoid resource sharing:
##   AnimationPlayer > Animation tab > Animation top button > Manage Animations... >
##   Storage > transition_screen_template_animation_library.tres > Save button >
##   Save As > transition_screen_animation_library.tres in the same game project folder)
##
## If you use a custom TransitionScreen, add an AnimationPlayer to it with RESET,
## fade_in and fade_out animations.
## We recommend that RESET state corresponds to fade_in end and fade_out start,
## i.e. the state where the screen fade is not visible at all.


@export var animation_player: AnimationPlayer


func _ready():
	visible = false


### Fade in screen
### This should not be called during another fade in/out
func _play_fade_in(animation_speed: float = 1.0):
	if not animation_player.current_animation.is_empty():
		push_warning("[TransitionScreen] fade_in: animation '%s' " %
			animation_player.current_animation,
			"is already playing. We will still play 'fade_in', but previous ",
			"async calls may be delayed as they are waiting for animation end.")

	animation_player.play(&"fade_in", -1, animation_speed)


### Fade out screen
### This should not be called during another fade in/out
func _play_fade_out(animation_speed: float = 1.0):
	if not animation_player.current_animation.is_empty():
		push_warning("[TransitionScreen] fade_out: animation '%s' " %
			animation_player.current_animation,
			"is already playing. We will still play 'fade_out', but previous ",
			"async calls may be delayed as they are waiting for animation end.")

	animation_player.play(&"fade_out", -1, animation_speed)


### Fade in screen and await for animation end
### This should not be called during another fade in/out
func fade_in_async(animation_speed: float = 1.0):
	visible = true

	_play_fade_in(animation_speed)

	# At this point, we know that the 'fade_in' animation is being played,
	# and the user should not try to play another animation to interrupt this one,
	# so we can just await animation_finished signal instead of doing a full check
	# with an animation_finished callback + check animation name => emit custom finish signal.
	# This allows the user to await this method directly instead of awaiting a custom signal.
	await animation_player.animation_finished

	visible = false


### Fade out screen and await for animation end
### This should not be called during another fade in/out
func fade_out_async(animation_speed: float = 1.0):
	visible = true

	_play_fade_out(animation_speed)

	# If using the TransitionScreen template or configuring the custom TransitionScreen
	# so that RESET state corresponds to fade_in end and fade_out start,
	# i.e. the state where the screen fade is not visible at all, as recommended,
	# fade out should start perfectly the first time.
	# Otherwise, it may glitch one frame showing the fully hidden state (typically a black screen)
	# due to animation rendering lag, and in this case we need the `advance(0)` hack for safety.
	animation_player.advance(0)

	# Same remark as fade_in_async
	await animation_player.animation_finished
