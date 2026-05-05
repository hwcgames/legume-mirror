extends BattleRule
class_name SlowSoul

@export var speed_mul = 0.8

func _added_to_soul(soul: Soul):
	soul.speed *= speed_mul

func soul(player: Actor, soul: Soul):
	soul.speed *= speed_mul

func top(fighter: Actor) -> bool:
	stacks -= 1
	return true

func done(fighter: Actor, player_victory: bool) -> bool:
	stacks = 0
	return true

func merge(other: BattleRule):
	speed_mul = (speed_mul * stacks + other.speed_mul * other.stacks) / (stacks + other.stacks)
	stacks += other.stacks

func _added(fighter: Actor):
	fighter.battlefield.println("%s turn(s) of %sx soul speed!" % [stacks, speed_mul])
