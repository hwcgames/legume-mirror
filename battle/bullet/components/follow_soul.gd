extends BulletComponent
class_name BulletFollowSoul

@export var speed: float = 50.
@export var close_enough: float = 64.

func move(bullet: Bullet, delta: float) -> bool:
	var soul: Soul = bullet.layer.battlefield.battle_board.souls.get(0)
	if not soul:
		return false
	var to_soul: Vector2 = soul.global_position - bullet.global_position
	var speed = speed * delta * clamp(to_soul.length() / close_enough, 0., 1.)
	bullet.global_position += to_soul.limit_length(speed)
	return false
