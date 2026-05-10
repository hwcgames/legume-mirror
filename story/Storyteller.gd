extends Node

var story: InkStory = load("uid://c8fvftm0kh5t"):
	set(new_story):
		story = new_story
		if is_instance_valid(story):
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

var leader: Actor:
	get:
		return Actor.find(Storyteller.story.FetchVariable("leader"))
		
var rules: Array[BattleRule] = []

func _ready():
	story.changed.connect(setup)
	Saver.pre_save.connect(pre_save)
	Saver.post_load.connect(post_load)
	setup()
func setup():
	for function in self.get_method_list():
		if not (function["name"] as String).begins_with("cmd_"):
			continue
		story.BindExternalFunction((function["name"] as String).substr(4), Callable(self , function["name"]), false)
	for function in self.get_method_list():
		if not (function["name"] as String).begins_with("obs_"):
			continue
		story.ObserveVariable((function["name"] as String).substr(4), Callable(self , function["name"]))
	if last_state:
		story.LoadState(last_state)
	#do_story = true

func pre_save(file: SaveFile):
	file.ink_save = story.SaveState()
	file.active_camera = active_camera.name if is_instance_valid(active_camera) else null

func post_load(file: SaveFile):
	do_story = false
	var handle = await lock.shared_lock()
	# oh boy this is unsafe!
	while not story.unreference():
		pass
	story = load("uid://c8fvftm0kh5t")
	await get_tree().process_frame
	last_state = file.ink_save
	story.LoadState(file.ink_save)
	handle.call()
	await get_tree().process_frame
	handle = await lock.exclusive_lock()
	handle.call()
	if file.active_camera != null and file.active_camera != "":
		cmd_set_camera(file.active_camera)
	Chatterbox.clear()
	do_story = true

var last_state

func _process(delta: float) -> void:
	if not do_story:
		return
	if lock.exclusive_locked or lock.shared_locks > 0:
		return
	if !story.GetCanContinue():
		return
	if is_instance_valid(nag_timer):
		nag_timer = null
	var handle = await lock.exclusive_lock()
	line = story.Continue()
	if line and line.strip_edges() != "_" and !line.is_empty():
		print("Story line: ", line)
		new_line.emit(tr(line), tags)
	if not story.GetCanContinue():
		handle.call()
		handle = await lock.exclusive_lock()
		new_choices.emit(choices)
		check_nag(choices)
	last_state = story.SaveState()
	handle.call()

var nag_timer: SceneTreeTimer

func check_nag(choices: Array[InkChoice]):
	for choice in choices:
		if not choice.GetText().begins_with("nag "):
			continue
		var time = float(choice.GetText().trim_prefix("nag "))
		nag_timer = get_tree().create_timer(time)
		nag_timer.timeout.connect(func(): choose_if_available([choice.GetText()]))

func choose_if_available(names: Array[String], important: bool = false) -> bool:
	print("Choosing ", names, " from ", choices.map(func(c): return c.GetText()))
	for name in names:
		for i in range(len(choices)):
			var choice = choices[i]
			if choice.GetText() == name:
				story.ChooseChoiceIndex(i)
				return true
	if important and story.GetCanContinue():
		print("Trying to choose ", names, " on the next choice")
		self.new_choices.connect(func(_c): choose_if_available(names, false), CONNECT_ONE_SHOT)
	return false
	#var current_choices = choices
	#for choice_name in names:
		#var choice_index = current_choices.find_custom(func(choice: InkChoice):
			#return choice.GetText() == choice_name)
		#if choice_index != -1:
			#print("Choosing ", choice_name, " (", choice_index, ") from ", current_choices.map(func(c): return c.GetText()))
			#var choice = current_choices[choice_index]
			#assert(len(choices) == len(current_choices))
			#for i in range(len(choices)):
				#assert(choices[i].GetText() == current_choices[i].GetText())
			#story.ChooseChoiceIndex(choice_index)
			#chose.emit(choice)
			#return true

func cmd_reset():
	print("Resetting the game for the next player.")
	OS.set_restart_on_exit(true)
	get_tree().quit()

func cmd_say(actor: String, text: String):
	await Chatterbox.simple_message(Actor.find(actor), text)

func cmd_clear_dialogue():
	var top = Chatterbox.oldest
	while top != null:
		top.queue_free()
		top = top.next_balloon
	Chatterbox.newest = null
	Chatterbox.oldest = null

func cmd_dialogue_choice():
	Chatterbox.queue_dialogue_choice()

func cmd_random_choice():
	new_choices.connect(func(_c):
		await get_tree().process_frame
		print("Choosing randomly from ", choices.map(func(c): return c.GetText()))
		if not choices.any(func(c): return c.GetText() != "_"):
			story.ChooseChoiceIndex(0)
			return
		while true:
			var i = randi_range(0, len(story.GetCurrentChoices()) - 1)
			if choices[i].GetText() == "_":
				continue
			if len(story.GetCurrentChoices()) <= i:
				continue
			story.ChooseChoiceIndex(i)
			break ,
		CONNECT_ONE_SHOT
	)

func cmd_kill_enemies():
	var battlefield: Battlefield = Battlefield.find()
	for enemy in battlefield.enemies:
		enemy.hp -= 999999

func cmd_actor_exists(actor_name: String) -> bool:
	return Actor.find(actor_name) != null

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
	new_scene = true
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
		get_tree().create_timer(0.5).timeout.connect(func(): new_scene = false)
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
	#assert(dungeon_map.allow_progress == true, "Inconsistency: Double-blocked dungeon progress")
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

var party_stack: Array[Actor] = []

func cmd_spawn_party(landmark_name: String):
	printerr("Stub story operation!")
	var leader: String = story.FetchVariable("leader")
	var leader_pm = Actor.find(leader)
	var landmark = Landmark.find(landmark_name)
	if leader_pm != null:
		leader_pm.global_transform = landmark.global_transform
		return
	var leader_sheet = Saver.current_save.get_character_sheet(leader)
	leader_pm = Actor.from_sheet(leader_sheet)
	leader_pm.add_to_group("party_leader")
	leader_pm.add_to_group("loading_root")
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

func cmd_spawn_party_member(id: String, landmark_name: String):
	var pm = Actor.find(id)
	var landmark = Landmark.find(landmark_name)
	if pm != null:
		pm.global_transform = landmark.global_transform
		return
	var pm_sheet = Saver.current_save.get_character_sheet(id)
	pm = Actor.from_sheet(pm_sheet)
	if pm.id == story.FetchVariable("leader"):
		pm.add_to_group("party_leader")
		pm.add_to_group("loading_root")
	get_tree().current_scene.add_child(pm)
	pm.global_transform = landmark.global_transform

func cmd_add_party_member(id: String, landmark_name: String):
	var pm = Actor.find(id)
	var landmark = Landmark.find(landmark_name)
	if pm != null and not pm.mode_stack.any(func(m): return m is ActorModeFollow):
		pm.push_mode(ActorModeFollow.new(party_stack[-1], 3.))
		party_stack.push_back(pm)
		return
	var pm_sheet = Saver.current_save.get_character_sheet(id)
	pm = Actor.from_sheet(pm_sheet)
	get_tree().current_scene.add_child(pm)
	pm.global_transform = landmark.global_transform
	pm.push_mode(ActorModeFollow.new(party_stack[-1], 3.))
	party_stack.push_back(pm)

func cmd_rm_party_member(id: String):
	printerr("Stub story operation!")
	pass

func cmd_heal_party():
	for pm in party_stack:
		pm.heal(9999)

func cmd_spawn_enemy(id: String, name: String, landmark_name: String):
	var landmark = Landmark.find(landmark_name)
	var enemy_factory: ActorSheet = load("res://database/enemy/%s.tres" % id);
	var enemy: Actor = Actor.from_sheet(enemy_factory)
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
			mode.goal_rotation = landmark.global_rotation.y
			mode.do_rotate = true
		"glide", _:
			mode = ActorModeMoveTo.new(actor, landmark)
	actor.push_mode(mode)

func cmd_actor_cargo(actor_name: String, carrier_name: String):
	var actor: Actor = Actor.find(actor_name)
	var carrier: Actor = Actor.find(carrier_name)
	actor.push_mode(ActorModeCargo.new(carrier))

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
		await follower.push_mode(ActorModeFollow.new(followee, 1.))
	).call()

func cmd_actor_stop(actor_name: String):
	(func():
		var actor = Actor.find(actor_name)
		await actor.pop_mode()
	).call()

func cmd_actor_wait(actor_name: String):
	(func():
		print("Wait for %s..." % actor_name)
		var lock = await lock.shared_lock()
		var actor = Actor.find(actor_name)
		if actor.top_mode is ActorModeStoryCanary:
			print("Already idle")
			lock.call()
			return
		while actor.top_mode is not ActorModeStoryCanary and actor.mode_stack.any(func(m): return m is ActorModeStoryCanary):
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
		while len(actor.mode_stack) > index:
			await actor.pop_mode()
	).call()

func cmd_play_sound(sound: String):
	print("Stub story operation")

func cmd_fade_out(to_fade: String):
	(func():
		var lock = await lock.shared_lock()
		await Fader.fade_out(to_fade)
		lock.call()
	).call()

func cmd_fade_in():
	(func():
		var lock = await lock.shared_lock()
		await Fader.fade_in()
		lock.call()
	).call()

func cmd_start_battle():
	var battlefield: Battlefield = Battlefield.find()
	battlefield.battle()

func cmd_join_battle(actor_name: String, as_enemy: bool = false):
	var actor: Actor = Actor.find(actor_name)
	if not actor:
		return
	var battlefield: Battlefield = Battlefield.find()
	if as_enemy:
		battlefield.enemies.push_back(actor)
	else:
		battlefield.players.push_back(actor)

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
	var enemy: Actor = Actor.find(enemy_name)
	if not enemy:
		return
	enemy.state = state
	if enemy.planned_pattern:
		enemy.planned_pattern = null
		enemy.battlefield.assign_patterns()

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

var new_scene = false

func cmd_set_weather(weather_name: String):
	var weather: Weather = load("res://database/weather/%s.tres" % weather_name)
	var sun: DirectionalLight3D = get_tree().current_scene.get_node("%Sun")
	var env: WorldEnvironment = get_tree().current_scene.get_node("%WorldEnvironment")
	create_tween().tween_property(sun, "light_color", weather.sun_color, 10. if not new_scene else 0.)
	create_tween().tween_property(sun, "rotation_degrees", weather.sun_angle, 10. if not new_scene else 0.)
	env.environment = weather.environment

func cmd_confidant_level(confidant: String, level: int):
	new_line.emit("This would level up a social link, if it was implemented.", [])

func cmd_junction_next_room(direction: int) -> String:
	var map: DungeonMap = get_tree().current_scene.get_node("%DungeonMap")
	if not map.state in [DungeonMap.STATE.JUNCTION, DungeonMap.STATE.HALLWAY_TO_JUNCTION, DungeonMap.STATE.WAIT_FOR_JUNCTION]:
		return "N/A"
	if not map.are_connected(map.current_position, map.current_position + Vector2i(direction, 1)):
		return "N/A"
	var room: MapRoom = map.map.get(map.current_position + Vector2i(direction, 1))
	if not is_instance_valid(room):
		return "N/A"
	return map.name_room(room.room_type)

func cmd_junction_current_room() -> String:
	var map: DungeonMap = get_tree().current_scene.get_node("%DungeonMap")
	if not map.state in [DungeonMap.STATE.ROOM, DungeonMap.STATE.HALLWAY_TO_ROOM, DungeonMap.STATE.WAIT_FOR_ROOM]:
		return "N/A"
	var room: MapRoom = map.map.get(map.current_position)
	if not is_instance_valid(room):
		return "N/A"
	return map.name_room(room.room_type)

func cmd_show(name: String):
	var h = Hidable.find(name)
	if h:
		h.show()

func cmd_hide(name: String):
	var h = Hidable.find(name)
	if h:
		h.hide()

func cmd_save(in_place: bool):
	(func():
		var handle = await lock.exclusive_lock()
		Saver.save(in_place)
		handle.call()
		# This prevents us from accidentally forgetting to set things back up after saving!
		Saver.load(Saver.parent_save)
	).call()

#func obs_party(_name, new_value: Array[String]):
	#if len(new_value) == 0:
		#printerr("The party can't be empty")
		#return
	#pass

#func obs_gamemode(_name, new_value: String):
	#print("Stub story operation")
	#pass
