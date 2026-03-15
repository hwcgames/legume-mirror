extends BattleRule
class_name SlowSoul

@export var speed_mul = 0.5

func _added_to_soul(soul: Soul):
	soul.speed *= speed_mul

func soul(player: PartyMember, soul: Soul):
	soul.speed *= speed_mul

func top(fighter: Fighter) -> bool:
	stacks -= 1
	return true

func merge(other: BattleRule):
	speed_mul = (speed_mul * stacks + other.speed_mul * other.stacks) / (stacks + other.stacks)
	stacks += other.stacks

func _added(fighter: Fighter):
	fighter.battlefield.println("%s turn(s) of %sx soul speed!" % [stacks, speed_mul])
