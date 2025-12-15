extends BulletComponent
class_name BulletMoveLinear

@export var speed: float = 100.

func move(bullet: Bullet, delta: float) -> bool:
	bullet.translate(Vector2.UP.rotated(bullet.rotation) * delta * speed)
	return false
