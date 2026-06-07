extends BattleRule
class_name RuleNoMagic

func get_sp(fighter: Actor, amount: int) -> bool:
	activated.emit()
	fighter.sp = 0
	fighter.heal(amount / 2)
	return false

func icon(fighter: Actor) -> Texture2D:
	var sheet: SpriteFrames = preload("uid://dd807705h8yfd")
	return sheet.get_frame_texture("NO_MAGIC", 0)

func message(fighter: Actor) -> String:
	return "Can't gain SP.\n...You do heal a little when grazing, though."
