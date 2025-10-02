extends Node

@export var player1: Player
@export var player2: Player

# Items mapped to each checkbox
@export var group1_items: Array[Item] = []  # length 2
@export var group2_items: Array[Item] = []  # length 2

# 2D matrix of checkboxes [group][index]
@onready var checkbox_matrix = [
	[$all/left/Slot1/CheckBox1, $all/left/Slot2/CheckBox2],
	[$all/left2/Slot1/CheckBox3, $all/left2/Slot2/CheckBox4]
]

# Track the state manually
var checkbox_state = [
	[false, false],  # group 1
	[false, false]   # group 2
]

func _ready():
	# Connect all checkboxes
	for group_index in range(checkbox_matrix.size()):
		for i in range(checkbox_matrix[group_index].size()):
			checkbox_matrix[group_index][i].toggled.connect(Callable(self, "_on_checkbox_toggled").bind(group_index, i))

func _on_checkbox_toggled(group_index: int, index: int, pressed: bool) -> void:
	# Update the state matrix
	checkbox_state[group_index][index] = pressed
	_check_assign_items()

func _check_assign_items():
	# Find selected index in each group
	var sel_indices = []
	for group in checkbox_state:
		var selected = []
		for i in range(group.size()):
			if group[i]:
				selected.append(i)
		sel_indices.append(selected)
	
	# Only assign if exactly one checkbox is selected in each group
	if sel_indices[0].size() == 1 and sel_indices[1].size() == 1:
		_assign_items(sel_indices[0][0], sel_indices[1][0])

func _assign_items(idx1: int, idx2: int):
	var chosen_item1 = group1_items[idx1]
	var chosen_item2 = group2_items[idx2]

	player1.pickup_item(chosen_item1)
	player2.pickup_item(chosen_item2)

	var other_item1 = group1_items[1 - idx1]
	var other_item2 = group2_items[1 - idx2]

	player1.pickup_item(other_item2)
	player2.pickup_item(other_item1)

	print("Player1 got:", chosen_item1.name, "and", other_item2.name)
	print("Player2 got:", chosen_item2.name, "and", other_item1.name)
