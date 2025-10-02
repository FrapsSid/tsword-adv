extends EnemyAnimation

func _on_enemy_animation_changed(state: int, flip_h: bool):
	match state:
		EnemyTemplate.States.IDLE:
			play("Idle")
		EnemyTemplate.States.MOVE:
			play("Jump")

	self.flip_h = flip_h
