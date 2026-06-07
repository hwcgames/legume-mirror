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
	active_component = %Component/Idle
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
		if not rule.begin(self):
			break
	await battle_component._begin(self)

func top():
	for rule in sheet.rules:
		if not rule.top(self):
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
		if not rule.telegraph(self):
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

func snap_to_landmark(landmark: Node3D):
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

func _physics_process(delta: float):
	while !is_instance_valid(active_component):
		mode_done()
		return
	if active_component._reset_velocity():
		velocity = Vector3.ZERO
	active_component._active(delta)
	
	move_and_slide()

func mode_done():
	print("{human_name} {active_component} mode done".format(self))
	var party_pos = Storyteller.party_stack.find(self)
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
		follow_actor(Storyteller.party_stack[party_pos-1])
	else:
		active_component = %Component/Idle
	print("-> {active_component}".format(self))

var captured: bool = false:
	set(new_cap):
		if new_cap == captured:
			return
		captured = new_cap
		mode_done()
signal new_mode(mode: ActorComponent)
var pose: String = "normal"

func wants_line(line: String, tags: Array[String]) -> bool:
	return components.any(func(c: ActorComponent): return c.wants_line(line, tags))
func take_line(line: String, tags: Array[String]):
	var idx = components.find_custom(func(c: ActorComponent): return c.wants_line(line, tags))
	components[idx].take_line(line, tags)

func glide_to(target, speed = 10., rotation = INF):
	var glide: ActorGlide = %Component/Glide
	glide.target = (func(): return target.global_position) if target is Node3D else (func(): return target)
	glide.speed = speed
	glide.rotation = rotation
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

##region CARGO
