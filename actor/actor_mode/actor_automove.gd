extends ActorMode
class_name ActorModeAutomove

var automove: Automove

func _init(automove: Automove):
	self.automove = automove

func _activate():
	if automove == null:
		finished = true
		return
	var mode = automove.mode_for_actor(actor)
	if mode == null:
		_uncovered()
		return
	await actor.push_mode(mode)

func _uncovered():
	var old_automove = automove
	automove = null
	if old_automove.next_automove != null:
		automove = old_automove.next_automove
	if old_automove.next_seam != null:
		var partner = old_automove.next_seam.partner
		if partner != null:
			automove = partner.automoves.get(old_automove.next_seam_key)
	await _activate()
