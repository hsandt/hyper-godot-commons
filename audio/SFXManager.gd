class_name SFXManager
extends Node
## A manager class to spawn one-shot or looping SFX
##
## Usage:
## - create scene SFXManager.tscn with one node with this script
##   (the easiest is to copy SFXManagerTemplate.tscn, which has
##   an SFXParent setup as child)
## - customize SFXManager.tscn to project needs, in particular:
##   - One Shot Audio Stream Player Prefab:
##     you may want to replace it with a custom copy/inherited scene of the provided template,
##     see OneShotAudioStreamPlayer.gd documentation
##   - Looping Audio Stream Player Prefab:
##     you may want to replace it with a custom copy/inherited scene of the provided template,
##     see LoopingAudioStreamPlayer.gd documentation
## - instantiate that scene in whichever way you prefer,
##   access it from the script that needs to spawn SFX
##   and call spawn_sfx (for one-shot SFX) or spawn_looping_sfx
##   (the easiest is to instantiate an SFXManager node at edit time
##   in any scene that needs it and flag it with Access as Unique Name,
##   but you can also instantiate the SFXManager at runtime automatically
##   on game start or when you enter a new scene)
## Note: this is not a Singleton because you may need multiple SFXManager
##   for each type of SFX (ingame, menu, etc.), each with a different
##   One Shot / Looping Audio Stream Player Prefab with its own Bus.


## Prefab of OneShotAudioStreamPlayer used to play SFX
@export var one_shot_audio_stream_player_prefab: PackedScene

## Prefab of LoopingAudioStreamPlayer used to play SFX
@export var looping_audio_stream_player_prefab: PackedScene

## Parent to spawn SFX under
@export var sfx_parent: Node


func _ready():
	DebugUtils.assert_member_is_set(self, one_shot_audio_stream_player_prefab, "one_shot_audio_stream_player_prefab")
	DebugUtils.assert_member_is_set(self, looping_audio_stream_player_prefab, "looping_audio_stream_player_prefab")
	DebugUtils.assert_member_is_set(self, sfx_parent, "sfx_parent")


## Spawn SFX by instantiating OneShotAudioStreamPlayer and let it free itself when finished
func spawn_sfx(audio_stream: AudioStream):
	assert(audio_stream != null, "SFXManager.spawn_sfx: expected audio_stream")

	var one_shot_audio_stream_player: OneShotAudioStreamPlayer = NodeUtils.instantiate_under(one_shot_audio_stream_player_prefab, sfx_parent)
	one_shot_audio_stream_player.play_audio_stream(audio_stream)


## Spawn SFX by instantiating OneShotAudioStreamPlayer and return it so caller
## can store reference to it and call stop_and_free on it when needed
func spawn_looping_sfx(audio_stream: AudioStream) -> LoopingAudioStreamPlayer:
	assert(audio_stream != null, "SFXManager.spawn_looping_sfx: expected audio_stream")

	var looping_audio_stream_player: LoopingAudioStreamPlayer = NodeUtils.instantiate_under(looping_audio_stream_player_prefab, sfx_parent)
	looping_audio_stream_player.play_audio_stream(audio_stream)
	return looping_audio_stream_player
