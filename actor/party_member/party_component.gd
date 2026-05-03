extends Resource
class_name PartyComponent

@export var sp: EnergyComponent

@export_file_path("*.tscn") var skill_challenge_scene = "uid://bbpp48kcropih"
@export_file_path("*.tscn") var battle_planner_scene = "uid://d21yudvneounm"
@export var basic_attack: BattleAction = BattleActionBasicAttack.new()
@export var skillset: Skillset = SkillsetUnskilled.new()

func copy() -> PartyComponent:
	var new = self.duplicate()
	new.skillset = self.skillset.duplicate()
	new.basic_attack = self.basic_attack.duplicate()
	new.attrs = self.attrs.duplicate()
	return new
