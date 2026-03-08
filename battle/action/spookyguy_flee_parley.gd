extends ParleyAction
class_name ParleyTutorialFlee

func label() -> String:
	return "Rescue"

func allowed(party_member: PartyMember) -> bool:
	return true

func display(party_member: PartyMember) -> bool:
	return enemy.state == 2

func plan(battle_planner: BattlePlanner) -> BattleActionPlan:
	return TutorialFleePlan.new(enemy)

class TutorialFleePlan extends BattleActionPlan:
	var enemy: Enemy
	func _init(enemy: Enemy):
		self.enemy = enemy
	func go(party_member: PartyMember):
		Actor.find("casey").push_mode(ActorModeCargo.new(party_member))
		Storyteller.choose_if_available(["cipher attempts to flee"])
		enemy.state = 2
		enemy.pick_pattern()
		await party_member.battlefield.top
		enemy.take_damage(9999999)
		pass
