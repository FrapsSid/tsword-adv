extends EnemyTemplate
class_name Slime

@export var jump_force: float = -400.0   # upward force for jump
@export var jump_interval: float = 1.5   # seconds between jumps
@export var jump_horizontal_speed: float = 100.0

var jump_timer: float = 0.0
var jump_direction := Vector2.ZERO

func _physics_process(delta: float):
	# Run parent physics
	super(delta)
	
	# Countdown to next jump
	jump_timer -= delta
	
	# Apply horizontal movement during jump
	if not is_on_floor():
		velocity.x = jump_direction.x * jump_horizontal_speed

func move_to(target_position: Vector2):
	# Only jump when on floor and timer is ready
	if is_on_floor() and jump_timer <= 0:
		do_jump(target_position)

func do_jump(target_position: Vector2):
	# Calculate jump direction
	jump_direction = Vector2(target_position.x - global_position.x, 0).normalized()
	
	# Apply jump forces
	velocity.y = jump_force
	velocity.x = jump_direction.x * jump_horizontal_speed
	
	# Reset timer
	jump_timer = jump_interval
