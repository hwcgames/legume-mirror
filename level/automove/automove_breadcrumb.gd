extends Automove
class_name AutomoveBreadcrumb

func mode_for_actor(actor: Actor) -> ActorMode:
	var mode = ActorModePathfind.new()
	mode.pathfind_target = global_position
	#mode.goal_rotation = global_rotation.y
	return mode
