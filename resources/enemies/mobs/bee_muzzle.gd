extends Node2D

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 400.0
@export var fire_rate: float = 1.0   # shots per second
@export var aim_at_player: NodePath

var _cooldown: float = 0.0
@onready var _target: Node2D = null
@onready var _enemy: EnemyTemplate = get_parent().get_node("EnemyTemplate")

func _ready():
	if aim_at_player != NodePath(""):
		_target = get_node(aim_at_player)

func _physics_process(delta: float):
	global_position = _enemy.global_position
	_cooldown -= delta
	if _cooldown <= 0.0:
		fire()
		_cooldown = 1.0 / fire_rate

func fire() -> void:
	if projectile_scene == null:
		return

	var proj = projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj) # spawn into world

	var dir: Vector2
	if _target:
		dir = (_target.global_position - global_position).normalized()
	else:
		if _enemy.flip_h:
			dir = Vector2.RIGHT
		else:
			dir = Vector2.LEFT

	proj.global_position = global_position
	proj.set_direction(dir)
