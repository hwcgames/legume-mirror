extends BulletComponent
class_name BulletGrazeValue

@export var value: Curve

func graze(bullet: Bullet, soul: Soul) -> bool:
	print("Grazed ", soul);
	var amount = value.sample_baked(randf())
	for p in soul.players:
		p.get_sp(amount)
	return false
