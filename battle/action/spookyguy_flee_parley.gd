extends ParleyAction
class_name ParleyTutorialFlee

func label() -> String:
	return "Rescue"

func description() -> String:
	return "Grab the stranger and run."

func allowed(party_member: Actor) -> bool:
	return true

func display(party_member: Actor) -> bool:
	return enemy.state == 2

func plan(battle_planner: BattlePlanner) -> BattleActionPlan:
	return TutorialFleePlan.new(enemy)

class TutorialFleePlan extends BattleActionPlan:
	var enemy: Actor
	func _init(enemy: Actor):
		self.enemy = enemy
	func go(party_member: Actor):
		Actor.find("casey").push_mode(ActorModeCargo.new(party_member))
		Storyteller.choose_if_available(["cipher attempts to flee"])
		enemy.state = 2
		enemy.planned_pattern = null
		await enemy.battlefield.assign_patterns()
		await party_member.battlefield.top
		enemy.take_damage(9999999)
		pass
