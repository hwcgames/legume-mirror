extends Area3D

func _ready():
	collision_layer = 4
	collision_mask = 4

var last_hover: Interactable

func _physics_process(delta: float) -> void:
	if get_parent() != Storyteller2.leader:
		return
	var hoverable: Array = get_overlapping_areas()\
		.filter(func(a: Area3D): return a is Interactable and a.interactable)
	hoverable.sort_custom(func(a, b): return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position))
	var hovered: Interactable = hoverable.get(0) if not hoverable.is_empty() else null
	if last_hover != hovered:
		if last_hover:
			last_hover.blur()
		if hovered:
			hovered.hover()
		last_hover = hovered
	if !hovered:
		return
	if Input.is_action_just_pressed("ui_accept"):
		hovered.go()
		hovered.blur()
		last_hover = null
