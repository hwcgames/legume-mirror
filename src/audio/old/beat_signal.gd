extends AudioStreamPlayer

var old_playhead: float = 0.

signal beat
signal bar

func _process(_delta: float):
	var new_playhead = get_playback_position() + AudioServer.get_time_since_last_mix()
	var old_beat = floor(old_playhead * 60. / stream._get_bpm())
	var new_beat = floor(new_playhead * 60. / stream._get_bpm())
	if new_beat <= old_beat:
		return
	beat.emit()
	if fmod(new_beat, stream._get_bar_beats()) != 0:
		return
	bar.emit()
