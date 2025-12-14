extends Node

var locks: Dictionary[int, Locks] = {}

func lock(index: int) -> Locks:
	if index not in locks:
		locks[index] = Locks.new()
	return locks[index]
