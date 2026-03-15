extends Node
## Music Manager singleton
##
## Usage:
## - create scene MusicManager.tscn and register it as autoload singleton scene
##   (the easiest is to copy MusicManagerTemplate.tscn as MusicManager.tscn
##   in some game project folder)
## - in MusicManager.tscn scene, set AudioStreamPlayer_BGM Bus to the audio bus you use for music


## AudioStreamPlayer responsible for playing music
@export var music_stream_player: AudioStreamPlayer

## Default duration of music fade out (s)
@export var default_fade_out_duration: float = 1.0

## True when music is muted
var is_music_muted: bool = false


func _ready():
	DebugUtils.assert_member_is_set(self, music_stream_player, "music_stream_player")


func play_music(music_stream: AudioStream, force_restart_if_same: bool = false):
	if not music_stream:
		push_error("music_stream is null")
		return

	if not music_stream_player.playing \
			or music_stream_player.stream != music_stream \
			or force_restart_if_same:
		music_stream_player.stream = music_stream
		# Make sure to restore volume in case we called fade_out before
		music_stream_player.volume_linear = 1.0
		music_stream_player.play()


func stop_music():
	music_stream_player.stop()


func fade_out(duration: float = default_fade_out_duration) -> Tween:
	var tween := create_tween()
	tween.tween_property(music_stream_player, ^"volume_linear", 0.0, duration)
	tween.tween_callback(music_stream_player.stop)
	return tween


func toggle_music():
	var music_bus_index := AudioServer.get_bus_index(music_stream_player.bus)
	var new_linear_volume := 1.0 if is_music_muted else 0.0
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(new_linear_volume))
	is_music_muted = !is_music_muted
