@abstract
extends Resource
class_name Skillset

@abstract func label(party_member: PartyMember) -> String
@abstract func tooltip(party_member: PartyMember) -> String

func button(party_member: PartyMember) -> Button:
	var b = Button.new()
	b.text = self.label(party_member)
	b.tooltip_text = tooltip(party_member)
	b.size_flags_horizontal = Control.SIZE_FILL
	return b

@abstract func subplanner(party_member: PartyMember) -> SubPlanner
