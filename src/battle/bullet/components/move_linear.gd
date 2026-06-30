extends BulletComponent
class_name BulletMoveLinear

@export var speed: float = 100.
@export var deceleration: Curve
var decel: float = 0.0

func _ready(bullet: Bullet):
	if deceleration:
		decel = deceleration.sample(randf())

func move(bullet: Bullet, delta: float) -> bool:
	bullet.translate(Vector2.UP.rotated(bullet.rotation) * delta * speed)
	speed = max(speed - decel * delta, 0)
	return false
