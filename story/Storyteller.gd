extends Node

var story: InkStory = preload("uid://c8fvftm0kh5t"):
	set(new_story):
		story = new_story
		_ready()
var lock: Locks = Locks.new()
var do_story: bool = false

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
	if not do_story:
		return
	if lock.exclusive_locked or lock.shared_locks > 0:
		return
	if !story.GetCurrentChoices().is_empty():
		return
	var handle = await lock.exclusive_lock()
	line = story.Continue()
	if !line.is_empty():
		print("Story line: ", line)
		new_line.emit(line, tags)
	if not story.GetCanContinue():
		handle.call()
		handle = await lock.exclusive_lock()
		new_choices.emit(choices)
	handle.call()

func choose_if_available(names: Array[String]) -> bool:
	var current_choices = choices
	for choice_name in names:
		var choice_index = current_choices.find_custom(func(choice: InkChoice):
			return choice.GetText() == choice_name)
		if choice_index != -1:
			var choice = current_choices[choice_index]
			story.ChooseChoiceIndex(choice_index)
			chose.emit(choice)
			return true
	return false

func cmd_say(actor: String, text: String):
	Chatterbox.simple_message(Actor.find(actor), text)

func cmd_dialogue_choice():
	Chatterbox.queue_dialogue_choice()

func cmd_sleep(time: float):
	var handle = await lock.shared_lock()
	await get_tree().create_timer(time).timeout
	handle.call()

func cmd_queue_room(room: String, seam: String):
	printerr("unimplemented story operation!")

func cmd_change_level(level_id: String, starting_room: String = "default"):
	(func():
		var l = await lock.shared_lock()
		var level: Level = load("res://database/level/%s.tres" % level_id)
		get_tree().change_scene_to_packed(preload("uid://cw0r478jvhrnn"))
		await get_tree().process_frame
		var treadmill: Treadmill = get_tree().current_scene.get_node("%Treadmill")
		#var dungeon_map: DungeonMap = get_tree().current_scene.get_node("%DungeonMap")
		treadmill.roomset = level.roomset
		treadmill.spawn_initial_room(level.entrances[starting_room])
		l.call()
	).call()

func cmd_start_dungeon(dungeon_name: String):
	printerr("Todo: use dungeon generator name %s" % dungeon_name)
	var dungeon_map: DungeonMap = get_tree().current_scene.get_node("%DungeonMap")
	dungeon_map.generate_map()

func cmd_stop_dungeon():
	var dungeon_map: DungeonMap = get_tree().current_scene.get_node("%DungeonMap")
	dungeon_map.reset()

func cmd_block_dungeon_progress():
	var dungeon_map: DungeonMap = get_tree().current_scene.get_node("%DungeonMap")
	assert(dungeon_map.allow_progress == true, "Inconsistency: Double-blocked dungeon progress")
	dungeon_map.allow_progress = false

func cmd_allow_dungeon_progress():
	var dungeon_map: DungeonMap = get_tree().current_scene.get_node("%DungeonMap")
	assert(dungeon_map.allow_progress == false, "Inconsistency: Double-allowed dungeon progress")
	dungeon_map.allow_progress = true

func cmd_spawn_actor(actor: String, landmark_name: String):
	var leader: String = story.FetchVariable("party")
	print(leader)

func cmd_spawn_party(landmark_name: String):
	printerr("Stub story operation!")
	#var landmark = Landmark.find(landmark_name)
	#var party: InkList = story.FetchVariable("party")
	#var leader: String = story.FetchVariable("party")
	#
	#for member in party.:
		#var is_leader: bool = member == leader
		#var character_sheet: CharacterSheet = load("res://database/party_members/%s.tres" % member)
		#var party_member = PartyMember.from_character_sheet(character_sheet)
		#if is_leader:
			#party_member.push_mode(ActorPlayerControl.new())
		#else:
			#party_member.push_mode(ActorPlayerControl.new())
		#party_member.transform = landmark.global_transform
		#get_tree().current_scene.add_child(party_member)

func cmd_spawn_party_member(id: String, landmark: String):
	printerr("Stub story operation!")

func cmd_spawn_enemy(id: String, landmark: String) -> String:
	printerr("Stub story operation!")
	return id

func cmd_actor_act(actor: String, action: String):
	printerr("Stub story operation!")

func cmd_actor_move(actor_name: String, landmark_name: String, _style: String):
	var landmark = Landmark.find(landmark_name)
	var actor = Actor.find(actor_name)
	var mode = ActorModePathfind.new()
	mode.pathfind_target = landmark.global_position
	await actor.push_mode(mode)

func cmd_actor_start_following_path(actor_name: String, path_name: String):
	(func():
		var actor = Actor.find(actor_name)
		var automove = Automove.find(actor, path_name)
		await actor.push_mode(ActorModeAutomove.new(automove))
	).call()

func cmd_actor_start_following_actor(follower_name: String, followee_name: String, _style: String):
	(func():
		var follower = Actor.find(follower_name)
		var followee = Actor.find(followee_name)
		await follower.push_mode(ActorModeFollow.new(followee, 1.5))
	).call()

func cmd_actor_stop(actor_name: String):
	(func():
		var actor = Actor.find(actor_name)
		await actor.pop_mode()
	).call()

func cmd_actor_wait(actor_name: String):
	(func():
		var lock = await lock.shared_lock()
		var actor = Actor.find(actor_name)
		await actor.mode_stack[-1].popped
	).call()

func cmd_actor_capture(actor_name: String):
	(func():
		var actor = Actor.find(actor_name)
		await actor.push_mode(ActorModeStoryCanary.new())
	).call()

func cmd_actor_release(actor_name: String):
	(func():
		var actor = Actor.find(actor_name)
		var index = actor.mode_stack.rfind_custom(func(mode): return mode is ActorModeStoryCanary)
		assert(index != -1, "Inconsistency: Double-released actor")
		if index == -1:
			return
		while not actor.mode_stack.is_empty():
			var popped = await actor.pop_mode()
			if popped is ActorModeStoryCanary:
				return
	).call()

func obs_party(_name, new_value: Array[String]):
	if len(new_value) == 0:
		printerr("The party can't be empty")
		return
	pass

func obs_gamemode(_name, new_value: Array[String]):
	if len(new_value) != 1:
		printerr("We can be in exactly one gamemode")
	pass
