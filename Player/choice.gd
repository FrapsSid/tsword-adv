extends Node

@export var player1: Player
@export var player2: Player

# Items mapped to each checkbox
@export var group1_items: Array[Item] = []  # length 2
@export var group2_items: Array[Item] = []  # length 2

# ButtonGroups
var group1: ButtonGroup
var group2: ButtonGroup

# Checkboxes
@onready var checkboxes_group1: Array[CheckBox] = [$all/left/Slot1/CheckBox1, $all/left/Slot2/CheckBox2]
@onready var checkboxes_group2: Array[CheckBox] = [$all/left2/Slot1/CheckBox3, $all/left2/Slot2/CheckBox4]

func _ready():
	# Create button groups
	group1 = ButtonGroup.new()
	group2 = ButtonGroup.new()

	# Assign checkboxes to groups
	for cb in checkboxes_group1:
		cb.toggle_mode = true
		cb.group = group1
		cb.connect("toggled", Callable(self, "_on_checkbox_toggled"))

	for cb in checkboxes_group2:
		cb.toggle_mode = true
		cb.group = group2
		cb.connect("toggled", Callable(self, "_on_checkbox_toggled"))

func _on_checkbox_toggled(button_pressed: bool):
	if button_pressed:
		_check_assign_items()

func _check_assign_items():
	var sel1_idx = _get_selected_index(checkboxes_group1)
	var sel2_idx = _get_selected_index(checkboxes_group2)

	if sel1_idx != -1 and sel2_idx != -1:
		_assign_items(sel1_idx, sel2_idx)

func _get_selected_index(checkboxes: Array[CheckBox]) -> int:
	for i in range(checkboxes.size()):
		if checkboxes[i].pressed:
			return i
	return -1

func _assign_items(idx1: int, idx2: int):
	# Assign chosen items
	var chosen_item1 = group1_items[idx1]
	var chosen_item2 = group2_items[idx2]

	player1.pickup_item(chosen_item1)
	player2.pickup_item(chosen_item2)

	# Assign the "other" item to the opposite player
	var other_item1 = group1_items[1 - idx1]
	var other_item2 = group2_items[1 - idx2]

	player1.pickup_item(other_item2)
	player2.pickup_item(other_item1)

	print("Player1 got:", chosen_item1.name, "and", other_item2.name)
	print("Player2 got:", chosen_item2.name, "and", other_item1.name)
