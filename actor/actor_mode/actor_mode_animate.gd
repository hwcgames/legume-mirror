extends ActorMode
class_name ActorModeAnimate

var animation: StringName = "idle":
	set(new_animation):
		animation = new_animation
		if new_animation != animation:
			await _activate()
var previous_animation: StringName
var return_to_previous: bool

func _init(animation: StringName, return_to_previous: bool = true):
	self.animation = animation
	self.return_to_previous = return_to_previous

func _activate():
	previous_animation = actor.costume.state.get_current_node()
	actor.costume.state.state_finished.connect(func(state_finished):
		if state_finished == animation:
			finished = true)
	await actor.play(animation, true)

func _uncovered():
	if actor.costume.state.get_current_node() != animation:
		await _activate()

func _deactivate():
	if return_to_previous:
		await actor.play(previous_animation, true)
