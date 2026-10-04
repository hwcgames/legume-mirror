extends ActorComponent
class_name ActorAutomove

var current: Automove

func _activate():
	while active:
		if !is_instance_valid(current):
			actor.mode_done()
			return
		current.apply_to_actor(actor)
		#if actor.active_component != self:
			#actor.active_component._active(1./Engine.physics_ticks_per_second)
		if is_instance_valid(current.next_automove):
			current = current.next_automove
			continue
		while current.next_seam_key != "" and !(is_instance_valid(current.next_seam) and is_instance_valid(current.next_seam.partner)):
			await get_tree().physics_frame
		if !is_instance_valid(current):
			actor.mode_done()
			return
		if is_instance_valid(current.next_seam) \
			and is_instance_valid(current.next_seam.partner) \
			and is_instance_valid(current.next_seam.partner.automoves.get(current.next_seam_key)):
			current = current.next_seam.partner.automoves.get(current.next_seam_key)
		else:
			current = null
		var _a = 1
func _active(delta: float):
	pass
func _reset_velocity() -> bool:
	return false
