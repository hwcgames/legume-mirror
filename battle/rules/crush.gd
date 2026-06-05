extends BattleRule
class_name Crush

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
	attrs.defense -= amount
	return true

func merge(other: BattleRule):
	self.amount = max(self.amount, other.amount)
	self.stacks += other.stacks

func _added(fighter: Actor):
	fighter.battlefield.println("%s round(s) of Crush %s." % [stacks, amount])

func message(fighter: Actor) -> String:
	return "Armor reduced by {amount} (to {defense}) for {stacks} round(s).".format(self ).format(fighter.computed_attrs)
