extends ItemEffect

func apply(player):
	player.move_speed *= 0.5

func remove(player):
	player.move_speed *= 2.0
