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
##     Note: make sure to reset animation after each preview to play from start
##     b. or call play_from_start() (it will call AnimatedSprite2D.play(&"default"))
##   B. with AnimationPlayer controlling AnimatedSprite2D
##     a. set your default animation to Autoplay on Load in the Animation pane
##     Note: make sure to check Reset on Save on AnimationPlayer to play from start
##     b. or call play_from_start() (it will call AnimationPlayer.play(&"default"))


## Signal emitted when animated_sprite animation has finished
signal animation_finished


## Animation player to monitor for end of animation
## Either this or animated_sprite must be assigned
@export var animation_player: AnimationPlayer

## Animated sprite of which we monitor the end of animation
## If the FX is compounded of multiple animated sprites, pick the longest one
## Either this or animation_player must be assigned
@export var animated_sprite: AnimatedSprite2D

## If true, play "default" animation from start on start
@export var auto_play_from_start: bool = true


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

	if auto_play_from_start:
		play_from_start()


## Play "default" animation from start
## Call this if you are not using autoplay
func play_from_start():
	stop()
	play()


## Play "default" animation
func play():
	if animation_player:
		animation_player.play(&"default")
	else:
		animated_sprite.play(&"default")


## Stop the current animation
func stop():
	if animation_player:
		animation_player.stop()
	else:
		animated_sprite.stop()


func _on_animation_player_animation_finished(anim_name: StringName):
	notify_animation_finished_and_queue_free()


func _on_animated_sprite_2d_animation_finished():
	notify_animation_finished_and_queue_free()


func notify_animation_finished_and_queue_free():
	animation_finished.emit()
	queue_free()
