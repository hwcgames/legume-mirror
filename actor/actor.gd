extends CharacterBody3D
class_name Actor

var mode_stack: Array[ActorMode] = []:
	get:
		if mode_stack.is_empty():
			mode_stack.push_back(ActorIdle.new())
		mode_stack[-1].actor = self
		return mode_stack

func _physics_process(delta: float):
	mode_stack[-1]._process(delta)
	pass
