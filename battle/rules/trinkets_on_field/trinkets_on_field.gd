extends BulletPatternLayer
class_name TrinketsOnFieldLayer

@export var pm: Actor
@export var value_per_trinket: int = 10
@export var trinket_scene: PackedScene = preload("uid://d4jcm0io4gafo")

func _ready() -> void:
	(pm.sp_component as TrinketsPool).trinkets_changed.connect(trinkets_changed)
	await get_tree().process_frame
	trinkets_changed((pm.sp_component as TrinketsPool).trinkets_on_field)

var trinkets_on_field: Array[Bullet] = []

var to_place: int = 0

func trinkets_changed(amount: int):
	amount += to_place
	while amount >= value_per_trinket:
		amount -= value_per_trinket
		var trinket: Bullet = trinket_scene.instantiate()
		for component in trinket.components:
			if component is BulletTrinketValue:
				component.pm = pm
				component.value = value_per_trinket
		add_child(trinket)
		trinket.scale = Vector2.ZERO
		trinket.create_tween().tween_property(trinket, "scale", Vector2.ONE, 0.5)
		trinket.position = Vector2(
			randf_range(0, get_rect().size.x),
			randf_range(0, get_rect().size.y)
		)
		trinkets_on_field.push_back(trinket)
	to_place = amount
