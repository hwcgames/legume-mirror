extends Control
class_name BulletEmitter

@export var layer: BulletPatternLayer
@export var emission_angle: Curve
@export var interval: Curve
@export var amount: Curve
@export var start_delay: float
@export var bullet: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().create_timer(start_delay).timeout.connect(fire)

signal fire_at_position(pos: Vector2)
signal fire_at_angle(angle: float)

func fire():
	var delay = interval.sample_baked(randf())
	var count = amount.sample_baked(randf())
	for i in range(ceil(count)):
		var bullet_position = Vector2(
			randf_range(0, get_rect().size.x),
			randf_range(0, get_rect().size.y)
		)
		var angle = emission_angle.sample_baked(randf())
		var bullet_instance: Bullet = bullet.instantiate()
		bullet_instance.layer = layer
		bullet_instance.rotation_degrees = angle
		bullet_instance.position = bullet_position
		add_child(bullet_instance)
		bullet_instance.reparent(get_parent(), true)
		fire_at_position.emit(bullet_position)
		fire_at_angle.emit(angle)
	get_tree().create_timer(delay).timeout.connect(fire)
