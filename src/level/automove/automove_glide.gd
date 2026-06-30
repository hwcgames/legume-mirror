extends Automove
class_name AutomoveGlide

@export var glide_speed: float = 3.
@export var rotate: bool = false

func apply_to_actor(actor: Actor):
	actor.glide_to(self, glide_speed, global_rotation.y if rotate else INF)
