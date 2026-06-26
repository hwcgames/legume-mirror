extends Node3D
class_name BattleEnvironment

@export var players: Array[Marker3D] = []
@export var enemies: Array[Marker3D] = []
@export var player: AnimationPlayer

func animate_in():
	player.play("in")
	while player.current_animation == "in":
		await get_tree().process_frame
	player.play("loop")
