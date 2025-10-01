extends ItemEffect

func apply(player):
	player.gravity_scale = 1.5  # fall faster

func remove(player):
	player.gravity_scale = 1.0
