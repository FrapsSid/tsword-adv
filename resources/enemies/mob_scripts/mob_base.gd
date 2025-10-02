extends Node
class_name MobBase

signal died

func die():
	emit_signal("died", self)
	queue_free()
