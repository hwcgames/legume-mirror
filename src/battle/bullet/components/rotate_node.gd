extends BulletComponent
class_name BulletRotateNode

@export var speed_curve: Curve
@export var node_path: NodePath
var node: Node2D
var speed: float

func _ready(bullet: Bullet):
	node = bullet.get_node(node_path)
	speed = speed_curve.sample(randf())

func move(bullet: Bullet, delta: float) -> bool:
	bullet.get_node(node_path).rotate(deg_to_rad(speed * delta))
	return false
