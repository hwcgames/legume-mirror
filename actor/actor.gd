extends CharacterBody3D
class_name Actor

var mode_stack: Array[ActorMode] = []:
	get:
		if mode_stack.is_empty():
			mode_stack.push_back(ActorIdle.new())
		mode_stack[-1].actor = self
		return mode_stack

func _physics_process(delta: float):
	if not mode_stack[-1].finishing:
		if mode_stack[-1].finished:
			while mode_stack[-1].finished:
				mode_stack[-1].finishing = true
				await pop_mode()
		mode_stack[-1]._process(delta)

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
	await mode_stack[-1]._uncovered()
	mode.popped.emit()
	return mode
