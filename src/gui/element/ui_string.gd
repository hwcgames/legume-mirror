extends Line2D
class_name UiString

@export var target: Node2D
@export var handle_len: float = 64.
@export var point_amt: int = 64.
var curve: Curve2D = Curve2D.new()

func _ready():
	while curve.point_count < 2:
		curve.add_point(Vector2.ZERO)

func _process(delta: float) -> void:
	if !is_instance_valid(target) or !target.is_inside_tree():
		return
	curve.set_point_position(0, global_position)
	curve.set_point_out(0, Vector2.UP.rotated(global_rotation) * handle_len)
	curve.set_point_position(1, target.global_position)
	curve.set_point_in(1, Vector2.UP.rotated(target.global_rotation) * handle_len)
	var baked = curve.get_baked_points()
	while len(points) > len(baked):
		remove_point(len(baked)-1)
	while len(points) < len(baked):
		add_point(Vector2.ZERO)
	
	for i in range(len(baked)):
		var f = i / (point_amt - 1)
		set_point_position(i, global_transform.inverse() * baked[i])
