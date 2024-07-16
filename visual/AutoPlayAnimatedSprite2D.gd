extends AnimatedSprite2D
## This class makes sure that the AnimatedSprite2D will play the animation
## set in inspector start, as Godot will auto-play


func _ready():
	stop()
	play()
