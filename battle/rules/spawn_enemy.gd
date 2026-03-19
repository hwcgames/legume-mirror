extends BattleRule
class_name RuleSpawnEnemies

@export var enemy_template: EnemyFactory
@export var chance: float = 0.6
@export var active: bool = true

func top(fighter: Fighter) -> bool:
	if not fighter.alive:
		return true
	if len(fighter.battlefield.enemies.filter(func(e): return is_instance_valid(e) and e.alive)) == len(fighter.battlefield.enemy_landmarks):
		return true
	var enemy: Enemy = Enemy.from_enemy_factory(enemy_template)
	enemy.active = enemy.active && active
	for i in range(len(fighter.battlefield.enemy_landmarks)):
		var e = fighter.battlefield.enemies.get(i)
		if (not is_instance_valid(e)) or (not e.alive):
			if is_instance_valid(e):
				e.queue_free()
			while len(fighter.battlefield.enemies) <= i:
				fighter.battlefield.enemies.push_back(null)
			fighter.battlefield.enemies[i] = enemy
			break
	fighter.battlefield.add_child(enemy)
	enemy.join_battle(fighter.battlefield)
	return true
