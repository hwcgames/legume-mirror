extends WorldEnvironment
class_name StoryEnvironment

@export var context: MainGame.MODE = MainGame.MODE.LEVEL

func _ready():
	add_to_group("story_listener")

var tween: Tween

func wants_line(line: String, tags: Array[String]) -> bool:
	return do_line(line, tags) is Callable
func take_line(line: String, tags: Array[String]):
	await do_line(line, tags).call()
func do_line(line: String, _tags: Array[String]):
	if MainGame.find().mode != context:
		return null
	var words = Array(line.split(" ", false))
	match words:
		["/", "weather", var weather_name]:
			var path = "res://database/weather/%s.tres" % weather_name
			if !FileAccess.file_exists(path):
				return null
			return func():
				var weather: Weather = load(path)
				set_weather(weather)
		["/", "weather", "instant", var weather_name]:
			var path = "res://database/weather/%s.tres" % weather_name
			if !FileAccess.file_exists(path):
				return null
			return func():
				var weather: Weather = load(path)
				set_weather(weather, true)
	return null

func set_weather(weather: Weather, instant = false):
	if is_instance_valid(tween):
		tween.kill()
	tween = create_tween()
	if !is_instance_valid(weather.environment):
		return
	environment = environment.duplicate()
	for property in environment.get_property_list():
		var name: String = property["name"]
		if (not instant) and ((environment[name] is float) or (environment[name] is Color) or (environment[name] is Vector3)):
			tween.parallel()
			tween.tween_property(
				environment,
				name,
				weather.environment[name],
				0.75
			).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		else:
			environment[name] = weather.environment[name]
	tween.play()
