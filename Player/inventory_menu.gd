# InventoryMenu.gd
extends Control
class_name InventoryMenu

@export var player: Node

@onready var item_list: ItemList = $ItemList
@onready var description_label: Label = $Label

func _ready():
	visible = false
	item_list.connect("item_selected", Callable(self, "_on_item_selected"))


func open():
	visible = true
	grab_focus()
	_refresh_items()

func close():
	visible = false

func _refresh_items():
	item_list.clear()
	for item in player.inventory.items:
		item_list.add_item(item.name, item.icon)

func _on_item_selected(index: int):
	var item: Item = player.inventory.items[index]
	description_label.text = item.name
