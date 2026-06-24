@abstract
extends Resource
class_name BattleRule

@export var stacks: int = 1:
	set(new_stacks):
		stacks = new_stacks
		changed.emit()
signal removed
signal activated

func copy() -> BattleRule:
	return self.duplicate()

func merge(other: BattleRule):
	self.stacks += other.stacks

func priority() -> int:
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

func hp_change(fighter: Actor, instance: HpChange) -> bool:
	return true

func sp_change(fighter: Actor, instance: SpChange) -> bool:
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


func marker_scene(fighter: Actor) -> PackedScene:
	return preload("uid://bj4rgc3br1tr6")
func icon(fighter: Actor) -> Texture2D:
	return preload("uid://bky25goc74wma")
@abstract
func message(fighter: Actor) -> String
func make_marker(fighter: Actor) -> Control:
	var m = marker_scene(fighter).instantiate()
	m.fighter = fighter
	m.rule = self
	#m.amount = stacks
	#m.icon = icon(fighter)
	#m.message = message(fighter)
	#changed.connect(func():
		#m.amount = stacks
		#m.icon = icon(fighter)
		#m.message = message(fighter))
	return m
