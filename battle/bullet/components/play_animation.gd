extends BulletComponent
class_name BulletPlayAnimation

@export var animation: StringName
@export var state_after: int = -1
@export var persistent: bool = false

func _ready(bullet: Bullet):
	pass

var acted: bool = false
func move(bullet: Bullet, delta: float) -> bool:
	if not bullet.animator:
		return false
	if persistent and bullet.animator.current_animation != animation:
		acted = false
	if not acted:
		(func():
			acted = true
			var animator: AnimationPlayer = bullet.animator
			animator.play(animation)
			if state_after != -1:
				await animator.animation_finished
				bullet.state = state_after
		).call()
	return false
