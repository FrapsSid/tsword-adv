extends AnimatedSprite2D
class_name EnemyAnimation

@onready var parent: Node2D = get_parent()
@onready var enemy: EnemyTemplate = parent.get_node("EnemyTemplate")

func _ready() -> void:
	enemy.animation_changed.connect(_on_enemy_animation_changed)

func _process(_delta: float) -> void:
	global_position = enemy.global_position

func _on_enemy_animation_changed(state: int, flip_h: bool):
	match state:
		EnemyTemplate.States.IDLE:
			play("Idle")
		EnemyTemplate.States.MOVE:
			play("Move")

	self.flip_h = flip_h
