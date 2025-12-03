extends Actor
class_name Fighter

var alive: bool:
	get:
		return hp > 0
@export var max_hp: int
@export var hp: int
@export var max_sp: int
@export var sp: int
@export var strength: int
@export var magic: int
@export var defense: int
@export var finesse: int

func take_damage(amount: int):
	hp -= amount

func heal(amount: int):
	hp += amount

var battlefield: Battlefield

func join_battle(battle: Battlefield):
	battlefield = battle
	battle.begin.connect(begin)
	battle.top.connect(top)
	battle.telegraph.connect(telegraph)
	battle.player_action.connect(player_action)
	battle.enemy_action.connect(enemy_action)
	_join_battle(battle)

func _join_battle(_battle: Battlefield):
	pass

func begin():
	_begin()

func top():
	_top()

func telegraph():
	_telegraph()

func player_action():
	_player_action()

func enemy_action():
	_enemy_action()

func _begin():
	pass

func _top():
	pass

func _telegraph():
	pass

func _player_action():
	pass

func _enemy_action():
	pass
