extends Skillset
class_name SkillsetUnskilled

func label(_party_member: PartyMember) -> String:
	return "Unskilled"

func tooltip(_p: PartyMember):
	return "Showcase your special talent."

func button(_party_member: PartyMember) -> Button:
	var b = Button.new()
	b.text = self.label(_party_member)
	b.tooltip_text = tooltip(_party_member)
	b.disabled = true
	b.size_flags_horizontal = Control.SIZE_FILL
	return b

func subplanner(_party_member: PartyMember) -> SubPlanner:
	return UnskilledPlanner.new()

class UnskilledPlanner extends SubPlanner:
	func choose() -> BattleActionPlan:
		return null
	func show_toplevel():
		return
