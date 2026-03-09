extends Area2D
class_name Bullet

@export var components: Array[BulletComponent] = []
@export var state: int = 0
var enemy: Enemy
var target: Soul
var layer: BulletPatternLayer
var rotation_initialized: bool = false

func _bullet_ready():
	for component in components:
		component._ready(self)

func _physics_process(delta: float):
	for mover in components:
		var stop = mover.move(self, delta)
		if stop:
			break

func _on_graze_player(soul: Soul):
	for grazer in components:
		var stop = grazer.graze(self, soul)
		if stop:
			break

func _on_hurt_player(soul: Node2D):
	for damager in components:
		var stop = damager.damage(self, soul)
		if stop:
			break
