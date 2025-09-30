extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var shape_rect = $CollisionShape2D.shape.get_rect()
		
		# Convert local rect to global coordinates
		var global_rect_position = $CollisionShape2D.global_position + shape_rect.position

		# Find the camera in the World scene
		var camera = get_tree().get_first_node_in_group("main_camera")
		if not camera:
			camera = get_tree().get_first_node_in_group("camera")
		
		if camera:
			camera.limit_left = int(global_rect_position.x)
			camera.limit_top = int(global_rect_position.y)
			camera.limit_right = int(global_rect_position.x + shape_rect.size.x)
			camera.limit_bottom = int(global_rect_position.y + shape_rect.size.y)
			fit_camera_to_rectangle(camera, $CollisionShape2D.shape, $CollisionShape2D.scale)

func fit_camera_to_rectangle(camera: Camera2D, rect_shape: RectangleShape2D, shape_scale: Vector2) -> void:
	print("happened")

	# Apply scale to extents → actual world size
	var rect_size: Vector2 = rect_shape.extents * 2 * shape_scale.abs()
	var viewport_size: Vector2 = camera.get_viewport_rect().size

	# Compute scale factors for both axes
	var scale_x = viewport_size.x / rect_size.x
	var scale_y = viewport_size.y / rect_size.y

	# Use the smaller scale so the whole rect fits
	var scale = min(scale_x, scale_y)

	print(scale, viewport_size, scale_x, scale_y, scale)

	# Apply zoom (inverse of scale)
	camera.zoom = Vector2(scale, scale)
