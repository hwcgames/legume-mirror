extends BulletComponent
class_name BulletTrail

@export var line_path: NodePath
var line: Line2D

func _ready(bullet: Bullet):
	line = bullet.get_node("Trail")
	line.reparent(bullet.layer)
	line.global_transform = Transform2D.IDENTITY

@export var interval: float = 0.1
@export var ticks: int = 15
var clock: float = 0.
var colliders: Array[CollisionShape2D] = []

func move(bullet: Bullet, delta: float) -> bool:
	clock += delta
	if clock >= interval:
		clock = 0.
		var p = bullet.global_position
		line.add_point(bullet.global_position)
		while line.get_point_count() > ticks:
			line.remove_point(0)
		while len(colliders) > ticks:
			colliders.pop_front().queue_free()
		var collision = CollisionShape2D.new()
		collision.shape = CircleShape2D.new()
		collision.shape.radius = 3.
		collision.disabled = true
		bullet.add_child(collision)
		#collision.top_level = true
		collision.global_position = bullet.global_position
		colliders.push_back(collision)
		collision.set.call_deferred("disabled", false)
		var update_pos = func():
			collision.global_position = p
		RenderingServer.frame_pre_draw.connect(update_pos)
		collision.tree_exited.connect(func(): RenderingServer.frame_pre_draw.disconnect(update_pos))
	for i in range(len(colliders)):
		colliders[i].global_position = line.get_point_position(i)
		colliders[i].reset_physics_interpolation()
	return false
