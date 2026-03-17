extends EnemyFactory
class_name EnemyTable

@export var table: Array[EnemyFactory] = []

func roll_enemy() -> EnemySheet:
	var total = table.map(func(e): return e.weight).reduce(func(a,b): return a+b)
	var value = randf_range(0, total)
	for enemy in table:
		value -= enemy.weight
		if value <= 0:
			return enemy.roll_enemy()
	return null
