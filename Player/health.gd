extends HBoxContainer

var player_id: int = 2
@export var max_hp: int = 3
@export var heart_full: Texture2D
@export var heart_empty: Texture2D

var hearts: Array[TextureRect] = []

func _ready():
	if player_id == 2:
		self.position.x += 1300
	# Clear any existing children
	for child in get_children():
		child.queue_free()
	hearts.clear()

	# Initialize hearts
	for i in range(max_hp):
		var heart = TextureRect.new()
		heart.texture = heart_empty
		heart.custom_minimum_size = Vector2(100,100)  # clamp to desired size
		heart.expand = true
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.size_flags_horizontal = Control.SIZE_FILL
		heart.size_flags_vertical = Control.SIZE_FILL
		add_child(heart)
		hearts.append(heart)
	update_health(max_hp)

func update_health(current_hp: int):
	for i in range(hearts.size()):
		if i < current_hp:
			hearts[i].texture = heart_full
		else:
			hearts[i].texture = heart_empty

func reduce_max_hp(amount: int):
	max_hp = max(max_hp - amount, 1)  # prevent max_hp < 1

	# Remove extra hearts if needed
	while hearts.size() > max_hp:
		var last_heart = hearts.pop_back()
		last_heart.queue_free()

func increase_max_hp(amount: int):
	max_hp += amount

	# Add new hearts if needed
	while hearts.size() < max_hp:
		var heart = TextureRect.new()
		heart.texture = heart_empty
		heart.expand = true
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.size_flags_horizontal = Control.SIZE_FILL
		heart.size_flags_vertical = Control.SIZE_FILL
		add_child(heart)
		hearts.append(heart)
