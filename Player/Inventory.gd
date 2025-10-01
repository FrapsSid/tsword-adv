# Inventory.gd
extends Node
class_name Inventory

signal item_added(item: Item)
signal item_removed(item: Item)

var items: Array[Item] = []
var player: Node = null

func _init(_player: Node):
	player = _player

func add_item(item: Item) -> void:
	if item not in items:
		items.append(item)
		if item.effect:
			item.effect.apply(player)
		emit_signal("item_added", item)

func remove_item(item: Item) -> void:
	if item in items:
		items.erase(item)
		if item.effect:
			item.effect.remove(player)
		emit_signal("item_removed", item)

func has_item(item: Item) -> bool:
	return item in items
