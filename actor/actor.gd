extends CharacterBody3D
class_name Actor

@export var human_name: StringName = name 
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

var mode_stack: Array[ActorMode] = []

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
			if not rule.compute_attrs(self , attrs):
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
	var battle_idle = ActorIdle.new()
	battle.done.connect(done)
	battle.done.connect(func(_w): battle_idle.finished = true)
	push_mode(battle_idle)
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

var top_mode: ActorMode:
	get:
		var t = mode_stack.get(len(mode_stack) - 1)
		if t == null:
			t = ActorIdle.new()
			t.actor = self
			mode_stack = [t]
		return t

func _physics_process(delta: float):
	velocity = Vector3.ZERO
	var t := top_mode
	if not t.finished and not t.finishing:
		t._process(delta)
	while t.finished:
		if t.finishing:
			break;
		while t.finished and not t.finishing:
			pop_mode()
		t = top_mode
	move_and_slide()

func push_mode(mode: ActorMode) -> ActorMode:
	var old_mode = top_mode
	if old_mode != null:
		await old_mode._covered(mode)
	mode.actor = self
	mode_stack.push_back(mode)
	await mode._activate()
	return mode

func pop_mode() -> ActorMode:
	var mode = top_mode
	if mode.finishing:
		return mode
	mode.finishing = true
	await mode._deactivate()
	mode_stack.pop_back()
	mode.popped.emit()
	await top_mode._uncovered()
	return mode

func play(name: StringName, wait_for_arrival: bool = false, wait_for_completion: bool = false):
	await costume.play(name, wait_for_arrival, wait_for_completion)

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

func add_rule(rule: BattleRule) -> bool:
	for existing in sheet.rules:
		if existing.get_script() == rule.get_script():
			existing.merge(rule)
			return false
	sheet.rules.push_back(rule)
	rule._added(self )
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
	if costume != null:
		costume.play("dead")

func heal(amount: int):
	for rule in sheet.rules:
		if not rule.heal(self , amount):
			return
	sheet.hp.hp += amount

func _revived():
	for rule in sheet.rules:
		if not rule._revived(self ):
			return
	if costume != null:
		costume.play("idle")

func get_sp(amount: int):
	for rule in sheet.rules:
		if not rule.get_sp(self , amount):
			return
	sheet.party_component.sp.sp += amount

func use_sp(amount: int):
	for rule in sheet.rules:
		if not rule.use_sp(self , amount):
			return
	sheet.party_component.sp.sp -= amount

func begin():
	for rule in sheet.rules:
		if not rule.begin(self ):
			break
	await battle_component._begin(self)

func top():
	for rule in sheet.rules:
		if not rule.top(self ):
			break
	sheet.rules = sheet.rules.filter(func(r: BattleRule):
		var keep = r.stacks > 0
		if not keep:
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
