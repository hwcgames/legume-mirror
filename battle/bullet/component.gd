@abstract
extends Resource
class_name BulletComponent

func move(bullet: Bullet, delta: float) -> bool:
	return false

func graze(bullet: Bullet, soul: Soul) -> bool:
	return false

func damage(bullet: Bullet, soul: Soul) -> bool:
	return false
