extends BulletComponent
class_name BulletDamage

@export var value: Curve
@export var magic: bool = false
@export var finesse: bool = false

func damage(bullet: Bullet, soul: Soul) -> bool:
	print("Bullet ", bullet, " hits ", soul)
	var players = soul.players.filter(func(p): return p.alive)
	if players.is_empty():
		return false
	var target: PartyMember = players[randi_range(0, len(players) - 1)]
	var damage = max(1, round(value.sample_baked(randf())) + \
		3 * (bullet.enemy.computed_attrs.magic if magic else bullet.enemy.computed_attrs.strength) - \
		3 * (target.computed_attrs.finesse if finesse else target.computed_attrs.defense))
	target.take_damage(damage)
	Chatterbox.simple_message(target, "%s!" % damage)
	return false
