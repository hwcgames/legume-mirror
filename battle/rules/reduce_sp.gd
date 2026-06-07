extends BattleRule
class_name RuleReduceSpGain

@export var sp_gain_mul_per_stack: float = 0.8

func top(fighter: Actor) -> bool:
	stacks -= 1
	return true

func get_sp(fighter: Actor, amount: int) -> bool:
	if amount <= 0:
		return true
	fighter.use_sp(amount * (1. - pow(sp_gain_mul_per_stack, stacks)))
	return true

func icon(fighter: Actor) -> Texture2D:
	var sheet: SpriteFrames = preload("uid://dd807705h8yfd")
	return sheet.get_frame_texture("REDUCE_SP", 0)

func message(fighter: Actor) -> String:
	return "SP gain reduced by %.02fx for %s round(s)." % [pow(sp_gain_mul_per_stack, stacks), stacks]
