extends Node2D


@onready var enemy = $EnemyTemplate
var targets: Array = []
var current_target_index := 0

func _ready() -> void:
	# Get all target children
	for child in get_children():
		if child.is_in_group("target"):
			targets.append(child)

func _physics_process(_delta: float) -> void:
	if targets.size() == 0:
		return
	
	var current_target = targets[current_target_index]
	enemy.move_to(current_target.global_position)
	
	# Switch to next target when close enough
	if enemy.global_position.distance_to(current_target.global_position) < 10:
		current_target_index = (current_target_index + 1) % targets.size()
