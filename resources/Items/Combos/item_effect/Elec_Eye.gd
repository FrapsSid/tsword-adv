extends ItemEffect

func apply(player):
	player.slowness = 0.5

func remove(player):
	player.slowness = 1
