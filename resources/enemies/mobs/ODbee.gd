extends Node2D
class_name SimpleEnemy

@export var speed: float = 10.0  # pixels per second

var target: Player

func _physics_process(delta):
	if target == null:
		return
	
	# Direction vector from enemy to target
	var dir = (target.global_position - global_position).normalized()
	
	# Move towards the target ignoring collisions (flies through walls)
	global_position += dir * speed * delta
	
	if global_position.distance_to(target.global_position) < 16:
		target.take_damage(1)
		queue_free()  # enemy disappears
