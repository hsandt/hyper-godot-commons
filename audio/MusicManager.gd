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

## True when music is muted
var is_music_muted: bool = false


func _ready():
	DebugUtils.assert_member_is_set(self, music_stream_player, "music_stream_player")


func play_music(music_stream: AudioStream):
	if not music_stream:
		push_error("music_stream is null")
		return

	music_stream_player.stream = music_stream
	music_stream_player.play()


func toggle_music():
	var music_bus_index := AudioServer.get_bus_index(&"BGM")
	var new_linear_volume := 1.0 if is_music_muted else 0.0
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(new_linear_volume))
	is_music_muted = !is_music_muted
