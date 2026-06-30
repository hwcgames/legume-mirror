extends BulletComponent
class_name BulletGravity

@export var vector: Vector2 = Vector2(0, 20.)

var timer: float = 0

func move(bullet: Bullet, delta: float) -> bool:
	timer += delta
	var speed = vector * timer
	bullet.global_position += speed * delta
	return false
