extends BattleRule
class_name TrinketsRule

@export var trinkets_decay: float = 0.7
@export var field_layer: PackedScene = preload("uid://dhpww5nxtbn2n")
@export var value_per_trinket: int = 5

func top(fighter: Actor) -> bool:
	(fighter.sheet.party_component.sp as TrinketsPool).trinkets_on_field *= trinkets_decay
	return true

func begin(fighter: Actor) -> bool:
	(fighter.sheet.party_component.sp as TrinketsPool).trinkets_on_field = 0
	return true

func sp_change(fighter: Actor, instance: SpChange) -> bool:
	if instance.amount <= 0:
		return false
	activated.emit()
	return false

func hp_change(fighter: Actor, instance: HpChange) -> bool:
	if instance.amount < 0:
		fighter.sp_change(SpChange.new(instance.from, instance.to, instance.amount))
	(fighter.sheet.party_component.sp as TrinketsPool).trinkets_on_field += instance.amount * 1.5
	return true

func enemy_action(fighter: Actor) -> bool:
	if !fighter.alive:
		return true
	activated.emit()
	var board: TrinketsOnFieldLayer = field_layer.instantiate()
	board.battlefield = fighter.battlefield
	board.pm = (fighter as Actor)
	board.value_per_trinket = value_per_trinket
	fighter.battlefield.battle_board.add_pattern(board)
	fighter.battlefield.players_died.connect(board.done.emit)
	return true

func icon(fighter: Actor) -> Texture2D:
	var sheet: SpriteFrames = preload("uid://dd807705h8yfd")
	return sheet.get_frame_texture("TRINKETS", 0)

func message(fighter: Actor) -> String:
	return "Energy is governed by trinkets.\nScatter trinkets on the board with your basic attack.\nCollect them; they persist between battles."
