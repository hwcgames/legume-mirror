extends BattleRule
class_name Strengthen

@export var amount: int = 3

func top(fighter: Fighter) -> bool:
	stacks -= 1
	return true

func compute_attrs(fighter: Fighter, attrs: CombatAttributes) -> bool:
	attrs.strength += amount
	return true

func merge(other: BattleRule):
	self.amount = max(self.amount, other.amount)
	self.stacks += other.stacks

func _added(fighter: Fighter):
	fighter.battlefield.println("%s turn(s) of Strengthen %s." % [stacks, amount])
