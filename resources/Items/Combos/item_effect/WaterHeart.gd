extends ItemEffect

func apply(player) -> void:
	player.friction = 0.005   # smaller = more slippery

func remove(player) -> void:
	player.friction = 0.2    # reset to default
