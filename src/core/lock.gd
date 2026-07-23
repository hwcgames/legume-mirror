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
	return LockHandle.new(self, false)
	#return func():
		#if shared_locks == 0:
			#printerr("Shared lock double-freed!")
			#return
		#shared_locks -= 1
		#if shared_locks == 0:
			#shared_free.emit()

func exclusive_lock() -> LockHandle:
	await wait_for_clear()
	exclusive_locked = true
	exclusive_take.emit()
	return LockHandle.new(self, true)
	#return func():
		#if !exclusive_locked:
			#printerr("Exclusive lock double-freed!")
			#return
		#exclusive_locked = false
		#exclusive_free.emit()

func wait_for_clear():
	while shared_locks > 0 or exclusive_locked:
		while shared_locks > 0:
			await shared_free
		while exclusive_locked:
			await exclusive_free
func is_clear():
	return !(shared_locks > 0 or exclusive_locked)

class LockHandle extends RefCounted:
	var locks: Locks
	var exclusive: bool
	var freed: bool = false
	## Should only be called by `Locks`.
	func _init(locks: Locks, exclusive: bool):
		self.locks = locks
		self.exclusive = exclusive
	static func dummy():
		return LockHandle.new(null, false)
	func release():
		if !is_instance_valid(locks):
			return
		if freed:
			printerr("BUG: Double-release on lock %s, by double-release on %s handle %s!" % [locks, "exclusive" if exclusive else "shared", self])
			breakpoint
			return
		freed = true
		if exclusive:
			if !locks.exclusive_locked:
				printerr("BUG: Double-release on lock %s by other exclusive handle!" % locks)
				breakpoint
				return
			locks.exclusive_locked = false
			locks.exclusive_free.emit()
		else:
			if locks.shared_locks <= 0:
				printerr("BUG: Extra-release on lock %s by other shared handle!" % locks)
				breakpoint
				return
			locks.shared_locks -= 1
			if locks.shared_locks == 0:
				locks.shared_free.emit()
	func forget():
		# This is bad!
		freed = true
	func _notification(what: int) -> void:
		if what != NOTIFICATION_PREDELETE:
			return
		if freed:
			return
		printerr("BUG: Lock handle freed without release! Releasing to avoid softlock...")
		breakpoint
		if exclusive and locks.exclusive_locked:
			locks.exclusive_locked = false
			locks.exclusive_free.emit()
		elif !exclusive and locks.shared_locks > 0:
			locks.shared_locks -= 1
			if locks.shared_locks == 0:
				locks.shared_free.emit()
