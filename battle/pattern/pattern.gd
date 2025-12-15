extends Control
class_name BulletPatternLayer

var battlefield: Battlefield
@export var duration: float = 10.0

signal done

func _process(delta: float) -> void:
	duration -= delta
	if duration <= 0:
		done.emit()
