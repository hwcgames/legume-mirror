extends AnimationRules
class_name AnimationRulesDefault

func animation_for(actor: Actor) -> String:
	if is_instance_valid(actor.hp_component) and actor.hp <= 0:
		return "dead"
	if not actor.is_on_floor():
		if actor.velocity.y > 0:
			return "jump"
		else:
			return "fall"
	if actor.velocity.length() > 0.02:
		return "walk"
	return "idle"
