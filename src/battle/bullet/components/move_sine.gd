extends BulletComponent
class_name BulletMoveSine

@export var amplitude: Curve
@export var period: Curve
var my_amplitude: float
var my_period: float
var my_clock: float = 0.

func _ready(bullet: Bullet):
	my_amplitude = amplitude.sample(randf())
	my_period = period.sample(randf())

func move(bullet: Bullet, delta: float) -> bool:
	my_clock += delta
	var cosine = cos(2*PI*my_clock/my_period) * my_amplitude
	bullet.translate(Vector2.RIGHT.rotated(bullet.rotation) * cosine * delta)
	return false
