extends Control

var song_registry: Registry = preload("uid://cka0s7mj767dq")
var songs = song_registry.get_all_string_ids()

func _ready() -> void:
	%Songs.item_selected.connect(func(idx):
		select_song(songs[idx]))
	%Commit.pressed.connect(commit)
	%Reload.pressed.connect(init_songs)
	init_songs()

func init_songs():
	%Songs.clear()
	for song in songs:
		%Songs.add_item(song)
	%Songs.selected = 0
	select_song(songs[0])

func select_song(song_name: StringName):
	var song = song_registry.load_entry(song_name)
	%Profiles.clear()
	for profile in song.profiles.keys():
		%Profiles.add_item(profile)
	%Profiles.selected = 0

func commit():
	var song_name = songs[%Songs.selected]
	var song: TrackSet = song_registry.load_entry(song_name)
	if %MusicMan.current_song != song:
		await %MusicMan.change_song(song, song.profiles.keys().get(%Profiles.selected), 0.)
	await %MusicMan.change_profile(song.profiles.keys().get(%Profiles.selected), %Fade.value)
