extends ItemEffect

func apply(player):
	player.max_hp -= 1
	if player.hp > player.max_hp:
		player.hp = player.max_hp

func remove(player):
	player.max_hp += 1
