extends Control
class_name BulletEmitter

@export var enabled: bool = true
@export var layer: BulletPatternLayer
@export var emission_angle: Curve
@export var interval: Curve
@export var amount: Curve
@export var start_delay: float
@export var bullet: PackedScene
@export var parent: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not layer:
		var p = get_parent()
		while p is not BulletPatternLayer:
			p = p.get_parent()
		layer = p
	get_tree().create_timer(start_delay).timeout.connect(fire)

signal fire_at_position(pos: Vector2)
signal fire_at_angle(angle: float)

func fire():
	if not enabled:
		get_tree().physics_frame.connect(fire, CONNECT_ONE_SHOT)
		return
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
		bullet_instance.enemy = layer.enemy
		(parent if parent else layer).add_child(bullet_instance)
		bullet_instance.global_position = global_position + get_global_transform().basis_xform(bullet_position)
		bullet_instance.global_rotation_degrees = angle
		#bullet_instance.reparent(, true)
		fire_at_position.emit(bullet_position)
		fire_at_angle.emit(angle)
		# bullet_instance._bullet_ready()
	get_tree().create_timer(delay).timeout.connect(fire)
