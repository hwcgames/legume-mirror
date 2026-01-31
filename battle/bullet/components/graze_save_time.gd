extends BulletComponent
class_name BulletGrazeSaveTime

@export var value: Curve

func graze(bullet: Bullet, soul: Soul) -> bool:
	bullet.layer.duration -= value.sample(randf())
	return false
