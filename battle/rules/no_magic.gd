extends BattleRule
class_name RuleNoMagic

func sp_change(fighter: Actor, instance: SpChange) -> bool:
	activated.emit()
	fighter.hp_change(HpChange.new(instance.from, fighter, instance.amount / 2.))
	instance.amount = 0
	return false

func icon(fighter: Actor) -> Texture2D:
	var sheet: SpriteFrames = preload("uid://dd807705h8yfd")
	return sheet.get_frame_texture("NO_MAGIC", 0)

func message(fighter: Actor) -> String:
	return "Can't gain SP.\n...You do heal a little when grazing, though."
