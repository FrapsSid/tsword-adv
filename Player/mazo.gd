extends TextureProgressBar
signal bar_empty_tick

# Config
@export var drain_per_second: int = 1
@export var empty_signal_interval: float = 5.0
@export var refill_on_damage: int = 10

# Internal
var current_value: int
var _drain_timer: float = 0.0
var _empty_timer: float = 0.0

func wake():
	set_process(true)
	visible = true
	current_value = max_value
	value = current_value

func _ready():
	visible = false
	set_process(false)   # stop the drain when hidden
	self.size = Vector2(1, 100)
	current_value = max_value
	value = current_value

func _process(delta):
	if current_value > 0:
		_drain_timer += delta
		if _drain_timer >= 1.0:
			_drain_timer = 0.0
			current_value = max(current_value - drain_per_second, 0)
			value = current_value
	else:
		# Bar is empty
		_empty_timer += delta
		if _empty_timer >= empty_signal_interval:
			_empty_timer = 0.0
			emit_signal("bar_empty_tick")

# Called when player takes damage
func refill():
	current_value = min(current_value + refill_on_damage, max_value)
	value = current_value
