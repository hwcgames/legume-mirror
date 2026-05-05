@abstract
extends BattleAction
class_name ParleyAction

var enemy: Actor

@abstract func label() -> String

func description() -> String:
	return "Its effect is a mystery."

@abstract func allowed(party_member: Actor) -> bool

@abstract func display(party_member: Actor) -> bool
