extends Node2D
class_name Muzzle

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 400.0
@export var fire_rate: float = 0.5    # shots per second
@export var aim_at_player1: NodePath
@export var aim_at_player2: NodePath

var _cooldown: float = 0.0
@onready var _targets: Array[Node2D] = []
@onready var _enemy: EnemyTemplate = get_parent().get_node("EnemyTemplate")
@onready var _raycast: RayCast2D = $RayCast2D

var _target: Node2D = null

signal muzzle_shoots(direction: Vector2)

func _ready():
	if aim_at_player1 != NodePath(""):
		_targets.append(get_node(aim_at_player1))
	if aim_at_player2 != NodePath(""):
		_targets.append(get_node(aim_at_player2))
	_raycast.add_exception(_enemy)

func _physics_process(delta: float):
	global_position = _enemy.global_position
	
	# Check which players are visible
	var visible_targets: Array[Node2D] = []
	for candidate in _targets:
		if candidate == null:
			continue
		_raycast.target_position = _raycast.to_local(candidate.global_position)
		_raycast.force_raycast_update()
		if _raycast.is_colliding():
			if _raycast.get_collider() == candidate:
				visible_targets.append(candidate)
	
	# Pick one of the visible targets at random
	if visible_targets.size() > 0:
		_target = visible_targets.pick_random()
	else:
		_target = null
	
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	
	if _target:
		fire()
		_cooldown = 1.0 / fire_rate

func fire() -> void:
	if projectile_scene == null:
		return
	
	var proj = projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)

	var dir: Vector2
	if _target:
		dir = (_target.global_position - global_position).normalized()
	else:
		dir = Vector2.RIGHT if _enemy.flip_h else Vector2.LEFT

	emit_signal("muzzle_shoots", dir)

	proj.global_position = global_position
	proj.set_direction(dir)
