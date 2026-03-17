extends BattleRule
class_name Bolster

@export var amount: int = 3

func priority(fighter: Fighter) -> int:
	return 1

func top(fighter: Fighter) -> bool:
	stacks -= 1
	return true

func done(fighter: Fighter, player_victory: bool) -> bool:
	stacks = 0
	return true

func compute_attrs(fighter: Fighter, attrs: CombatAttributes) -> bool:
	attrs.defense += amount
	return true

func merge(other: BattleRule):
	self.amount = max(self.amount, other.amount)
	self.stacks += other.stacks

func _added(fighter: Fighter):
	fighter.battlefield.println("%s turn(s) of Bolster %s." % [stacks, amount])
