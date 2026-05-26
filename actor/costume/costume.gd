extends Node3D
class_name Costume

@onready var player: AnimationPlayer = %AnimationPlayer
@export var head: Marker3D
@export var rules: AnimationRules

var playing: bool = false
func play(name: StringName):
	player.play(name)
	await player.animation_finished
	#if (tree.tree_root as AnimationNodeStateMachine).get_node(name) == null:
		#return
	#playing = true
	#state.travel(name)
	#if wait_for_arrival and state.get_current_node() != name:
		#while (await state.state_started) != name:
			#pass
	#if wait_for_completion and state.get_current_node() == name:
		#await state.state_finished
	#playing = false
