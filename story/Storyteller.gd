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

var leader: PartyMember:
	get:
		return Actor.find(Storyteller.story.FetchVariable("leader"))

func _ready():
	for function in self.get_method_list():
		if not (function["name"] as String).begins_with("cmd_"):
			continue
		story.BindExternalFunction((function["name"] as String).substr(4), Callable(self , function["name"]), false)
	for function in self.get_method_list():
		if not (function["name"] as String).begins_with("obs_"):
			continue
		story.ObserveVariable((function["name"] as String).substr(4), Callable(self , function["name"]))
	do_story = true

func _process(delta: float) -> void:
	if not do_story:
		return
	if lock.exclusive_locked or lock.shared_locks > 0:
		return
	if !story.GetCanContinue():
		return
	var handle = await lock.exclusive_lock()
	line = story.Continue()
	if line == "_":
		return
	if line != null and !line.is_empty():
		print("Story line: ", line)
		new_line.emit(line, tags)
	if not story.GetCanContinue():
		handle.call()
		handle = await lock.exclusive_lock()
		new_choices.emit(choices)
	handle.call()

func choose_if_available(names: Array[String]) -> bool:
	var current_choices = choices
	print("Choosing ", names, " from ", current_choices.map(func(c): return c.GetText()))
	for choice_name in names:
		var choice_index = current_choices.find_custom(func(choice: InkChoice):
			return choice.GetText() == choice_name)
		if choice_index != -1:
			var choice = current_choices[choice_index]
			story.ChooseChoiceIndex(choice_index)
			chose.emit(choice)
			return true
	return false

func cmd_reset():
	print("Resetting the game for the next player.")
	OS.set_restart_on_exit(true)
	get_tree().quit()

func cmd_say(actor: String, text: String):
	await Chatterbox.simple_message(Actor.find(actor), text)

func cmd_dialogue_choice():
	Chatterbox.queue_dialogue_choice()

func cmd_sleep(time: float):
	(func():
		var handle = await lock.shared_lock()
		await get_tree().create_timer(time).timeout
		handle.call()).call()

func cmd_queue_room(room_name: String, seam: String):
	var treadmill: Treadmill = get_tree().current_scene.get_node("%Treadmill")
	var room: RoomInfo = load("res://database/rooms/%s.tres" % room_name)
	treadmill.add_request(Treadmill.RoomRequest.new(room, seam))

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

func cmd_spawn_actor(id: String, landmark_name: String):
	var actor: Actor = Actor.find(id)
	var landmark = Landmark.find(landmark_name)
	if actor != null:
		actor.global_transform = landmark.global_transform
		return
	var actor_sheet = load("res://database/actors/%s.tres" % id);
	actor = Actor.from_sheet(actor_sheet)
	get_tree().current_scene.add_child(actor)
	actor.global_transform = landmark.global_transform
	pass

func cmd_despawn_actor(id: String):
	var actor = Actor.find(id)
	actor.queue_free()

var party_stack: Array[PartyMember] = []

func cmd_spawn_party(landmark_name: String):
	printerr("Stub story operation!")
	var leader: String = story.FetchVariable("leader")
	var leader_pm = PartyMember.find(leader)
	var landmark = Landmark.find(landmark_name)
	if leader_pm != null:
		leader_pm.global_transform = landmark.global_transform
		return
	var leader_sheet = load("res://database/party_members/%s.tres" % leader);
	leader_pm = PartyMember.from_character_sheet(leader_sheet)
	get_tree().current_scene.add_child(leader_pm)
	leader_pm.global_transform = landmark.global_transform
	leader_pm.push_mode(ActorPlayerControl.new())
	party_stack = [leader_pm]
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

func cmd_add_party_member(id: String, landmark_name: String):
	printerr("Stub story operation!")
	var pm = PartyMember.find(id)
	var landmark = Landmark.find(landmark_name)
	if pm != null:
		pm.global_transform = landmark.global_transform
		return
	var pm_sheet = load("res://database/party_members/%s.tres" % id)
	pm = PartyMember.from_character_sheet(pm_sheet)
	get_tree().current_scene.add_child(pm)
	pm.global_transform = landmark.global_transform
	pm.push_mode(ActorModeFollow.new(party_stack[-1], 3.))
	party_stack.push_back(pm)

func cmd_rm_party_member(id: String):
	printerr("Stub story operation!")
	pass

func cmd_spawn_enemy(id: String, name: String, landmark_name: String):
	var landmark = Landmark.find(landmark_name)
	var enemy_factory: EnemyFactory = load("res://database/enemy/%s.tres" % id);
	var enemy: Enemy = Enemy.from_enemy_factory(enemy_factory)
	get_tree().current_scene.add_child(enemy)
	enemy.global_transform = landmark.global_transform
	enemy.name = name

func cmd_actor_act(actor_name: String, action: String):
	var actor = Actor.find(actor_name)
	if not actor:
		return
	actor.push_mode(ActorModeAnimate.new(action))

func cmd_actor_move(actor_name: String, landmark_name: String, style: String):
	var landmark = Landmark.find(landmark_name)
	var actor = Actor.find(actor_name)
	var mode: ActorMode
	match style:
		"walk", "run":
			mode = ActorModePathfind.new()
			mode.pathfind_target = landmark.global_position
		"glide", _:
			mode = ActorModeMoveTo.new(actor, landmark)
	actor.push_mode(mode)

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
		print("Wait for actor...")
		var lock = await lock.shared_lock()
		var actor = Actor.find(actor_name)
		if actor.top_mode is ActorModeStoryCanary:
			print("Already idle")
			lock.call()
			return
		while actor.top_mode is not ActorModeStoryCanary:
			await get_tree().process_frame
		print("Actor is idle")
		lock.call()
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

func cmd_play_sound(sound: String):
	print("Stub story operation")

func cmd_fade_out(color: String):
	print("Stub story operation")

func cmd_fade_in():
	print("Stub story operation")

func cmd_start_battle():
	var battlefield: Battlefield = Battlefield.find()
	battlefield.battle()

func cmd_join_battle(actor_name: String):
	var actor: Actor = Actor.find(actor_name)
	if not actor:
		return
	var battlefield: Battlefield = Battlefield.find()
	if actor is PartyMember:
		battlefield.players.push_back(actor)
	elif actor is Enemy:
		battlefield.enemies.push_back(actor)

static var battlefield_lock

func cmd_lock_battlefield():
	if battlefield_lock != null:
		return
	(func():
		var lock = await lock.shared_lock()
		battlefield_lock = await Battlefield.find().lock.exclusive_lock()
		lock.call()
	).call()

func cmd_free_battlefield():
	if battlefield_lock == null:
		return
	battlefield_lock.call()
	battlefield_lock = null

func cmd_enemy_state(enemy_name: String, state: int):
	var enemy: Enemy = Enemy.find(enemy_name)
	if not enemy:
		return
	enemy.state = state
	if enemy.planned_pattern:
		enemy.pick_pattern()

var active_camera: PhantomCamera3D
func cmd_set_camera(camera_name: String):
	if active_camera != null:
		active_camera.priority -= 10
		active_camera = null
	if camera_name == "_":
		return
	var camera = get_tree().get_nodes_in_group("camera").filter(func(c: Node): return c.name == camera_name).get(0)
	if camera is not PhantomCamera3D:
		return
	active_camera = camera
	camera.priority += 10

#func obs_party(_name, new_value: Array[String]):
	#if len(new_value) == 0:
		#printerr("The party can't be empty")
		#return
	#pass

#func obs_gamemode(_name, new_value: String):
	#print("Stub story operation")
	#pass
