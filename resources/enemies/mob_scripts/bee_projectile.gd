extends Node2D

@export var speed: float = 400.0
@export var lifetime: float = 3.0
@export var damage: int = 1
@export var attack_knockback_scale: float = 1.0
var velocity: Vector2 = Vector2.ZERO

func set_direction(dir: Vector2) -> void:
	velocity = dir.normalized() * speed
	rotation = velocity.angle()

func _physics_process(delta: float) -> void:
	position += velocity * delta

	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	print (body)
	if body is EnemyTemplate:
		return

	if body is Player:
		body.take_damage(damage)
		body.knockback_from(global_position, attack_knockback_scale)
	
	queue_free()
