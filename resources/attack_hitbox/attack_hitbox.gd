extends Area2D

@export var damage := 1
@export var lifetime := 0.2 # seconds
@export var size := Vector2(30, 10)  # default hitbox size
var direction := Vector2.RIGHT  # default attack direction

@onready var col_shape := $CollisionShape2D

func _ready():
	#_update_transform()
	# Auto-remove after lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _on_body_entered(body):
	print(body)
	if body is EnemyTemplate:
		body.take_damage(damage)
		body.knockback_in_dir(direction)
		queue_free()  # remove immediately after hitting

# Set attack direction before adding as child
func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	#_update_transform()

func _update_transform() -> void:
	# Scale and position relative to parent
	if direction.x != 0:  # Horizontal
		col_shape.scale = Vector2(size.x * abs(direction.x), size.y)
		position = Vector2(sign(direction.x) * size.x * 0.5, 0)
	elif direction.y != 0:  # Vertical
		col_shape.scale = Vector2(size.y, size.x * abs(direction.y))
		position = Vector2(0, sign(direction.y) * size.x * 0.5)
