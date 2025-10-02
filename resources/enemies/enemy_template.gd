extends CharacterBody2D
class_name EnemyTemplate

@export var is_flying_mob := false
# Enemy properties
@export var speed: float = 150.0
@export var acceleration := 0.5
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
	
	handle_hurtbox()
	
	handle_flip(delta)
	handle_state(delta)
	if not is_flying_mob:
		apply_gravity(delta)
	
	apply_animation()
	move_and_slide()

func apply_gravity(delta: float) -> void:
	velocity.y += gravity * delta

func move_to(target_position: Vector2):
	if stun_timer > 0 and stun_timer:
		return
	if not is_flying_mob and not is_on_floor():
		return
	
	var desired_direction: Vector2
	
	if not is_flying_mob:
		desired_direction = Vector2(target_position.x - global_position.x, 0).normalized()
	else:
		desired_direction = (target_position - global_position).normalized()
	
	# Smoothly rotate toward target direction while maintaining speed
	var current_speed: float
	if not is_flying_mob:
		current_speed = Vector2(velocity.x, 0).length()
	else:
		current_speed = velocity.length()
	if current_speed < 10:
		current_speed = speed  # If stationary, use max speed
	
	var new_direction = velocity.normalized().lerp(desired_direction, turn_speed * get_physics_process_delta_time()).normalized()
	velocity = new_direction * lerp(current_speed, speed, acceleration)
	
func handle_hurtbox() -> void:
	for body: Node2D in hitbox.get_overlapping_bodies():
		print(body.name)
		if body.is_in_group("player"):
			body.take_damage(damage)
			body.knockback_from(global_position)
			
func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name, "entered hitbox of", name)
	if body is Player:
		body.take_damage(damage)
		body.knockback_from(global_position, attack_knockback_scale)

func handle_state(_delta: float):
	last_state = state
	if velocity == Vector2.ZERO:
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

func knockback_from(from: Vector2, scale: int = 1):
	var vec = global_position - from
	var direction = Vector2(vec.x, 0).normalized()
	
	velocity.x = direction.x * scale
	velocity.y = knockback_vertical
	
	stun_timer = stun_duration
	
func knockback_in_dir(direction: Vector2, scale: int = 1):
	velocity.x = direction.x * knockback_horizontal * scale
	velocity.y = knockback_vertical
	
	stun_timer = stun_duration
	
func take_damage(dmg: int):
	hp = max(0, hp - dmg)
