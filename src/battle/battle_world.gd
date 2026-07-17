extends CanvasLayer
class_name BattleWorld

var battlefield: Battlefield:
	get:
		return %Battlefield
var environment: BattleEnvironment

func setup(environment: BattleEnvironment):
	self.environment = environment
	%SubViewport.transparent_bg = true
	%Battlefield.player_landmarks = environment.players
	%Battlefield.enemy_landmarks = environment.enemies
	if environment.is_inside_tree():
		environment.reparent(%SubViewport, false)
	else:
		%SubViewport.add_child(environment)
	(func():
		await environment.animate_in()
		%SubViewport.transparent_bg = false
	).call()

func _ready() -> void:
	add_to_group("story_listener")

func wants_line(line: String, tags: Array[String]) -> bool:
	return do_line(line, tags) is Callable
func take_line(line: String, tags: Array[String]):
	await do_line(line, tags).call()
func do_line(line: String, tags: Array[String]):
	match Array(line.split(" ", false)):
		["/", "battle", "end"]:
			return func():
				await environment.animate_out()
				queue_free()
		pass
	return null
