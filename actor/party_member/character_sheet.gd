extends Resource
class_name CharacterSheet

@export var id: String
@export var name: StringName = "Player"
@export var hp: HealthComponent
@export var sp: EnergyComponent
@export var attrs: CombatAttributes = CombatAttributes.new()

@export var costume: PackedScene = preload("uid://c4r2ey7i7ooq3")
@export_file_path("*.tscn") var skill_challenge_scene = "uid://bbpp48kcropih"
@export_file_path("*.tscn") var battle_planner_scene = "uid://d21yudvneounm"
@export var basic_attack: BattleAction = BattleActionBasicAttack.new()
@export var skillset: Skillset = SkillsetUnskilled.new()

func copy() -> CharacterSheet:
	var new = self.duplicate()
	new.skillset = self.skillset.duplicate()
	new.basic_attack = self.basic_attack.duplicate()
	new.attrs = self.attrs.duplicate()
	return new
