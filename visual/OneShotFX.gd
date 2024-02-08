class_name OneShotFX
extends Node2D
## Script to place on a one-shot FX represented by an AnimatedSprite2D
##
## The animated sprite must have autoplay set to a non-looping animation
## The node will be freed after the animated sprite finished its animation


## Animated sprite of which we monitor the end of animation
## If the FX is compounded of multiple animated sprites, pick the longest one
@export var animated_sprite: AnimatedSprite2D


func _ready():
	DebugUtils.assert_member_is_set(self, animated_sprite, "animated_sprite")
	animated_sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)


func _on_animated_sprite_2d_animation_finished():
	queue_free()
