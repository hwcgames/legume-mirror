extends Node3D
class_name Costume

@onready var tree: AnimationTree = %AnimationTree
@onready var player: AnimationPlayer = %AnimationPlayer
@onready var state: AnimationNodeStateMachinePlayback = tree.get("parameters/playback")
@export var head: Marker3D

func play(name: StringName, wait_for_arrival: bool = false, wait_for_completion: bool = false):
	if (tree.tree_root as AnimationNodeStateMachine).get_node(name) == null:
		return
	state.travel(name)
	if wait_for_arrival and state.get_current_node() != name:
		while (await state.state_started) != name:
			pass
	if wait_for_completion and state.get_current_node() == name:
		while (await state.state_finished) != name:
			pass
