extends Node
class_name Song

@export var title: String
@export var bpm: int

var music_man: Node

var counters: Dictionary[StringName, int] = {}
var flags: Dictionary[StringName, bool] = {}

func _ready():
	%AudioStreamPlayer.play()
