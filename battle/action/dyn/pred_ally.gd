extends ActorPredicate
class_name PredicateAlly

func test(actor: Actor, battlefield: Battlefield) -> bool:
	return actor in battlefield.players
