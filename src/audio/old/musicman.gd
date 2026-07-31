extends Node

var active_song: Song

func start(song: Song):
	var old_song = active_song
	active_song = song
	add_child(song)
	#if old_song != null:
		#old_song.queue_free()
	return old_song

func stop():
	pass
	#active_song.queue_free()
