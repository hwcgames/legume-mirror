extends BulletComponent
class_name BulletAimAtSoul

@export var keep_aiming: bool = false
@export var tracking_speed: float = 0.01

func _ready(bullet: Bullet):
	bullet.global_rotation = bullet.layer.angle_to_soul(bullet.position, 0) + PI/2

func move(bullet: Bullet, delta: float):
	if keep_aiming:
		bullet.rotate(clamp(angle_difference(bullet.rotation, bullet.layer.angle_to_soul(bullet.position, 0.)), -tracking_speed * delta, tracking_speed * delta))
