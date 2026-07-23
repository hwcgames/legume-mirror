extends CharacterBody3D
class_name Actor

@export var human_name: StringName = name
func _to_string() -> String:
	return human_name
@export var costume: Costume:
	set(new_costume):
		if not is_instance_valid(new_costume):
			return
		if costume != null:
			costume.hide()
			costume.queue_free()
		costume = new_costume
		%Afterimager.target = costume
		if not is_ancestor_of(new_costume):
			if new_costume.is_inside_tree():
				new_costume.reparent(self, false)
			else:
				add_child(new_costume)
@export var interactable: Interactable
var head: Marker3D:
	get:
		return costume.head
var head_position: Vector3:
	get:
		return head.global_position
## Used to store saved positions... or, perhaps, anything else.
var registers: Dictionary = {}

# Player flags
var leader: bool:
	get:
		return name == Storyteller.find().story.FetchVariable("leader")
var turns: int = 0:
	set(new_turns):
		turns = new_turns
		if turns <= 0:
			out_of_turns.emit()
signal out_of_turns
var player: int = 0
var skill_challenge: SkillChallenge
var battle_planner: BattlePlanner
var home_landmark: Marker3D
var device_index:
	get:
		return PlayerManager.get_player_device(player)

# Enemy flags
var state: int = 0
var planned_pattern: BulletPattern

var battle_component: BattleComponent
var battlefield: Battlefield

@onready var navigation: NavigationAgent3D = %NavigationAgent3D

@export var text_color: Color
@export var bg_color: Color
@export var sheet: ActorSheet
var alive:
	get:
		return sheet.alive
var lock: Locks = Locks.new()
var computed_attrs: CombatAttributes:
	get:
		var attrs = self.sheet.compute_attrs()
		#for rule in sheet.get_rules():
			#if not rule.compute_attrs(self, attrs):
				#return attrs
		return attrs
var hp_component: HealthComponent:
	get:
		return sheet.hp
	set(hp):
		sheet.hp = hp
var hp: float:
	get:
		return hp_component.hp
	set(hp):
		hp_component.hp = hp
var sp_component: EnergyComponent:
	get:
		if is_instance_valid(sheet.party_component):
			return sheet.party_component.sp
		else:
			return null
	set(sp):
		if is_instance_valid(sheet.party_component):
			sheet.party_component.sp = sp
		else:
			return null
var sp: float:
	get:
		if is_instance_valid(sp_component):
			return sp_component.sp
		else:
			return 0
	set(sp):
		if is_instance_valid(sp_component):
			sp_component.sp = sp

func _ready():
	add_to_group("actor")
	add_to_group("story_listener")
	%Afterimager.target = costume
	goal_rotation = global_rotation.y
	%Telegraph.hide()
	if is_instance_valid(sheet.party_component):
		add_to_group("party_member")
		PlayerManager.player_joined.connect(player_joined)
		PlayerManager.player_left.connect(player_left)
		if self != Storyteller.find().leader:
			for device in PlayerManager.get_player_indexes():
				player_joined(device)
	if interactable:
		interactable.choices.insert(0, "%s" % sheet.id)

func wants_line(line: String, tags: Array[String]) -> bool:
	return do_line(line, tags) is Callable
func take_line(line: String, tags: Array[String]):
	await do_line(line, tags).call()
func do_line(line: String, tags: Array[String]):
	match Array(line.split(" ", false)):
		["/", name, "appear", var landmark_name]:
			var landmark: Landmark = Landmark.find(landmark_name)
			if !is_instance_valid(landmark):
				print("Can't find landmark %s" % landmark_name)
				return null
			return func():
				global_transform = landmark.global_transform
				goal_rotation = landmark.global_rotation.y
				if active_component is ActorUninit:
					mode_done()
		["/", name, "disappear"]:
			return func():
				global_position += Vector3(0, 1000, 0)
				active_component = %Component/Uninit
		["/", name, "capture"]:
			return func():
				captured = true
		["/", name, "release"]:
			return func():
				captured = false
		["/", name, "wait"]:
			return func():
				while not (active_component is ActorUninit\
				or active_component is ActorIdle\
				or active_component is ActorHuman\
				or active_component is ActorFollow):
					await new_mode
		["/", name, "die"]:
			return func():
				hp_change(HpChange.new(self, self, -999999))
		["/", name, "heal"]:
			return func():
				hp_change(HpChange.new(self, self, 999999))
		["/", name, "float"]:
			return func():
				gravity = false
		["/", name, "fall"]:
			return func():
				gravity = true
		["/", name, "state", var n]:
			var state_n := int(n)
			return func():
				state = state_n
				if planned_pattern and is_instance_valid(battlefield):
					planned_pattern = null
					battlefield.assign_patterns()
		["/", name, "root", var landmark_name]:
			var landmark := Landmark.find(landmark_name)
			if !is_instance_valid(landmark):
				printerr("WARNING: No landmark %s" % landmark_name)
				return null
			return func():
				root(landmark)
		["/", name, "follow", "path", var automove_name]:
			var automove: Automove = Automove.find(self, automove_name)
			if !is_instance_valid(automove):
				printerr("WARNING: No automove %s" % automove_name)
				return null
			return func():
				automove_along(automove)
		["/", name, "stop"]:
			return func():
				mode_done()
		pass
	return null

func player_joined(n: int):
	if PlayerManager.get_player_device(n) == -1:
		return
	if self == Storyteller.find().leader:
		return
	if self.player != 0:
		return
	for pm in get_tree().get_nodes_in_group("party_member"):
		if pm == self:
			continue
		if n == pm.player:
			return
	player = n

func player_left(n: int):
	if self.player == n:
		self.player = 0

signal joined_battle(Battlefield)

func join_battle(battle: Battlefield, as_enemy: bool = false):
	self.battlefield = battle
	battle.begin.connect(begin)
	battle.top.connect(top)
	battle.telegraph.connect(telegraph)
	battle.player_action.connect(player_action)
	battle.enemy_action.connect(enemy_action)
	battle.done.connect(done)
	var was_uninit = active_component is ActorUninit
	active_component = %Component/Idle
	if as_enemy or not is_instance_valid(sheet.party_component):
		battle_component = sheet.enemy_component
		await sheet.enemy_component._join_battle(self, battlefield)
	else:
		battle_component = sheet.party_component
		await sheet.party_component._join_battle(self, battlefield)
	registers["position_before_battle"] = global_position
	registers["rotation_before_battle"] = global_rotation.y
	registers["transform_before_battle"] = global_transform
	registers["parent_before_battle"] = get_parent()
	visual_reparent(battlefield)
	if battlefield.phase == Battlefield.PHASE.SETUP:
		if not was_uninit:
			snap_to_landmark(home_landmark, true)
		else:
			global_transform = home_landmark.global_transform
			goal_rotation = home_landmark.global_rotation.y
			var t = create_tween()
			t.tween_property(self, "scale", scale, 0.4).from(Vector3.ZERO).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			t.play()
			mode_done()
	else:
		global_position = home_landmark.global_position
		global_rotation = home_landmark.global_rotation
		goal_rotation = home_landmark.global_rotation.y
	joined_battle.emit(battlefield)
	for rule in sheet.get_rules():
		if not await rule.join_battle(self):
			break

static func find(actor_name: StringName) -> Actor:
	for node in Storyteller.find().get_tree().get_nodes_in_group("actor"):
		if node.name == actor_name:
			return node
	return null

static func from_sheet(sheet: ActorSheet) -> Actor:
	var a: Actor = preload("uid://dsmw0etg767jy").instantiate();
	if sheet.saved:
		a.sheet = sheet
	else:
		a.sheet = sheet.copy()
	if is_instance_valid(sheet.enemy_component):
		a.sheet.enemy_component = sheet.enemy_component.copy()
	var existing = Actor.find(sheet.id)
	if not sheet.id.is_empty():
		a.name = sheet.id if !is_instance_valid(existing) else sheet.id + "-" + str(randi())
	else:
		a.name = sheet.resource_path.rsplit("/", false, 2)[-1].split(".", false, 2)[0]
	a.human_name = sheet.name
	a.costume = sheet.costume.instantiate()
	a.text_color = sheet.text_color
	a.bg_color = sheet.bg_color
	return a

signal new_rule(rule: BattleRule)

func add_rule(rule: BattleRule) -> bool:
	var added = sheet.add_rule(rule)
	if added:
		rule._added(self)
		new_rule.emit(rule)
	return added

func hp_change(instance: HpChange):
	for rule in sheet.get_rules():
		if not rule.hp_change(self, instance):
			return
	sheet.hp.apply(instance)

func _died():
	for rule in sheet.get_rules():
		if not rule._died(self):
			return

func _revived():
	for rule in sheet.get_rules():
		if not rule._revived(self):
			return

func sp_change(change: SpChange):
	for rule in sheet.get_rules():
		if not rule.sp_change(self, change):
			return
	sheet.party_component.sp.apply(change)


func begin():
	for rule in sheet.get_rules():
		if not await rule.begin(self):
			break
	await battle_component._begin(self)

func top():
	for rule in sheet.get_rules():
		if not await rule.top(self):
			break
		rule.changed.emit()
	sheet.rules = sheet.rules.filter(func(r: BattleRule):
		var keep = r.stacks != 0
		if not keep:
			r.removed.emit()
			r._removed(self)
		return keep)
	await battle_component._top(self)

func telegraph():
	for rule in sheet.get_rules():
		if not await rule.telegraph(self):
			break
	await battle_component._telegraph(self)

func show_telegraph():
	for child in %TelegraphParent.get_children():
		child.queue_free()
	if not planned_pattern:
		%Telegraph.hide()
		return
	var telegraph = planned_pattern.telegraph_scene.instantiate()
	%TelegraphParent.add_child(telegraph)
	%Telegraph.show()

func player_action():
	for rule in sheet.get_rules():
		if not await rule.player_action(self):
			return
	await battle_component._player_action(self)

func setup_challenge(scene: PackedScene = load(sheet.party_component.skill_challenge_scene)) -> SkillChallenge:
	skill_challenge = scene.instantiate()
	skill_challenge.party_member = self
	%SkillChallengeParent.add_child(skill_challenge)
	return skill_challenge

func enemy_action():
	for rule in sheet.get_rules():
		if not await rule.enemy_action(self):
			break
	await battle_component._enemy_action(self)

func done(player_victory: bool):
	for rule in sheet.get_rules():
		if not await rule.done(self, player_victory):
			break
	sheet.rules = sheet.rules.filter(func(r): return r.stacks > 0)
	await battle_component._done(self, player_victory)
	battlefield = null
	visual_reparent(registers["parent_before_battle"])
	await snap_to_position(registers["position_before_battle"], registers["rotation_before_battle"], true)
	mode_done()

func snap_to_landmark(landmark: Node3D, afterimages: bool = false):
	#var tween = create_tween()
	#tween.set_ease(Tween.EASE_IN_OUT)
	#tween.set_trans(Tween.TRANS_QUAD)
	#tween.tween_property(self, "goal_rotation", lerp_angle(goal_rotation, landmark.global_rotation.y, 1), 0.3)
	#tween.parallel()
	#tween.tween_property(self, "global_position", landmark.global_position, 0.3)
	#tween.tween_callback(func():
		#global_rotation = landmark.global_rotation)
	#tween.play()
	#await tween.finished
	await snap_to_position(landmark.global_position, landmark.global_rotation.y, afterimages)
	global_transform = landmark.global_transform
func snap_to_position(position: Vector3, rotation: float = INF, afterimages: bool = false):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position", position, 0.3)
	if is_finite(rotation):
		tween.parallel()
		tween.tween_property(self, "goal_rotation", lerp_angle(goal_rotation, rotation, 1), 0.2)
	tween.play()
	var atween = create_tween()
	if afterimages:
		var count = round(global_position.distance_to(position)) * 2
		for n in range(count + 5):
			atween.tween_callback(func(): afterimage_stationary(0.2)).set_delay(0 if n == 0 else (0.2 / count))
		atween.play()
	await tween.finished
	atween.kill()

func wait_for_idle():
	while not ((active_component is ActorIdle) or (active_component is ActorHuman)):
		await new_mode

var goal_rotation: float

var components: Array[ActorComponent]:
	get:
		var out: Array[ActorComponent] = []
		for component in %Component.get_children():
			out.push_back(component as ActorComponent)
		return out
@export var active_component: ActorComponent:
	set(new_active):
		if new_active == active_component:
			return
		if is_instance_valid(active_component):
			active_component._deactivate()
		print("{0} -> {1}".format([active_component, new_active]))
		active_component = new_active
		active_component._activate()
		new_mode.emit(active_component)

var skip_physics: bool = false

func _physics_process(delta: float):
	if global_position.y < -1000:
		queue_free()
	while !is_instance_valid(active_component):
		mode_done()
		return
	if active_component._reset_velocity():
		velocity = Vector3.ZERO
	active_component._active(delta)
	if not skip_physics:
		move_and_slide()

func mode_done():
	print("{human_name} {active_component} mode done".format(self))
	var party_pos = Storyteller.find().party_stack.find(self)
	print(%Component/Automove.current)
	if is_instance_valid(battlefield):
		active_component = %Component/Idle
	elif is_instance_valid(%Component/Automove.current):
		active_component = %Component/Automove
	elif captured:
		active_component = %Component/Idle
	elif leader:
		active_component = %Component/Human
	elif party_pos != -1:
		follow_actor(Storyteller.find().party_stack[party_pos - 1])
	else:
		active_component = %Component/Idle
	print("DONE -> {active_component}".format(self))

var captured: bool = false:
	set(new_cap):
		if new_cap == captured:
			return
		captured = new_cap
		mode_done()
var gravity: bool = true
signal new_mode(mode: ActorComponent)
var pose: String = "normal"

func glide_to(target, speed = 10., rotation = INF, afterimage_duration: float = 0., afterimage_count: int = 0):
	var glide: ActorGlide = %Component/Glide
	glide.target = (func(): return target.global_position if is_instance_valid(target) else Vector3.ZERO) if target is Node3D else (func(): return target)
	glide.speed = speed
	glide.rotation = rotation
	glide.afterimage_duration = afterimage_duration
	glide.afterimage_count = afterimage_count
	active_component = glide
	await new_mode
func follow_actor(actor: Actor, at_distance: float = 1.5, at_speed: float = 10.):
	var follow: ActorFollow = %Component/Follow
	follow.distance = at_distance
	follow.speed = at_speed
	follow.target = actor
	active_component = follow
	await new_mode
func pathfind_to(target: Vector3, rotation: float = INF):
	var pathing: ActorPathing = %Component/Pathing
	pathing.target = target
	pathing.rotation = rotation
	active_component = pathing
	await new_mode
func automove_along(automove_node: Automove):
	var automove: ActorAutomove = %Component/Automove
	automove.current = automove_node
	active_component = automove
	while is_instance_valid(automove.current):
		await new_mode
func cargo(carrier: Actor):
	var cargo: ActorCargo = %Component/Cargo
	cargo.carrier = carrier
	active_component = cargo
func root(to_node: Node3D):
	%Component/Rooted.root = to_node
	active_component = %Component/Rooted

func afterimage_stationary(duration: float = 1.) -> Node3D:
	var tween = create_tween()
	var image = %Afterimager.create_afterimage(
	func(m: BaseMaterial3D):
		if m is StandardMaterial3D:
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
			#m.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
			tween.tween_property(m, "albedo_color", Color(m.albedo_color, 0.), duration).from(Color(m.albedo_color, 0.5)).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			tween.parallel()
	, func(sprite: SpriteBase3D):
		tween.tween_property(sprite, "modulate", Color(sprite.modulate, 0.), duration).from(Color(sprite.modulate, 0.5)).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.parallel()
	)
	var camera = get_viewport().get_camera_3d()
	var camera_transform = camera.global_transform if is_instance_valid(camera) else Transform3D.IDENTITY
	var forward = camera_transform.basis * Vector3.FORWARD
	image.global_position += forward * 0.1
	tween.tween_callback(func(): image.queue_free()).set_delay(duration)
	tween.play()
	return image

func visual_reparent(new_parent: Node3D):
	if new_parent == get_parent():
		return
	if !is_instance_valid(get_viewport().get_camera_3d()):
		reparent(new_parent, true)
		reset_physics_interpolation()
	var transform_relative_to_camera: Transform3D = global_transform * get_viewport().get_camera_3d().global_transform.inverse()
	var new_parent_camera = new_parent.get_viewport().get_camera_3d()
	var new_transform: Transform3D = new_parent_camera.global_transform * transform_relative_to_camera if is_instance_valid(new_parent_camera) else Transform3D.IDENTITY
	global_transform = new_transform
	reparent(new_parent, true)
	reset_physics_interpolation()
