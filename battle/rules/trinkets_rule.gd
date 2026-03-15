extends BattleRule
class_name TrinketsRule

@export var trinkets_decay: float = 0.7
@export var field_layer: PackedScene = preload("uid://dhpww5nxtbn2n")
@export var value_per_trinket: int = 5

func top(fighter: Fighter) -> bool:
	(fighter.sp_component as TrinketsPool).trinkets_on_field *= trinkets_decay
	return true

func begin(fighter: Fighter) -> bool:
	(fighter.sp_component as TrinketsPool).trinkets_on_field = 0
	return true

func get_sp(fighter: Fighter, amount: int) -> bool:
	return false

func take_damage(fighter: Fighter, amount: int) -> bool:
	(fighter.sp_component as TrinketsPool).trinkets_on_field += amount * 2
	return true

func enemy_action(fighter: Fighter) -> bool:
	if !fighter.alive:
		return true
	var board: TrinketsOnFieldLayer = field_layer.instantiate()
	board.battlefield = fighter.battlefield
	board.pm = (fighter as PartyMember)
	board.value_per_trinket = value_per_trinket
	fighter.battlefield.battle_board.add_pattern(board)
	fighter.battlefield.players_died.connect(board.done.emit)
	return true
