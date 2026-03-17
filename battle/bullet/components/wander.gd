extends BulletComponent
class_name BulletWander

@export var noise: FastNoiseLite
@export var timescale: float = 1.
@export var coord_curve: Curve

var timer: float = 0.

func _ready(bullet: Bullet):
	noise.seed = randi()

func move(bullet: Bullet, delta: float) -> bool:
	timer += delta * timescale
	var noise_val = Vector2(
		coord_curve.sample(noise.get_noise_1d(timer)),
		coord_curve.sample(noise.get_noise_1d(timer + 100.))
	)
	bullet.global_position = bullet.layer.global_position + bullet.layer.size * noise_val
	return false
