extends Node
class_name ActorRoot

static var me: ActorRoot
static func find() -> ActorRoot:
	return me
func _ready():
	me = self
	add_to_group("story_listener")

func wants_line(line: String, tags: Array[String]) -> bool:
	return do_line(line, tags) is Callable
func take_line(line: String, tags: Array[String]):
	do_line(line, tags).call()
func do_line(line: String, tags: Array[String]):
	match Array(line.split(" ", false)):
		[">>>", "spawn", var actor_name]:
			return func():
				var sheet: ActorSheet = ActorSheet.find(actor_name)
				var actor: Actor = Actor.from_sheet(sheet)
				actor.active_component = actor.get_node("%Component/Uninit")
				add_child(actor)
	return null
