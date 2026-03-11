extends BulletComponent
class_name BulletLifetime

@export var lifetime: Curve
var my_life: float
var elapsed: float = 0.

func _ready(bullet: Bullet):
	my_life = lifetime.sample(randf())

func move(bullet: Bullet, delta: float) -> bool:
	elapsed += delta
	if elapsed > my_life:
		bullet.queue_free()
	return false
