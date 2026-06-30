extends BulletComponent
class_name BulletStateChange

@export var timer: Curve
@export var to_state: int = 0

func _init() -> void:
	resource_local_to_scene = true

var elapsed: float = 0.
var total: float

func _ready(bullet: Bullet):
	total = timer.sample(randf())

func move(bullet: Bullet, delta: float) -> bool:
	elapsed += delta
	if elapsed >= total:
		bullet.state = to_state
		elapsed = 0
		return true
	return false
