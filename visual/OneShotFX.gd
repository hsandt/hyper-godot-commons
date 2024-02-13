class_name OneShotFX
extends Node2D
## Script to place on a one-shot FX represented by an AnimatedSprite2D
##
## The node will be freed after the animated sprite finished its animation
## The animated sprite must have either:
## - autoplay set to a non-looping animation
## - no autoplay, but the animation to play set in inspector instead
## In general, a OneShotFX has only one animation named "default"


## Signal emitted when animated_sprite animation has finished
signal animation_finished


## Animated sprite of which we monitor the end of animation
## If the FX is compounded of multiple animated sprites, pick the longest one
@export var animated_sprite: AnimatedSprite2D


func _ready():
	DebugUtils.assert_member_is_set(self, animated_sprite, "animated_sprite")
	animated_sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)


## Play the last animation (typically the one set in inspector)
## Call this if you are not using autoplay
func play():
	animated_sprite.play()


func _on_animated_sprite_2d_animation_finished():
	animation_finished.emit()
	queue_free()
