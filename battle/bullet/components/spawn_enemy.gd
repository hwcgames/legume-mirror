extends BulletComponent
class_name BulletSpawnEnemy

@export var enemy_template: EnemyTable
@export var chance: float = 0.2
@export var active: bool = false

func damage(bullet: Bullet, soul: Soul) -> bool:
	if randf() > chance:
		return false
	if len(bullet.layer.battlefield.enemies.filter(func(e): return is_instance_valid(e) and e.alive)) == len(bullet.layer.battlefield.enemy_landmarks):
		return false
	var enemy: Actor = Actor.from_sheet(enemy_template.roll_enemy())
	enemy.active = enemy.active && active
	for i in range(len(bullet.layer.battlefield.enemy_landmarks)):
		var e = bullet.layer.battlefield.enemies.get(i)
		if (not is_instance_valid(e)) or (not e.alive):
			if is_instance_valid(e):
				e.queue_free()
			while len(bullet.layer.battlefield.enemies) <= i:
				bullet.layer.battlefield.enemies.push_back(null)
			bullet.layer.battlefield.enemies[i] = enemy
			break
	bullet.layer.battlefield.add_child(enemy)
	enemy.join_battle(bullet.layer.battlefield)
	return false
