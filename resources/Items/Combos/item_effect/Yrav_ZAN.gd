extends ItemEffect

var timer: Timer

func apply(player):
	timer = Timer.new()
	timer.wait_time = 60.0
	timer.autostart = true
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "_spawn_enemy").bind(player))
	player.add_child(timer)

func remove(player):
	if timer:
		timer.queue_free()

func _spawn_enemy(player):
	var enemy = preload("res://scenes/FlyingEnemy.tscn").instantiate()
	var root = player.get_tree().current_scene
	root.add_child(enemy)

	# spawn off-screen
	var spawn_offset = Vector2(randf_range(-800, 800), randf_range(-600, -400))
	enemy.global_position = player.global_position + spawn_offset

	# fly toward player
	enemy.target = player
