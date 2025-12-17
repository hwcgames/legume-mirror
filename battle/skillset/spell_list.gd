extends Skillset
class_name SkillsetSpellList

@export var name: StringName = "Magic"
@export var spell_list: Array[BattleAction] = []

func label(party_member: PartyMember) -> String:
	return name

@export var subplanner_scene: PackedScene = preload("uid://bgym47jf3uuxo")

func subplanner(party_member: PartyMember) -> SubPlanner:
	var subplanner: SpellListPlanner = subplanner_scene.instantiate()
	subplanner.spells = spell_list
	return subplanner
