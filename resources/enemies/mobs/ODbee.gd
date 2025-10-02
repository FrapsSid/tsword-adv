extends Node2D  # or Area2D if you don't need physics movement

@export var speed: float = 150.0
@export var damage: int = 1

var player: Player = null

func _ready() -> void:
	# Find the player in the scene
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("No player found! Add your player to group 'player'.")
		
func _process(delta: float) -> void:
	if player == null:
		return

	# Fly directly at the player
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()

	# Check if close enough to hit
	if global_position.distance_to(player.global_position) < 12:
		_inflict_damage()

func _inflict_damage() -> void:
	if player and not player.is_dead:
		player.take_damage(damage)
	queue_free()  # enemy kills itself after hitting
