extends Area2D

@export var target_room: Node       # Room node to enter
@export var target_door: Node       # Destination door node
@export var tween_duration := 0.5   # Camera pan time

var is_locked := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body is Player and not is_locked:
		is_locked = true
		$CollisionShape2D.disabled = true  # disable trigger
		close_door_animation()

		# Teleport player immediately
		body.global_position = target_door.global_position

		# Update camera bounds of the new room
		var cam_bounds = target_room.get_node("CameraBounds")
		cam_bounds.emit_signal("body_entered", body)

		# Smooth camera pan
		var cam: Camera2D = body.get_node("Camera2D")
		smooth_camera_to(cam, cam_bounds)

func close_door_animation():
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("close")

# Smooth camera pan function
func smooth_camera_to(cam: Camera2D, bounds: Node):
	var shape_rect = bounds.get_node("CollisionShape2D").shape
	var global_pos = bounds.get_node("CollisionShape2D").global_position

	var target_rect = Rect2(
		global_pos - shape_rect.extents,
		shape_rect.extents * 2
	)

	var tween = create_tween()
	tween.tween_property(cam, "limit_left", int(target_rect.position.x), tween_duration)
	tween.tween_property(cam, "limit_top", int(target_rect.position.y), tween_duration)
	tween.tween_property(cam, "limit_right", int(target_rect.position.x + target_rect.size.x), tween_duration)
	tween.tween_property(cam, "limit_bottom", int(target_rect.position.y + target_rect.size.y), tween_duration)
