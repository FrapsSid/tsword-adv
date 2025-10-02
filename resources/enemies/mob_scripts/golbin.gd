extends EnemyTemplate
class_name Goblin

@export var attack_cooldown: float = 1.0
var _attack_timer: float = 0.0

func _physics_process(delta: float):
	super._physics_process(delta)
	if _attack_timer > 0:
		_attack_timer -= delta

func handle_hurtbox() -> void:
	for body: Node2D in hitbox.get_overlapping_bodies():
		if body is Player and _attack_timer <= 0:
			state = States.ATTACK
			_attack_timer = attack_cooldown
			perform_attack(body)
			return
	
	# If attack finished, allow state reset
	if state == States.ATTACK and _attack_timer <= 0:
		state = States.IDLE
	else:
		super.handle_hurtbox()

func handle_state(_delta: float):
	# 🔹 Prevent parent logic from overwriting ATTACK
	if state == States.ATTACK:
		return
	
	# Otherwise, fallback to normal parent logic
	super.handle_state(_delta)

func perform_attack(player: Node2D):
	player.take_damage(damage)
	player.knockback_from(global_position, attack_knockback_scale)
