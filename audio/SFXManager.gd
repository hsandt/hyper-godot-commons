class_name SFXManager
extends Node


## Prefab of OneShotAudioStreamPlayer used to play SFX
@export var one_shot_audio_stream_player_prefab: PackedScene

## Parent to spawn SFX under
@export var sfx_parent: Node


func _ready():
	DebugUtils.assert_member_is_set(self, one_shot_audio_stream_player_prefab, "one_shot_audio_stream_player_prefab")
	DebugUtils.assert_member_is_set(self, sfx_parent, "sfx_parent")


## Spawn SFX by instantiating OneShotAudioStreamPlayer and let it free itself when finished
func spawn_sfx(audio_stream: AudioStream):
	assert(audio_stream != null, "SFXManager.spawn_sfx: expected audio_stream")

	var one_shot_audio_stream_player: OneShotAudioStreamPlayer = NodeUtils.instantiate_under(one_shot_audio_stream_player_prefab, sfx_parent)
	one_shot_audio_stream_player.play_audio_stream(audio_stream)
