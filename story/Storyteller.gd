extends Node

var story: InkStory = preload("uid://c8fvftm0kh5t"):
	set(new_story):
		story = new_story
		_ready()
var lock: Locks = Locks.new()

var line: String = ""
var tags: Array[String]:
	get:
		return story.GetCurrentTags()
signal new_line(line: String, tags: Array[String])
var choices: Array[InkChoice]:
	get:
		return story.GetCurrentChoices()
signal new_choices(choices: Array[InkChoice])
signal chose(choice: InkChoice)

enum STORY_STATE {
	WAITING,
	CHOOSING,
}

func _ready():
	for function in self.get_method_list():
		if not (function["name"] as String).begins_with("cmd_"):
			continue
		story.BindExternalFunction((function["name"] as String).substr(4), Callable(self, function["name"]), false)
	for function in self.get_method_list():
		if not (function["name"] as String).begins_with("obs_"):
			continue
		story.ObserveVariable((function["name"] as String).substr(4), Callable(self, function["name"]))

func _process(delta: float) -> void:
	if lock.exclusive_locked or lock.shared_locks > 0:
		return
	var handle = await lock.exclusive_lock()
	if not story.GetCanContinue():
		return
	line = story.Continue()
	new_line.emit(line, tags)
	if not story.GetCanContinue():
		handle.call()
		handle = await lock.exclusive_lock()
		new_choices.emit(choices)
	handle.call()


func cmd_sleep(time: float):
	var handle = await lock.shared_lock()
	await get_tree().create_timer(time).timeout
	handle.call()

func cmd_change_level(level_id: String, starting_room: String = "default"):
	var level: Level = load("res://database/level/%s.tres" % level_id)
	get_tree().change_scene_to_packed(preload("uid://cw0r478jvhrnn"))
	var treadmill: Treadmill = get_tree().current_scene.get_node("%Treadmill")
	#var dungeon_map: DungeonMap = get_tree().current_scene.get_node("%DungeonMap")
	treadmill.roomset = level.roomset
	treadmill.spawn_initial_room(level.entrances[starting_room])

func cmd_spawn_party(landmark_name: String):
	var landmark = Landmark.find(landmark_name)
	var party: Array[String] = story.FetchVariable("party")
	var leader: String = story.FetchVariable("party")
	
	for member in party:
		var is_leader: bool = member == leader
		var character_sheet: CharacterSheet = load("res://database/party_members/%s.tres" % member)
		var party_member = PartyMember.from_character_sheet(character_sheet)
		if is_leader:
			party_member.push_mode(ActorPlayerControl.new())
		else:
			party_member.push_mode(ActorPlayerControl.new())
		party_member.transform = landmark.global_transform
		get_tree().current_scene.add_child(party_member)

func cmd_spawn_actor(actor: String, landmark_name: String):
	var leader: String = story.FetchVariable("party")
	if true:
#		Make sure I come back here

func obs_party(_name, new_value: Array[String]):
	if len(new_value) == 0:
		printerr("The party can't be empty")
		return
	pass

func obs_gamemode(_name, new_value: Array[String]):
	if len(new_value) != 1:
		printerr("We can be in exactly one gamemode")
	pass
