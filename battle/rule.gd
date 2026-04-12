@abstract
extends Resource
class_name BattleRule

@export var stacks: int = 1

func merge(other: BattleRule):
	self.stacks += other.stacks

func priority(fighter: Fighter) -> int:
	return 0

func compute_attrs(fighter: Fighter, attrs: CombatAttributes) -> bool:
	return true

func _added(fighter: Fighter):
	pass

func _added_to_soul(soul: Soul):
	pass

func _removed(fighter: Fighter):
	pass

func _died(fighter: Fighter) -> bool:
	return true

func _revived(fighter: Fighter) -> bool:
	return true

func take_damage(fighter: Fighter, amount: int) -> bool:
	return true

func heal(fighter: Fighter, amount: int) -> bool:
	return true

func use_sp(fighter: Fighter, amount: int) -> bool:
	return true

func get_sp(fighter: Fighter, amount: int) -> bool:
	return true

func join_battle(fighter: Fighter) -> bool:
	return true

func begin(fighter: Fighter) -> bool:
	return true

func top(fighter: Fighter) -> bool:
	return true

func telegraph(fighter: Fighter) -> bool:
	return true

func player_action(fighter: Fighter) -> bool:
	return true

func player_plan(player: PartyMember, plan: BattleActionPlan) -> bool:
	return true

func enemy_action(fighter: Fighter) -> bool:
	return true

func setup_battle_board(enemy: Enemy, board: BulletPatternLayer):
	return true

func pick_pattern(enemy: Enemy):
	return true

func done(fighter: Fighter, player_victory: bool) -> bool:
	return true

func soul(player: PartyMember, soul: Soul):
	return true
