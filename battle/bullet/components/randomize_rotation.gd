extends BulletComponent
class_name BulletRandomizeRotation

@export var amount: Curve

func _ready(bullet: Bullet):
	bullet.rotate(deg_to_rad(amount.sample(randf())))
