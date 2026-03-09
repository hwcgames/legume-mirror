extends BulletComponent
class_name BulletComponentIf

@export var subcomponents: Array[BulletComponent] = []
@export var states: Array[int] = []

func _ready(bullet: Bullet):
	if bullet.state not in states:
		return false
	for component in subcomponents:
		component._ready(bullet)


func move(bullet: Bullet, delta: float) -> bool:
	if bullet.state not in states:
		return false
	for component in subcomponents:
		if component.move(bullet, delta):
			return true
	return false

func graze(bullet: Bullet, soul: Soul) -> bool:
	if bullet.state not in states:
		return false
	for component in subcomponents:
		if component.graze(bullet, soul):
			return true
	return false

func damage(bullet: Bullet, soul: Soul) -> bool:
	if bullet.state not in states:
		return false
	for component in subcomponents:
		if component.damage(bullet, soul):
			return true
	return false
