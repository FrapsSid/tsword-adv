extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var shape_rect = $CollisionShape2D.shape.get_rect()
		
		# Convert local rect to global coordinates
		var global_rect_position = $CollisionShape2D.global_position + shape_rect.position

		var cam = body.get_node("Camera2D")
		cam.limit_left = int(global_rect_position.x)
		cam.limit_top = int(global_rect_position.y)
		cam.limit_right = int(global_rect_position.x + shape_rect.size.x)
		cam.limit_bottom = int(global_rect_position.y + shape_rect.size.y)
