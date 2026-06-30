extends RefCounted
class_name HpChange

enum ELEMENT {
	ENERGY = 1,
	MATTER = 2,
	CONCORD = 4,
	DISCORD = 8,
	FORCE = 16,
	TECH = 32,
	POINT = 64,
	WIDE = 128
}

var from: Actor
var to: Actor
var original_amount: int
var amount: int
var critical: bool
var alignment: int
var registers: Dictionary

func _init(from: Actor, to: Actor, amount: int, alignment: int = 0, critical: bool = false):
	self.from = from
	self.to = to
	self.original_amount = amount
	self.amount = amount
	self.alignment = alignment
	self.critical = critical
