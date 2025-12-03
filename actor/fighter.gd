extends Actor
class_name Fighter

var alive: bool = true

func take_damage(amount: int):
	pass

func heal(amount: int):
	pass

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
