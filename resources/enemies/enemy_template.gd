extends CharacterBody2D
class_name EnemyTemplate

@export var is_flying_mob := false
# Enemy properties
@export var speed: float = 150.0
@export var acceleration := 5.0
@export var deceleration := 5.0
@export var turn_speed := 10.0
@export var gravity: float = 980.0

@export var max_hp := 3
@export var hp := 3
@export var stunnable := true
@export var knockback_horizontal := 200.0
@export var knockback_vertical := -150.0
@export var attack_knockback_scale :=  2
@export var stun_duration := 0.4

var stun_timer := 0.0

var velocity_target := Vector2.ZERO

@export var damage = 1

@onready var hitbox = $Hitbox

# State machine
enum States { IDLE, MOVE, ATTACK }
var state := States.IDLE
var last_state := States.IDLE
var flip_h := false
var last_flip_h := false

func _ready():
	pass


func _physics_process(delta: float):
	if stun_timer > 0:
		stun_timer -= delta
	if stun_timer <= 0:
		handle_flip(delta)
	if not is_flying_mob:
		apply_gravity(delta)
	
	update_velocity(delta)
	
	handle_hurtbox()
	handle_state(delta)
	apply_animation()
	move_and_slide()

func apply_gravity(delta: float) -> void:
	velocity.y += gravity * delta

func move_to(target_position: Vector2):
	if stun_timer > 0 and stunnable:
		return
	if not is_flying_mob and not is_on_floor():
		return
	
	var desired_direction: Vector2
	
	if not is_flying_mob:
		desired_direction = Vector2(target_position.x - global_position.x, 0).normalized()
	else:
		desired_direction = (target_position - global_position).normalized()
	
	# Smoothly rotate toward target direction while maintaining speed
	#var current_speed: float
	#if not is_flying_mob:
		#current_speed = Vector2(velocity.x, 0).length()
	#else:
		#current_speed = velocity.length()
	#if current_speed < 10:
		#current_speed = speed  # If stationary, use max speed
	#
	#var new_direction = velocity.normalized().lerp(desired_direction, turn_speed * get_physics_process_delta_time()).normalized()
	#velocity = new_direction * lerp(current_speed, speed, acceleration)
	
	velocity_target = desired_direction * speed

func update_velocity(delta: float) -> void:

	if velocity_target.x != 0:
		velocity.x = move_toward(velocity.x, velocity_target.x, acceleration * speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * speed * delta)

	if is_flying_mob:
		if velocity_target.y != 0:
			velocity.y = move_toward(velocity.y, velocity_target.y, acceleration * speed * delta)
		else:
			move_toward(velocity.y, 0, deceleration * speed * delta) 	

func handle_hurtbox() -> void:
	for body: Node2D in hitbox.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(damage)
			body.knockback_from(global_position)
			
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(damage)
		body.knockback_from(global_position, attack_knockback_scale)

func handle_state(_delta: float):
	last_state = state
	if velocity_target == Vector2.ZERO:
		state = States.IDLE 
	else:
		state = States.MOVE

func handle_flip(_delta: float):
	if velocity.x != 0:
		flip_h = velocity.x > 0

signal animation_changed(state: int, flip_h: bool)

func apply_animation() -> void:
	# Instead of playing animations here, just notify others
	if state != last_state or flip_h != last_flip_h:
		last_flip_h = flip_h
		emit_signal("animation_changed", state, flip_h)


# ----------------------------
# Combat System
# ----------------------------

func knockback_from(from: Vector2, scale: float = 1.0):
	var vec = global_position - from
	var direction = Vector2(vec.x, 0).normalized()
	
	velocity.x = direction.x * knockback_horizontal * scale
	velocity.y = knockback_vertical
	
	velocity_target = Vector2.ZERO
	stun_timer = stun_duration
	
func knockback_in_dir(direction: Vector2, scale: float = 1.0):
	
	velocity.x = direction.x * knockback_horizontal * scale
	velocity.y = knockback_vertical
	
	velocity_target = Vector2.ZERO
	stun_timer = stun_duration
	
# ----------------------------
# Death System
# ----------------------------

@export var death_sprite_scene: PackedScene  # optional: scene to spawn on death
@export var death_duration: float = 0.5      # how long death sprite stays

func take_damage(dmg: int):
	hp = max(0, hp - dmg)
	if hp <= 0:
		die()
		
func die():
	# Spawn death sprite before removing parent
	if death_sprite_scene:
		var death_sprite = death_sprite_scene.instantiate()
		get_tree().current_scene.add_child(death_sprite)
		death_sprite.global_position = global_position

		
		# Make sprite disappear after death_duration
		var t = Timer.new()
		t.wait_time = death_duration
		t.one_shot = true
		t.connect("timeout", Callable(death_sprite, "queue_free"))
		death_sprite.add_child(t)
		t.start()
	
	# Remove the whole mob (parent node)
	if is_instance_valid(get_parent()):
		get_parent().die()
