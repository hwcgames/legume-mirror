extends ActorPredicate
class_name PredicateAlive

@export var dead: bool = false

func test(actor: Actor, battlefield: Battlefield) -> bool:
	return actor.sheet.alive != dead
