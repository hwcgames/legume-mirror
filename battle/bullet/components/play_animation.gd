extends BulletComponent
class_name BulletPlayAnimation

@export var animator_p: NodePath
@export var animation: StringName
@export var state_after: int = -1

func _ready(bullet: Bullet):
	pass

var acted: bool = false
func move(bullet: Bullet, delta: float) -> bool:
	if not acted:
		(func():
			acted = true
			var animator: AnimationPlayer = bullet.get_node(animator_p)
			animator.play(animation)
			if state_after != -1:
				await animator.animation_finished
				bullet.state = state_after
		).call()
	return false
