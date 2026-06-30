extends BulletComponent
class_name BulletSplash

@export var splash_scene: PackedScene

var was_above_soup: bool = true

func move(bullet: Bullet, delta: float) -> bool:
	var soup: Bullet = bullet.layer.get_node("%Soup")
	var below_soup = bullet.global_position.y > soup.global_position.y
	if below_soup and was_above_soup:
		var splash: Node2D = splash_scene.instantiate()
		if splash is Bullet:
			splash.layer = bullet.layer
			splash.enemy = bullet.enemy
		bullet.layer.add_child(splash)
		(func(): splash.global_position = bullet.global_position + Vector2(0, 24.)).call_deferred()
	was_above_soup = not below_soup
	return false
