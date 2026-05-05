extends BulletComponent
class_name BulletTrinketValue

var pm: Actor
@export var value: int = 10

func damage(bullet: Bullet, soul: Soul) -> bool:
	if value == 0:
		return false
	print("Grazed ", soul);
	for p in soul.players:
		if p.sp_component is not TrinketsPool:
			continue
		p.sp += value
		(p.sp_component as TrinketsPool).trinkets_on_field -= value
		bullet.queue_free()
		return false
	return false
