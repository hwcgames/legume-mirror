extends BattleAction
class_name BattleActionHold

class HoldActionPlan extends BattleActionPlan:
	func go(party_member: Actor):
		party_member.turns += 1

func plan(_battle_planner: BattlePlanner) -> BattleActionPlan:
	return HoldActionPlan.new()
