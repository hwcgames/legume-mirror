extends Area2D
class_name Bullet

@export var components: Array[BulletComponent] = []
@export var state: int = 0
@export var should_invuln: bool = true
@export var should_graze: bool = true
@export var animator: AnimationPlayer
var enemy: Enemy
var target: Soul
var layer: BulletPatternLayer
var rotation_initialized: bool = false
var initialized: bool = false

func _bullet_ready():
	initialized = true
	if not layer:
		var l = get_parent()
		while l is not BulletPatternLayer:
			l = l.get_parent()
		layer = l
	if not enemy:
		enemy = layer.enemy
	for component in components:
		component._ready(self)

func _physics_process(delta: float):
	if not initialized:
		_bullet_ready()
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
