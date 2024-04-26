class_name OneShotFX
extends Node2D
## Script to place on a one-shot FX represented by an AnimatedSprite2D
##
## It supports both direct AnimatedSprite2D play and AnimationPlayer
## (e.g. to support Call Method Track). If both are assigned,
## AnimationPlayer will be used.
##
## The node will be freed after the animated sprite finished its animation
##
## Setup:
## 1. Prepare a non-looping default animation in AnimatedSprite2D SpriteFrames
##    Name doesn't matter in sub-cases a. below, but in sub-cases b., it must be &"default"
## 2. To play the animation, use the usual method:
##   A. with AnimatedSprite2D alone
##     a. set your default animation to Autoplay on Load in the SpriteFrames pane
##     b. or call play() (it will call AnimatedSprite2D.play(&"default"))
##   B. with AnimationPlayer controlling AnimatedSprite2D
##     a. set your default animation to Autoplay on Load in the Animation pane
##     b. or call play() (it will call AnimationPlayer.play(&"default"))


## Signal emitted when animated_sprite animation has finished
signal animation_finished


## (Optional) Animation player to monitor for end of animation
@export var animation_player: AnimationPlayer

## Animated sprite of which we monitor the end of animation
## If the FX is compounded of multiple animated sprites, pick the longest one
@export var animated_sprite: AnimatedSprite2D


func _ready():
	if animation_player:
		if animation_player.autoplay:
			assert(animation_player.get_animation(animation_player.autoplay).loop_mode == Animation.LOOP_NONE,
				"[OneShotFX] Expected autoplay animation '%s' on animation player '%s' not to loop" % [
					animation_player.autoplay,
					animation_player.get_path()
					])
		else:
			assert(animation_player.get_animation(&"default").loop_mode == Animation.LOOP_NONE,
				"[OneShotFX] Since not using autoplay, expected animation &'default' on animation player '%s' not to loop" %
					animation_player.get_path())

		animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	else:
		if animated_sprite:
			if animated_sprite.autoplay:
				assert(not animated_sprite.sprite_frames.get_animation_loop(animated_sprite.autoplay),
					"[OneShotFX] Expected autoplay animation '%s' on animated sprite frames '%s' not to loop" % [
						animated_sprite.autoplay,
						animated_sprite.sprite_frames.get_path()
						])
			else:
				assert(not animated_sprite.sprite_frames.get_animation_loop(&"default"),
					"[OneShotFX] Since not using autoplay, expected animation &'default' on animated sprite frames '%s' not to loop" %
						animated_sprite.sprite_frames.get_path())

			animated_sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
		else:
			push_error("[OneShotFX] Neither animation_player nor animated_sprite is assigned on '%s'" % get_path())


## Play the last animation (typically the one set in inspector)
## Call this if you are not using autoplay
func play():
	if animation_player:
		animation_player.play(&"default")
	else:
		animated_sprite.play(&"default")


func _on_animation_player_animation_finished(anim_name: StringName):
	animation_finished.emit()
	queue_free()


func _on_animated_sprite_2d_animation_finished():
	animation_finished.emit()
	queue_free()
