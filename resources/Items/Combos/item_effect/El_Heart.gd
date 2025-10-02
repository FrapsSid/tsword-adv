extends ItemEffect

var connection

func apply(player):
	connection = player.connect("damaged", Callable(self, "_on_damage").bind(player))

func remove(player):
	if connection:
		player.disconnect("damaged", connection)

func _on_damage(player):
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	await player.get_tree().create_timer(1.0).timeout
	player.set_physics_process(true)
