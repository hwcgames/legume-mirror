@abstract
extends Resource
class_name BattleRule

@export var stacks: int = 1

func copy() -> BattleRule:
	return self.duplicate()

func merge(other: BattleRule):
	self.stacks += other.stacks

func priority(fighter: Actor) -> int:
	return 0

func compute_attrs(fighter: Actor, attrs: CombatAttributes) -> bool:
	return true

func _added(fighter: Actor):
	pass

func _added_to_soul(soul: Soul):
	pass

func _removed(fighter: Actor):
	pass

func _died(fighter: Actor) -> bool:
	return true

func _revived(fighter: Actor) -> bool:
	return true

func take_damage(fighter: Actor, amount: int) -> bool:
	return true

func heal(fighter: Actor, amount: int) -> bool:
	return true

func use_sp(fighter: Actor, amount: int) -> bool:
	return true

func get_sp(fighter: Actor, amount: int) -> bool:
	return true

func join_battle(fighter: Actor) -> bool:
	return true

func begin(fighter: Actor) -> bool:
	return true

func top(fighter: Actor) -> bool:
	return true

func telegraph(fighter: Actor) -> bool:
	return true

func player_action(fighter: Actor) -> bool:
	return true

func player_plan(player: Actor, plan: BattleActionPlan) -> bool:
	return true

func enemy_action(fighter: Actor) -> bool:
	return true

func setup_battle_board(enemy: Actor, board: BulletPatternLayer):
	return true

func pick_pattern(enemy: Actor):
	return true

func done(fighter: Actor, player_victory: bool) -> bool:
	return true

func soul(player: Actor, soul: Soul):
	return true
