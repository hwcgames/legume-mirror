extends Resource
class_name EnemyComponent

@export var active: bool = true

@export var patterns: Array[BulletPattern] = []
@export var planning_priority: int
@export var parleys: Array[ParleyAction] = []

func copy() -> EnemyComponent:
	var out: EnemyComponent = duplicate()
	out.patterns = patterns.map(func(pattern): return pattern.copy())
	out.parleys = parleys.map(func(parley): return parley.copy())
	return out
