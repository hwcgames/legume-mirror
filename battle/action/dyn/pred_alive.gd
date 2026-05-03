extends ActorPredicate
class_name PredicateAlive

func test(actor: Actor, battlefield: Battlefield) -> bool:
	return actor.sheet.alive
