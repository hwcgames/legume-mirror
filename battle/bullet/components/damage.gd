extends BulletComponent
class_name BulletDamage

@export var value: Curve

func damage(bullet: Bullet, soul: Soul) -> bool:
	print("Bullet ", bullet, " hits ", soul)
	var damage = round(value.sample_baked(randf()))
	var players = soul.players.filter(func(p): return p.alive)
	if players.is_empty():
		return false
	var target: PartyMember = players[randi_range(0, len(players)-1)]
	target.take_damage(damage)
	Chatterbox.message(target, "%s!" % damage)
	return false
