extends ActorPredicate
class_name PredicateEnemy

func test(actor: Actor, battlefield: Battlefield) -> bool:
	return actor in battlefield.enemies
