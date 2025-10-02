extends Area2D

@export var target_room: Node       # Room node to enter
@export var target_door: Node       # Destination door node
@export var mobs_room: Node         # Find all mobs in this room
@export var tween_duration := 0.5   # Camera pan time

var is_locked := true
var mobs_in_room: Array = []

func _ready():
	if not mobs_room:
		is_locked = false
		return
	for child in mobs_room.get_children():
		if child.is_in_group("mobs"):
			mobs_in_room.push_back(child)
			if child.has_signal("died"):
				child.connect("died", Callable(self, "_on_mob_died"))
	print(mobs_in_room)
	if mobs_in_room.is_empty():
		is_locked = false

func _on_mob_died(mob):
	mobs_in_room.erase(mob)
	if mobs_in_room.is_empty():
		is_locked = false

func _on_body_entered(body: Node) -> void:
	if body is Player and not is_locked:
		is_locked = true
		$CollisionShape2D.disabled = true  # disable trigger
		close_door_animation()

		# Teleport player immediately
		var i = 0
		for p in get_tree().get_nodes_in_group("player"):
			p.global_position = target_door.global_position + Vector2(10, 0) * i
			i += 1

		# Switch to the target room's camera
		switch_to_target_room_camera()

func close_door_animation():
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("close")

func switch_to_target_room_camera():
	# Get the target room's camera bounds
	var target_camera_bounds = target_room.get_node("CameraBounds")
	if target_camera_bounds:
		# Trigger the camera bounds to switch cameras
		target_camera_bounds.emit_signal("body_entered", get_tree().get_first_node_in_group("player"))
