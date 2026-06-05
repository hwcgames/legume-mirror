extends CharacterBody3D
class_name Actor

@export var human_name: StringName = name 
func _to_string() -> String:
	return human_name
@export var costume: Costume:
	set(new_costume):
		if costume != null:
			costume.hide()
			costume.queue_free()
		costume = new_costume
		if not is_ancestor_of(new_costume):
			if new_costume.is_inside_tree():
				new_costume.reparent(self , false)
			else:
				add_child(new_costume)
@export var interactable: Interactable
var head: Marker3D:
	get:
		return costume.head
var head_position: Vector3:
	get:
		return head.global_position


# Player flags
var leader: bool:
	get:
		return name == Storyteller.story.FetchVariable("leader")
var turns: int = 0
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
		var attrs = self.sheet.attrs.duplicate()
		for rule in sheet.rules:
			if not rule.compute_attrs(self, attrs):
				return attrs
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
	%Telegraph.hide()
	if is_instance_valid(sheet.party_component):
		add_to_group("party_member")
		PlayerManager.player_joined.connect(player_joined)
		PlayerManager.player_left.connect(player_left)
		if self != Storyteller.leader:
			for device in PlayerManager.get_player_indexes():
				player_joined(device)
	if interactable:
		interactable.choices.insert(0, "%s" % human_name)

func player_joined(n: int):
	if PlayerManager.get_player_device(n) == -1:
		return
	if self == Storyteller.leader:
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
	mode = MODE.IDLE
	if as_enemy or not is_instance_valid(sheet.party_component):
		battle_component = sheet.enemy_component
		await sheet.enemy_component._join_battle(self, battlefield)
	else:
		battle_component = sheet.party_component
		await sheet.party_component._join_battle(self, battlefield)
	joined_battle.emit(battlefield)
	for rule in sheet.rules:
		if not rule.join_battle(self ):
			break

static func find(actor_name: StringName) -> Actor:
	for node in Storyteller.get_tree().get_nodes_in_group("actor"):
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
	a.name = sheet.id if !is_instance_valid(existing) else sheet.id + "-" + str(randi())
	a.human_name = sheet.name
	a.costume = sheet.costume.instantiate()
	a.text_color = sheet.text_color
	a.bg_color = sheet.bg_color
	return a

signal new_rule(rule: BattleRule)

func add_rule(rule: BattleRule) -> bool:
	for existing in sheet.rules:
		if existing.get_script() == rule.get_script():
			existing.merge(rule)
			return false
	sheet.rules.push_back(rule)
	rule._added(self )
	new_rule.emit(rule)
	return true

func take_damage(amount: int):
	for rule in sheet.rules:
		if not rule.take_damage(self , amount):
			return
	sheet.hp.hp -= amount

func _died():
	for rule in sheet.rules:
		if not rule._died(self ):
			return

func heal(amount: int):
	for rule in sheet.rules:
		if not rule.heal(self , amount):
			return
	sheet.hp.hp += amount

func _revived():
	for rule in sheet.rules:
		if not rule._revived(self ):
			return

func get_sp(amount: int):
	for rule in sheet.rules:
		if not rule.get_sp(self , amount):
			return
	print("Get %s SP" % amount)
	sheet.party_component.sp.get_energy(amount)

func use_sp(amount: int):
	for rule in sheet.rules:
		if not rule.use_sp(self , amount):
			return
	print("Use %s SP" % amount)
	sheet.party_component.sp.use_energy(amount)

func begin():
	for rule in sheet.rules:
		if not rule.begin(self ):
			break
	await battle_component._begin(self)

func top():
	for rule in sheet.rules:
		if not rule.top(self ):
			break
		rule.changed.emit()
	sheet.rules = sheet.rules.filter(func(r: BattleRule):
		var keep = r.stacks != 0
		if not keep:
			r.removed.emit()
			r._removed(self )
		return keep)
	await battle_component._top(self)

func telegraph():
	for rule in sheet.rules:
		if not rule.telegraph(self ):
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
	for rule in sheet.rules:
		if not rule.player_action(self ):
			return
	await battle_component._player_action(self)

func setup_challenge(scene: PackedScene = load(sheet.party_component.skill_challenge_scene)) -> SkillChallenge:
	skill_challenge = scene.instantiate()
	skill_challenge.party_member = self
	%SkillChallengeParent.add_child(skill_challenge)
	return skill_challenge

func enemy_action():
	for rule in sheet.rules:
		if not rule.enemy_action(self ):
			break
	await battle_component._enemy_action(self)

func done(player_victory: bool):
	for rule in sheet.rules:
		if not rule.done(self , player_victory):
			break
	sheet.rules = sheet.rules.filter(func(r): return r.stacks > 0)
	await battle_component._done(self, player_victory)
	battlefield = null
	mode_done()

func snap_to_landmark(landmark: Landmark):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "goal_rotation", lerp_angle(goal_rotation, landmark.global_rotation.y, 1), 0.3)
	tween.parallel()
	tween.tween_property(self, "global_position", landmark.global_position, 0.3)
	tween.tween_callback(func():
		global_rotation = landmark.global_rotation)
	tween.play()
	await tween.finished
func snap_to_position(position: Vector3, rotation: float = INF):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position", position, 0.3)
	if is_finite(rotation):
		tween.parallel()
		tween.tween_property(self, "goal_rotation", lerp_angle(goal_rotation, rotation, 1), 0.3)
	tween.play()
	await tween.finished

func wait_for_idle():
	while mode not in [MODE.IDLE, MODE.HUMAN]:
		await new_mode







#region STATES
var captured: bool = false
signal new_mode(mode: int)
var mode: MODE = MODE.IDLE:
	set(m):
		mode = m
		if mode not in mode_start:
			printerr("ERROR: Unhandled mode %s!!!" % mode)
		mode_start[mode].call()
		new_mode.emit(mode)
enum MODE {
	IDLE,
	HUMAN,
	PATHING,
	NAIVE_WALKING,
	GLIDING,
	FOLLOWING,
	AUTOMOVING,
	CARGO,
}
var pose: String = "normal"


func _physics_process(delta: float):
	if mode not in mode_tick:
		printerr("ERROR: Unhandled mode %s!!!" % mode)
	velocity = Vector3.ZERO
	mode_tick[mode].call(delta)
	move_and_slide()

#region MODE IMPL
var mode_start: Dictionary[MODE, Callable] = {
	MODE.IDLE: func(): pass,
	MODE.HUMAN: func(): pass,
	MODE.PATHING: pathing_start,
	MODE.FOLLOWING: following_start,
	MODE.AUTOMOVING: func(): pass,
	MODE.CARGO: cargo_start
}
var mode_tick: Dictionary[MODE, Callable] = {
	MODE.IDLE: idle_tick,
	MODE.HUMAN: human_tick,
	MODE.PATHING: pathing_tick,
	MODE.FOLLOWING: following_tick,
	MODE.AUTOMOVING: automoving_tick,
	MODE.CARGO: cargo_tick
}
func mode_done():
	if is_instance_valid(battlefield):
		mode = MODE.IDLE
	elif is_instance_valid(automove_current):
		mode = MODE.AUTOMOVING
	elif leader:
		mode = MODE.HUMAN
	else:
		mode = MODE.IDLE

#region IDLE
var goal_rotation = 0.
func idle_tick(delta: float):
	if Vector2(velocity.x, velocity.z).length() > 0.02:
		goal_rotation = Vector3.FORWARD.signed_angle_to(velocity, Vector3.UP)
	global_rotation.y = move_toward(global_rotation.y, lerp_angle(global_rotation.y, goal_rotation, 1.), 4. * PI * delta)
	if is_on_floor():
		return
	velocity += Vector3.DOWN * 5.

#region HUMAN
var human_last_camera_rotation: float
func human_tick(delta: float):
	if captured:
		idle_tick(delta)
		return
	var camera = get_viewport().get_camera_3d()
	var input_rotation = camera.global_rotation.y
	var active_pcam = PhantomCameraManager.get_phantom_camera_hosts()[0].get_active_pcam()
	if active_pcam.has_meta("move_align"):
		input_rotation = (active_pcam.get_node(active_pcam.get_meta("move_align"))).global_rotation.y
	var input = MultiplayerInput.get_vector(PlayerManager.get_player_device(player), "left", "right", "down", "up")
	if input.length() < 0.1 or abs(angle_difference(input_rotation, human_last_camera_rotation)) < 0.5:
		human_last_camera_rotation = input_rotation
	var forward = Vector3.FORWARD.rotated(Vector3.UP, human_last_camera_rotation)
	var right = Vector3.RIGHT.rotated(Vector3.UP, human_last_camera_rotation)
	if player not in PlayerManager.player_data:
		return
	var movement = (forward * input.y + right * input.x) * 10.
	velocity += movement
	idle_tick(delta)

#region GLIDING
var glide_target: Vector3
var glide_speed: float
var glide_rotation: float = INF
func glide_to(target: Vector3, speed = 10., rotation = INF):
	glide_target = target
	glide_speed = speed
	glide_rotation = rotation
	mode = MODE.GLIDING
func glide_start():
	var glide_time = global_position.distance_to(glide_target) / glide_speed
	var t = create_tween()
	t.tween_property(self, "global_position", glide_target, glide_time)
	if is_finite(glide_rotation):
		t.parallel()
		t.tween_property(self, "global_rotation.y", lerp_angle(global_rotation.y, glide_rotation, 1.), glide_time)
	t.play()
	await t.finished
	if mode == MODE.GLIDING:
		mode_done()

#region FOLLOWING
var follow_target: Actor
var follow_speed: float = 10.
var follow_distance: float
var follow_history: Array[Vector3]
func follow_actor(actor: Actor, at_distance: float = 3., at_speed: float = 10.):
	follow_distance = at_distance
	follow_speed = at_speed
	follow_target = actor
	mode = MODE.FOLLOWING
	await new_mode
func following_start():
	follow_history = [follow_target.global_position]
func following_tick(delta: float):
	if follow_history.is_empty() or follow_history[-1].distance_to(follow_target.global_position) > 0.1:
		follow_history.push_back(follow_target.global_position)
	var speed_this_frame = follow_speed * delta
	while (not follow_history.is_empty()) and global_position.distance_to(follow_history[0]) < speed_this_frame:
		follow_history.pop_front()
	if not follow_history.is_empty():
		velocity = global_position.direction_to(follow_history[0]) * follow_speed


#region PATHING
var pathing_speed: float = 10.
func pathfind_to(target: Vector3, rotation: float = INF):
	pathing_target = target
	pathing_rotation = rotation
	mode = MODE.PATHING
	await new_mode
var pathing_target: Vector3
var pathing_rotation: float
func pathing_start():
	navigation.target_position = pathing_target
	navigation.navigation_finished.connect(func():
		if mode == MODE.PATHING:
			mode_done()
			if is_finite(pathing_rotation):
				await get_tree().process_frame
				goal_rotation = pathing_rotation
				velocity = Vector3.ZERO)
func pathing_tick(delta: float):
	var next_pos = navigation.get_next_path_position()
	velocity = (next_pos - global_position).normalized() * pathing_speed
	idle_tick(delta)

#region AUTOMOVING
func automove_along(automove: Automove):
	automove_current = automove
	mode = MODE.AUTOMOVING
	while is_instance_valid(automove_current):
		await new_mode
var automove_current: Automove
func automoving_tick(_delta: float):
	if !is_instance_valid(automove_current) and mode == MODE.AUTOMOVING:
		mode_done()
	automove_current.apply_to_actor(self)
	if is_instance_valid(automove_current.next_automove):
		automove_current = automove_current.next_automove
	elif is_instance_valid(automove_current.next_seam) \
		and is_instance_valid(automove_current.next_seam.partner) \
		and is_instance_valid(automove_current.next_seam.partner.automoves.get(automove_current.next_seam_key)):
		automove_current = automove_current.next_seam.partner.automoves.get(automove_current.next_seam_key)
	else:
		automove_current = null

#region CARGO
func cargo(carrier: Actor):
	cargo_carrier = carrier
	mode = MODE.CARGO
var cargo_carrier: Actor
func cargo_start():
	var colliders = get_children()\
		.filter(func(c): return c is CollisionShape3D and not c.disabled)\
		.map(func(c): return c as CollisionShape3D)
	for c in colliders:
		c.disabled = true
	hide()
	await new_mode # Our own new_mode
	await new_mode # When this mode ends
	for c in colliders:
		c.disabled = false
	show()
func cargo_tick(_delta: float):
	global_transform = cargo_carrier.global_transform
