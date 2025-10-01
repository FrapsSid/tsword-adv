extends CharacterBody2D
class_name Player

@export var max_hp := 3
@export var hp := 3

# ----------------------------
# Movement Settings
# ----------------------------
@export var move_speed := 100.0
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
enum States { IDLE, RUN, JUMP, FALL, MIDAIR, ATTACK }
var state := States.IDLE
var last_state := States.IDLE
var last_flip_h := false
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

	handle_input(delta)
	handle_horizontal(delta)
	handle_jump(delta)
	apply_gravity(delta)
	handle_attack(delta)
	move_and_slide()
	
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
	if attack_direction != AttackDir.NONE:
		state = States.ATTACK
	elif is_on_floor():
		if horizontal_input == 0:
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
enum AttackDir { NONE, UP, LEFT, RIGHT }
var attack_direction := AttackDir.NONE
var attack_timer := 0.0
@export var attack_cooldown := 0.3

# ----------------------------
# Handle directional attacks
# ----------------------------
func handle_attack(delta: float) -> void:
	if attack_timer > 0:
		attack_timer -= delta
		return

	if attack_direction != AttackDir.NONE :
		attack_direction = AttackDir.NONE

	if attack_timer <= 0 and Input.is_action_just_pressed("attack"):
		# Determine direction
		if Input.is_action_pressed("ui_up"):
			attack_direction = AttackDir.UP
		else:
			# Default to facing direction
			attack_direction = AttackDir.LEFT if sprite.flip_h else AttackDir.RIGHT

		perform_attack(attack_direction)

func perform_attack(dir: int) -> void:
	attack_timer = attack_cooldown

	# Play animation (if you want to add later)
	# match dir:
	# 	AttackDir.UP:
	# 		anim_player.play("Attack_Up")
	# 	AttackDir.LEFT:
	# 		anim_player.play("Attack_Left")
	# 	AttackDir.RIGHT:
	# 		anim_player.play("Attack_Right")

	# Spawn hitbox
	spawn_attack_hitbox(dir)

func spawn_attack_hitbox(dir: int) -> void:
	var hitbox := preload("res://resources/attack_hitbox/AttackHitbox.tscn").instantiate()
	add_child(hitbox)

	match dir:
		AttackDir.UP:
			hitbox.position = Vector2(0, -16) # above player
			hitbox.rotation_degrees = -90
		AttackDir.LEFT:
			hitbox.position = Vector2(-16, 0)
			hitbox.rotation_degrees = 180
		AttackDir.RIGHT:
			hitbox.position = Vector2(16, 0)
			hitbox.rotation_degrees = 0

	
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

signal animation_changed(state: int, flip_h: bool, attack_dir: int)

func apply_animation() -> void:
	# Instead of playing animations here, just notify others
	if state != last_state or sprite.flip_h != last_flip_h:
		last_flip_h = sprite.flip_h
		emit_signal("animation_changed", state, sprite.flip_h, attack_direction)

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
# Item System
# ----------------------------

@onready var inventory: Inventory = Inventory.new(self)

func pickup_item(item: Item) -> void:
	inventory.add_item(item)

func drop_item(item: Item) -> void:
	inventory.remove_item(item)

var active_effects: Array[ItemEffect] = []

func add_item_effect(effect: ItemEffect):
	if effect not in active_effects:
		active_effects.append(effect)
		effect.apply(self)

func remove_item_effect(effect: ItemEffect):
	if effect in active_effects:
		active_effects.erase(effect)
		effect.remove(self)
		
@onready var inventory_menu: InventoryMenu = $UI/InventoryMenu

func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		if inventory_menu.visible:
			inventory_menu.close()
		else:
			inventory_menu.open()
