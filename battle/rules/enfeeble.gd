extends BattleRule
class_name Enfeeble

@export var amount: int = 3

func priority(fighter: Actor) -> int:
	return 1

func top(fighter: Actor) -> bool:
	stacks -= 1
	return true

func done(fighter: Actor, player_victory: bool) -> bool:
	stacks = 0
	return true

func compute_attrs(fighter: Actor, attrs: CombatAttributes) -> bool:
	attrs.strength -= amount
	return true

func merge(other: BattleRule):
	self.amount = max(self.amount, other.amount)
	self.stacks += other.stacks

func _added(fighter: Actor):
	fighter.battlefield.println("%s round(s) of Enfeeble %s." % [stacks, amount])

func icon(fighter: Actor) -> Texture2D:
	var sheet: SpriteFrames = preload("uid://dd807705h8yfd")
	return sheet.get_frame_texture("STR-", 0)

func message(fighter: Actor) -> String:
	return "Strength reduced by {amount} (to {strength}) for {stacks} round(s).".format(self ).format(fighter.computed_attrs)
