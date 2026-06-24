extends ParleyAction
class_name ParleyTutorialFlee

func label() -> String:
	return "Rescue"

func description() -> String:
	return "Grab the stranger and run."

func allowed(party_member: Actor, source: Object) -> bool:
	return true

func display(party_member: Actor) -> bool:
	return enemy.state == 2

func plan(battle_planner: BattlePlanner, source: Object) -> BattleActionPlan:
	return TutorialFleePlan.new(enemy)

class TutorialFleePlan extends BattleActionPlan:
	var enemy: Actor
	func _init(enemy: Actor):
		self.enemy = enemy
	func go(party_member: Actor):
		Actor.find("casey").cargo(party_member)
		Storyteller.find().choose(["%s attempts to flee" % party_member.name])
		enemy.state = 2
		enemy.planned_pattern = null
		await enemy.battlefield.assign_patterns()
		await party_member.battlefield.top
		enemy.hp_change(HpChange.new(party_member, enemy, 9999999))
		pass
