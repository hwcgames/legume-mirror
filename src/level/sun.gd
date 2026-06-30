extends DirectionalLight3D
class_name Sun

@export var context: MainGame.MODE = MainGame.MODE.LEVEL
var base_rotation: float = 0.
var weather: Weather
var tween: Tween

func _ready() -> void:
	add_to_group("story_listener")

func wants_line(line: String, tags: Array[String]) -> bool:
	return do_line(line, tags) is Callable
func take_line(line: String, tags: Array[String]):
	await do_line(line, tags).call()
func do_line(line: String, _tags: Array[String]):
	if MainGame.find().mode != context:
		return null
	var words = Array(line.split(" ", false))
	match words:
		["/", "sun", "align", "with", var room_name]:
			if context != MainGame.MODE.LEVEL:
				return null
			var room: Room = Room.find(room_name)
			if !is_instance_valid(room):
				return null
			return func():
				base_rotation = room.global_rotation.y
				if is_instance_valid(tween):
					tween.kill()
				tween = create_tween()
				tween.tween_property(
					self,
					"global_rotation",
					Vector3(lerp_angle(global_rotation.x, weather.sun_angle.x, 1), lerp_angle(global_rotation.y, weather.sun_angle.y + base_rotation, 1.), 0),
					0.75
				).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
				tween.play()
		["/", "weather", var weather_name]:
			var path = "res://database/weather/%s.tres" % weather_name
			if !FileAccess.file_exists(path):
				return null
			return func():
				weather = load(path)
		["/", "weather", var weather_name, "instant"]:
			var path = "res://database/weather/%s.tres" % weather_name
			if !FileAccess.file_exists(path):
				return null
			return func():
				weather = load(path)
	return null

func set_weather(weather: Weather, instant = false):
	if is_instance_valid(tween):
		tween.kill()
	if instant:
		global_rotation = Vector3(weather.sun_angle.x, weather.sun_angle.y + base_rotation, 0.)
		light_color = weather.sun_color
	else:
		tween = create_tween()
		tween.tween_property(
			self,
			"global_rotation",
			Vector3(lerp_angle(global_rotation.x, weather.sun_angle.x, 1), lerp_angle(global_rotation.y, weather.sun_angle.y + base_rotation, 1.), 0),
			0.75
		).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.parallel()
		tween.tween_property(
			self,
			"light_color",
			weather.sun_color,
			0.75
		).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.play()
