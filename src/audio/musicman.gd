extends AudioStreamPlayer
class_name MusicMan

@export var current_song: TrackSet

func change_song(new_song: TrackSet, profile: StringName = "default", fade: float = 1.):
	var tween = create_tween()
	tween.tween_property(self, "volume_linear", 0., fade);
	tween.play()
	await tween.finished
	stop()
	stream = AudioStreamSynchronized.new()
	stream.stream_count = len(new_song.tracks)
	for i in range(len(new_song.tracks)):
		stream.set_sync_stream(i, new_song.tracks[i])
	volume_linear = 1.
	current_song = new_song
	await change_profile(profile, 0.)
	play()

func change_profile(profile: StringName, fade: float = 1.):
	var tween = create_tween()
	for i in len(current_song.tracks):
		var new_volume = max(-40, linear_to_db(current_song.profiles[profile][i]))
		print(new_volume)
		tween.parallel()
		tween.tween_method(func(v): stream.set_sync_stream_volume(i, v), stream.get_sync_stream_volume(i), new_volume, fade)
	tween.play()
	await tween.finished
