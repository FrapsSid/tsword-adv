extends Node
class_name Inventory

signal item_added(item: Item)
signal item_removed(item: Item)

var items: Array[Item] = []   # normal items
var combos: Array[Item] = []  # combo items
var player: Node = null

func _init(_player: Node):
	player = _player

func add_item(item: Item) -> void:
	if item.is_combo:
		# Add to combo list
		if item not in combos:
			combos.append(item)
			if item.effect:
				var eff_instance = item.effect.new()  # create an instance of the script
				eff_instance.apply(player)
	else:
		# Add to normal inventory
		if item not in items:
			items.append(item)
			emit_signal("item_added", item)

func remove_item(item: Item) -> void:
	if item.is_combo:
		if item in combos:
			combos.erase(item)
			emit_signal("item_removed", item)
	else:
		if item in items:
			items.erase(item)
			if item.effect:
				item.effect.remove(player)
			emit_signal("item_removed", item)

func has_item(item: Item) -> bool:
	if item.is_combo:
		return item in combos
	return item in items

func has_combo(item: Item) -> bool:
	return item in combos
