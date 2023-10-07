class_name OneShotAudioStreamPlayer
extends AudioStreamPlayer
## Subclass of AudioStreamPlayer that frees itself when audio stream has finished playing
## Also offers a utility method to play an audio stream


func _ready():
	finished.connect(_on_finished)


func play_audio_stream(audio_stream: AudioStream):
	stream = audio_stream
	play()


func _on_finished():
	queue_free()
