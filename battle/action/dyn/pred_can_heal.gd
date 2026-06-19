extends ActorPredicate
class_name PredicateCanHeal

func test(actor: Actor, battlefield: Battlefield) -> bool:
	return actor.hp < actor.hp_component.max
