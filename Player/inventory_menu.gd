extends CanvasLayer
class_name InventoryMenu

@export var player: Player

# This will hold references to the slot TextureRects
@onready var slots: Array[TextureRect] = []

# Reference to combo description buttons
@onready var combo_buttons := [
	$VBoxContainer/ComboDesc1,
	$VBoxContainer/ComboDesc2,
	$VBoxContainer/ComboDesc3
]

func _ready():
	visible = false

	# Position anchors if this is Player 2
	if player.player_id == 2:
		$Paper.anchor_left = 0.5
		$Paper.anchor_right = 1.0
		$Paper.anchor_top = 1.0
		$Paper.anchor_bottom = 0.0
		$GridContainer.anchor_left = 0.5
		$GridContainer.anchor_right = 1.0
		$GridContainer.anchor_top = 1.0
		$GridContainer.anchor_bottom = 0.0
		# Get the viewport width
		var screen_w = get_viewport().get_visible_rect().size

		# Suppose your container width is container_w
		var container_w = $VBoxContainer.size.x
		# Move container to the right half, keeping some margin from center
		var margin = 400
		$VBoxContainer.position.x = screen_w.x / 2 + margin
		# Optional: center vertically
		$VBoxContainer.position.y = (get_viewport().get_visible_rect().size.y - $VBoxContainer.size.y) / 2


	# Collect all slot TextureRects from GridContainer
	for slot in $GridContainer.get_children():
		var tex_rect: TextureRect = slot.get_node("TextureRect")
		slots.append(tex_rect)

func open():
	visible = true
	_refresh_items()

func close():
	visible = false

func _refresh_items():
	# Clear all slot textures first
	for tex in slots:
		tex.texture = null
		tex.tooltip_text = ""
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Assign textures from player inventory
	for i in range(min(slots.size(), player.inventory.items.size())):
		var item: Item = player.inventory.items[i]
		if item.icon:
			slots[i].texture = item.icon
		slots[i].tooltip_text = item.name
		slots[i].mouse_filter = Control.MOUSE_FILTER_STOP

	# Now update combo description buttons
	_check_combos()

func _check_combos():
	# Hide all buttons first
	for b in combo_buttons:
		b.visible = false
		b.disabled = true

	# Example combo checks (replace with your real combos!)
	if player.inventory.has_item(preload("res://resources/Items/Combos/combo_items/WaterHeart.tres")):
		combo_buttons[0].tooltip_text = preload("res://resources/Items/Combos/combo_items/WaterHeart.tres").description
		combo_buttons[0].visible = true
		combo_buttons[0].disabled = false
