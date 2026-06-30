extends Node2D

@onready var layer: BulletPatternLayer = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if layer.battlefield.battle_board:
		global_position = layer.battlefield.battle_board.souls[0].global_position
