extends EnemyAnimation

@onready var muzzle: Muzzle = parent.get_node("Muzzle")

@export var shoot_anim_duration: float = 0.3

var shoot_anim_timer: float = 0.0
var shooted: bool = false
var _state: int = 0
var _flip_h: bool = false
var last_state: int = 0
var last_flip_h: bool = false

func _ready() -> void:
	super._ready()
	print(muzzle)
	muzzle.muzzle_shoots.connect(_on_muzzle_shot)

func _process(delta: float) -> void:
	super._process(delta)
	if shoot_anim_timer > 0:
		shoot_anim_timer -= delta
	if shooted and shoot_anim_timer <= 0:
		_on_enemy_animation_changed(last_state, last_flip_h)
		shooted = false

func _on_enemy_animation_changed(state: int, flip_h: bool):
	_state = state
	_flip_h = flip_h 
	if shoot_anim_timer > 0:
		last_state = _state
		last_flip_h = _flip_h
		return
		 
	super._on_enemy_animation_changed(_state, _flip_h)

func _on_muzzle_shot(direction: Vector2):
	flip_h = direction.x > 0
	shoot_anim_timer = shoot_anim_duration
	shooted = true
	last_state = _state
	last_flip_h = _flip_h
	play("Attack")
