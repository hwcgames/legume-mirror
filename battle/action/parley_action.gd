@abstract
extends BattleAction
class_name ParleyAction

@abstract func label(enemy: Enemy) -> String

@abstract func allowed(enemy: Enemy) -> bool
