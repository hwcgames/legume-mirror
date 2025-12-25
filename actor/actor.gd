extends CharacterBody3D
class_name Actor

@export var human_name: StringName = name
@export var costume: Costume:
	set(new_costume):
		if costume != null:
			costume.hide()
			costume.queue_free()
		costume = new_costume
		add_child(new_costume)

@onready var navigation: NavigationAgent3D = %NavigationAgent3D

var mode_stack: Array[ActorMode] = []:
	get:
		if mode_stack.is_empty():
			mode_stack.push_back(ActorIdle.new())
		mode_stack[-1].actor = self
		return mode_stack

func _physics_process(delta: float):
	velocity = Vector3.ZERO
	if not mode_stack[-1].finishing:
		if mode_stack[-1].finished:
			while mode_stack[-1].finished:
				mode_stack[-1].finishing = true
				await pop_mode()
		mode_stack[-1]._process(delta)
	move_and_slide()

func push_mode(mode: ActorMode) -> ActorMode:
	await mode_stack[-1]._covered()
	mode.actor = self
	mode_stack.push_back(mode)
	await mode._activate()
	return mode

func pop_mode() -> ActorMode:
	var mode = mode_stack[-1]
	await mode._deactivate()
	mode_stack.pop_back()
	mode.popped.emit()
	await mode_stack[-1]._uncovered()
	return mode

func play(name: StringName, wait_for_arrival: bool = false, wait_for_completion: bool = false):
	await costume.play(name, wait_for_arrival, wait_for_completion)
