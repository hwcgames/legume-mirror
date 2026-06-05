extends BattleRule
class_name RuleNoMagic

func get_sp(fighter: Actor, amount: int) -> bool:
	activated.emit()
	fighter.sp = 0
	return false

func message(fighter: Actor) -> String:
	return "You can't use magic."
