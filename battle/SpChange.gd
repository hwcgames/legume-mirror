extends RefCounted
class_name SpChange

var from: Actor
var to: Actor
var original_amount: int
var amount: float
var registers: Dictionary

func _init(from: Actor, to: Actor, amount: float):
	self.from = from
	self.to = to
	self.original_amount = amount
	self.amount = amount
