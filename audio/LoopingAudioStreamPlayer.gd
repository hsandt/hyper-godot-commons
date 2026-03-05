class_name LoopingAudioStreamPlayer
extends AudioStreamPlayer
## Subclass of AudioStreamPlayer that provides a public method to stop / fade out
## and free itself at any time
## Also offers a utility method to play an audio stream
## Generally used for looping SFX or BGM tracks played dynamically
##
## Usage:
## - create scene LoopingAudioStreamPlayer.tscn with one node with this script
##   (the easiest is to copy/inherit from scene LoopingAudioStreamPlayerTemplate.tscn)
## - customize LoopingAudioStreamPlayer.tscn, in particular the Bus
##   to match the type of SFX/BGM to play on this instance
## - instantiate that scene at runtime and call play_audio_stream on it
##   (the easiest is to use the provided SFXManager)


func play_audio_stream(audio_stream: AudioStream):
	stream = audio_stream
	play()


func stop_and_free():
	stop()
	queue_free()


func fade_out_and_free(duration: float):
	var tween := create_tween()
	tween.tween_property(self, ^"volume_linear", 0.0, duration)
	tween.tween_callback(queue_free)
