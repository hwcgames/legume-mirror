extends RichTextLabel

var lifetime: float = 5.

func _ready() -> void:
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
