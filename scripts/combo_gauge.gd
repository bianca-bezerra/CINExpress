extends VBoxContainer
@onready var _progress_bar = $ProgressBar
@onready var _label = $MultiplierLabel

var base_position: Vector2
var noise := FastNoiseLite.new()
var time_passed: float = 0.0

func _ready() -> void:
	visible = false
	base_position = position
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 1.0

func _process(delta: float) -> void:
	time_passed += delta
	var multiplier_value = GameManager.multiplier
	var combo_value = GameManager.get_combo_timer_value()
	var combo_total = GameManager.get_combo_timer_total_time()
	_progress_bar.value = combo_value
	_progress_bar.max_value = combo_total
	_label.text = "x%d" % multiplier_value
	
	var shake_strength = 2.0 * multiplier_value
	if multiplier_value > 1:
		var x_offset = noise.get_noise_1d(time_passed * 2.0) * shake_strength
		var y_offset = noise.get_noise_1d((time_passed + 100.0) * 2.0) * shake_strength
		position = base_position + Vector2(x_offset, y_offset)
	else:
		position = base_position
	
	var progress_ratio = 1.0 - (combo_value / combo_total)
	var intensity = clamp(multiplier_value / 10.0, 0.0, 1.0)
	
	var color_start = Color(0.1, 1.0, 0.1) 
	var color_end = Color(1.0, 0.2, 0.2)
	var color_mix = color_start.lerp(color_end, progress_ratio * (0.5 + intensity))
	
	_progress_bar.modulate = color_mix
