extends Node
## Global manager for gameplay music.

const GAMEPLAY_TRACKS: Array[AudioStream] = [
	preload("res://Audio/Music/Gameplay Theme Level 1.wav"),
	preload("res://Audio/Music/Gameplay Theme Level 2.wav"),
	preload("res://Audio/Music/Gameplay Theme Level 3.wav"),
]
## Loop start time in seconds for each track. Zero loops the entire track.
const GAMEPLAY_LOOP_POINTS_SECONDS: Array[float] = [0.0, 0.0, 20.0]

var _music_player: AudioStreamPlayer
var _current_track_index: int = -1
var _pending_track_index: int = -1
var _pending_switch_position: float = 0.0
var _last_playback_position: float = 0.0


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player.bus = &"Music"
	add_child(_music_player)
	play_track(0)


func _process(_delta: float) -> void:
	if _pending_track_index == -1 or not _music_player.playing:
		return

	var playback_position := _music_player.get_playback_position()
	var crossed_switch_position := playback_position >= _pending_switch_position
	var playback_looped := playback_position < _last_playback_position
	if crossed_switch_position or playback_looped:
		_switch_to_track(_pending_track_index)
		return

	_last_playback_position = playback_position


func play_track(track_index: int) -> void:
	if track_index < 0 or track_index >= GAMEPLAY_TRACKS.size():
		push_error("GlobalAudioManager received an invalid gameplay track index: ", track_index)
		return
	
	if track_index == _current_track_index and _pending_track_index == -1 and _music_player.playing:
		return

	if not _music_player.playing:
		_switch_to_track(track_index)
		return

	_pending_track_index = track_index
	var playback_position := _music_player.get_playback_position()
	_pending_switch_position = ceil(playback_position / 2.0) * 2.0
	_last_playback_position = playback_position


func _switch_to_track(track_index: int) -> void:
	_music_player.stop()
	_music_player.stream = _create_looping_track(
		GAMEPLAY_TRACKS[track_index],
		GAMEPLAY_LOOP_POINTS_SECONDS[track_index],
	)
	_music_player.play()
	_current_track_index = track_index
	_pending_track_index = -1
	_pending_switch_position = 0.0
	_last_playback_position = 0.0


func stop_track() -> void:
	_music_player.stop()
	_current_track_index = -1
	_pending_track_index = -1
	_pending_switch_position = 0.0
	_last_playback_position = 0.0


func _create_looping_track(track: AudioStream, loop_point_seconds: float) -> AudioStream:
	var looping_track := track.duplicate() as AudioStreamWAV
	if looping_track == null:
		push_error("GlobalAudioManager requires gameplay tracks to be WAV streams.")
		return track

	var loop_point := clampf(loop_point_seconds, 0.0, looping_track.get_length())
	looping_track.loop_mode = AudioStreamWAV.LOOP_FORWARD
	looping_track.loop_begin = int(loop_point * looping_track.mix_rate)
	looping_track.loop_end = int(looping_track.get_length() * looping_track.mix_rate)
	return looping_track
