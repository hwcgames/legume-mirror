extends Automove
class_name AutomoveBreadcrumb

@export var speed_mul: float = 1.

#func (actor: Actor) -> ActorMode:
	#var mode = ActorModePathfind.new()
	#mode.pathfind_target = global_position
	#mode.do_rotate = false
	##mode.goal_rotation = global_rotation.y
	#return mode

func apply_to_actor(actor: Actor):
	#actor.pathing_target = global_position
	#actor.mode = Actor.MODE.PATHING
	actor.pathfind_to(global_position, INF, speed_mul)
