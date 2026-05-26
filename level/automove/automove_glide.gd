extends Automove
class_name AutomoveGlide

@export var glide_speed: float = 3.

func apply_to_actor(actor: Actor):
	actor.glide_to(global_position)
