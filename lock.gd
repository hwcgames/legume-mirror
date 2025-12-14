extends RefCounted
class_name Locks

var shared_locks: int = 0
var exclusive_locked: bool = false

signal shared_take
signal exclusive_take
signal shared_free
signal exclusive_free

func shared_lock():
	while exclusive_locked:
		await exclusive_free
	shared_locks += 1;
	shared_take.emit()
	return func():
		if shared_locks == 0:
			printerr("Shared lock double-freed!")
			return
		shared_locks -= 1
		if shared_locks == 0:
			shared_free.emit()

func exclusive_lock():
	await wait_for_clear()
	exclusive_locked = true
	exclusive_take.emit()
	return func():
		if !exclusive_locked:
			printerr("Exclusive lock double-freed!")
			return
		exclusive_locked = false
		exclusive_free.emit()

func wait_for_clear():
	while shared_locks > 0 or exclusive_locked:
		while shared_locks > 0:
			await shared_free
		while exclusive_locked:
			await exclusive_free
