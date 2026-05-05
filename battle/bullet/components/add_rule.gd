extends BulletComponent
class_name BulletAddRule

@export var rule: BattleRule
@export var chance: float = 1.

func damage(bullet: Bullet, soul: Soul) -> bool:
	var players = soul.players.filter(func(p): return p.alive)
	if players.is_empty():
		return false
	var target: Actor = players[randi_range(0, len(players) - 1)]
	if randf() < chance:
		if target.add_rule(rule.duplicate()):
			rule._added_to_soul(soul)
	return false
