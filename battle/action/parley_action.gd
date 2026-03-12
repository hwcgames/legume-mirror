@abstract
extends BattleAction
class_name ParleyAction

var enemy: Enemy

@abstract func label() -> String

func description() -> String:
	return "Its effect is a mystery."

@abstract func allowed(party_member: PartyMember) -> bool

@abstract func display(party_member: PartyMember) -> bool
