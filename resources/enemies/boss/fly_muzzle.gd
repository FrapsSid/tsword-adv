extends Muzzle
class_name MuzzleBurstSpread

@export var burst_count: int = 3            # number of bullets per burst
@export var burst_interval: float = 0.1     # time between bullets in burst
@export var spread_angle: float = 15.0      # max angle deviation in degrees

var _shots_fired_in_burst: int = 0
var _burst_timer: float = 0.0
var _is_bursting: bool = false

func _physics_process(delta: float) -> void:
	global_position = _enemy.global_position
	
	# Inherited targeting logic
	var visible_targets: Array[Node2D] = []
	for candidate in _targets:
		if candidate == null:
			continue
		_raycast.target_position = _raycast.to_local(candidate.global_position)
		_raycast.force_raycast_update()
		if _raycast.is_colliding() and _raycast.get_collider() == candidate:
			visible_targets.append(candidate)
	
	if visible_targets.size() > 0:
		_target = visible_targets.pick_random()
	else:
		_target = null
	
	# Burst logic with spread
	if _is_bursting:
		_burst_timer -= delta
		if _burst_timer <= 0.0 and _shots_fired_in_burst < burst_count:
			_shoot_spread()
			_shots_fired_in_burst += 1
			_burst_timer = burst_interval
		elif _shots_fired_in_burst >= burst_count:
			_is_bursting = false
			_cooldown = 1.0 / fire_rate
	else:
		_cooldown -= delta
		if _cooldown <= 0.0 and _target:
			_is_bursting = true
			_shots_fired_in_burst = 0
			_burst_timer = 0.0  # fire first shot immediately

# Fire a single bullet in a random direction near the target
func _shoot_spread() -> void:
	if projectile_scene == null or _target == null:
		return
	
	var proj = projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	
	# Base direction
	var dir: Vector2 = (_target.global_position - global_position).normalized()
	
	# Apply random spread angle
	var spread_rad = deg_to_rad(randf_range(-spread_angle/2, spread_angle/2))
	dir = dir.rotated(spread_rad)
	
	emit_signal("muzzle_shoots", dir)
	
	proj.global_position = global_position
	proj.set_direction(dir)
