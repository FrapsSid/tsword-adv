extends CharacterBody2D
class_name Player

# ----------------------------
# Movement Settings
# ----------------------------
@export var move_speed := 200.0
@export var acceleration := 15.0
@export var friction := 0.2

# ----------------------------
# Jump Settings
# ----------------------------
@export var jump_height := 400.0
@export var time_to_jump_apex := 0.4
@export var max_jump_hold := 0.2
@export var jump_cut_multiplier := 3.0
@export var gravity_scale := 1.0

# ----------------------------
# Derived physics values
# ----------------------------
@onready var gravity := (2 * jump_height) / (time_to_jump_apex*2)
@onready var jump_velocity := gravity * time_to_jump_apex

# ----------------------------
# State & input
# ----------------------------
enum States { IDLE, RUN, JUMP, FALL }
var state := States.IDLE
var last_state := States.IDLE
var jump_hold_timer := 0.0
var horizontal_input := 0.0

# ----------------------------
# Nodes
# ----------------------------
@onready var sprite := $Sprite2D
#@onready var anim_player := $AnimationPlayer

# ----------------------------
# Physics process
# ----------------------------
func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		handle_input(delta)
		handle_horizontal(delta)
		handle_jump(delta)
		apply_gravity(delta)
		move_and_slide()

	# Sync to other peers
	rpc("sync_state", global_position, velocity, state, sprite.flip_h)

	update_state()
	apply_animation()
	
	if is_multiplayer_authority():
		handle_input(delta)
		handle_horizontal(delta)
		handle_jump(delta)
		apply_gravity(delta)
		handle_attack(delta)
		move_and_slide()
	
	rpc("sync_state", global_position, velocity, state, sprite.flip_h, attack_direction)
	update_state()
	apply_animation()

# ----------------------------
# Input handling
# ----------------------------
func handle_input(delta: float) -> void:
	horizontal_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

# ----------------------------
# Horizontal movement with friction
# ----------------------------
func handle_horizontal(delta: float) -> void:
	var target_speed := float(horizontal_input) * move_speed

	if horizontal_input != 0:
		velocity.x = lerp(float(velocity.x), target_speed, acceleration * delta)
	else:
		velocity.x = lerp(float(velocity.x), 0.0, friction)

	if horizontal_input != 0:
		sprite.flip_h = horizontal_input < 0

# ----------------------------
# Jump handling
# ----------------------------
func handle_jump(delta: float) -> void:
	if is_on_floor():
		jump_hold_timer = 0.0
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = -jump_velocity
			jump_hold_timer = max_jump_hold
	else:
		# Variable jump height
		if Input.is_action_pressed("ui_accept") and jump_hold_timer > 0:
			jump_hold_timer -= delta
		elif Input.is_action_just_released("ui_accept") and velocity.y < 0:
			velocity.y /= jump_cut_multiplier

# ----------------------------
# Gravity with smooth apex
# ----------------------------
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		if velocity.y < 0:
			# Ascent: slower near apex
			var ascent_factor = clamp(abs(velocity.y) / jump_velocity, 0.0, 1.0)
			velocity.y += gravity * delta * gravity_scale * (0.5 + 0.5 * ascent_factor)
		else:
			# Descent: faster fall
			velocity.y += gravity * delta * gravity_scale * 1.5

# ----------------------------
# State machine
# ----------------------------
func update_state() -> void:
	last_state = state
	if is_on_floor():
		if abs(velocity.x) < 0.1:
			state = States.IDLE
		else:
			state = States.RUN
	else:
		if velocity.y < 0:
			state = States.JUMP
		else:
			state = States.FALL

# ----------------------------
# Attack Settings
# ----------------------------
enum AttackDir { NONE, UP, DOWN, LEFT, RIGHT }
var attack_direction := AttackDir.NONE
var attack_timer := 0.0
@export var attack_cooldown := 0.3

# ----------------------------
# Handle directional attacks
# ----------------------------
func handle_attack(delta: float) -> void:
	if attack_timer > 0:
		attack_timer -= delta

	if attack_timer <= 0 and Input.is_action_just_pressed("attack"):
		# Determine direction
		if Input.is_action_pressed("ui_up"):
			attack_direction = AttackDir.UP
		elif Input.is_action_pressed("ui_down"):
			attack_direction = AttackDir.DOWN
		else:
			# Default to facing direction
			attack_direction = AttackDir.LEFT if sprite.flip_h else AttackDir.RIGHT

		perform_attack(attack_direction)

func perform_attack(dir: int) -> void:
	attack_timer = attack_cooldown

	# Play animation
	#match dir:
		#AttackDir.UP:
			#anim_player.play("Attack_Up")
		#AttackDir.DOWN:
			#anim_player.play("Attack_Down")
		#AttackDir.LEFT:
			#anim_player.play("Attack_Left")
		#AttackDir.RIGHT:
			#anim_player.play("Attack_Right")

	# Spawn hitbox
	spawn_attack_hitbox(dir)

func spawn_attack_hitbox(dir: int) -> void:
	var hitbox := preload("res://assets/AttackHitbox.tscn").instantiate()
	# Add as child to player
	add_child(hitbox)

	match dir:
		AttackDir.UP:
			hitbox.set_direction(Vector2.UP)
		AttackDir.DOWN:
			hitbox.set_direction(Vector2.DOWN)
		AttackDir.LEFT:
			hitbox.set_direction(Vector2.LEFT)
		AttackDir.RIGHT:
			hitbox.set_direction(Vector2.RIGHT)

	
	# Play attack animation
	#match dir:
		#AttackDir.UP:
			#anim_player.play("Attack_Up")
		#AttackDir.DOWN:
			#anim_player.play("Attack_Down")
		#AttackDir.LEFT:
			#anim_player.play("Attack_Left")
		#AttackDir.RIGHT:
			#anim_player.play("Attack_Right")

func apply_animation() -> void:
	pass
	#if state != last_state:
		#match state:
			#States.IDLE:
				#anim_player.play("Idle")
			#States.RUN:
				#anim_player.play("Run")
			#States.JUMP:
				#anim_player.play("Jump")
			#States.FALL:
				#anim_player.play("Fall")

# ----------------------------
# Multiplayer sync
# ----------------------------
@rpc("unreliable")
func sync_state(pos: Vector2, net_velocity: Vector2, net_state: int, flip_h: bool) -> void:
	if not is_multiplayer_authority():
		global_position = pos
		velocity = net_velocity
		state = net_state
		sprite.flip_h = flip_h
