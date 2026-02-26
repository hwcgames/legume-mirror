extends Automove
class_name AutomoveGlide

@export var glide_speed: float = 3.

func mode_for_actor(actor: Actor) -> ActorMode:
	var mode = ActorModeMoveTo.new(actor, self , glide_speed)
	return mode
