extends Automove
class_name AutomoveBattle

@export var battlefield: Battlefield

#func mode_for_actor(actor: Actor) -> ActorMode:
	#var mode = ActorModeStoryCanary.new()
	#for player in get_tree().get_nodes_in_group("party_member"):
		#battlefield.players.push_back(player)
	#battlefield.battle.call_deferred()
	#battlefield.done.connect(func(_w):
		#mode.finished = true)
	#return mode
func apply_to_actor(actor: Actor):
	for player in Storyteller2.party_stack:
		battlefield.players.push_back(player)
	actor.battlefield = battlefield
	battlefield.battle.call_deferred()
	battlefield.done.connect(func(_w):
		actor.mode_done())
	actor.mode_done()
