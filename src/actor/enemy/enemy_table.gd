extends EnemyFactory
class_name EnemyTable

@export var table: Dictionary[ActorSheet, float] = {}

func roll_enemy() -> ActorSheet:
	var total = table.values().reduce(func(a,b): return a+b)
	var value = randf_range(0, total)
	for enemy in table.keys():
		value -= table[enemy]
		if value <= 0:
			return enemy
	return null
