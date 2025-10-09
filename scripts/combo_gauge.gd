extends VBoxContainer
@onready var _progress_bar = $ProgressBar
@onready var _label = $MultiplierLabel

var base_position: Vector2
var noise := FastNoiseLite.new()
var time_passed: float = 0.0	

func _process(_delta: float) -> void:
	var multiplier_value = PlayerManager.multiplier
	var combo_value = PlayerManager.get_combo_timer_value()
	var combo_total = PlayerManager.get_combo_timer_total_time()
	_progress_bar.value = move_toward(_progress_bar.value, combo_value, 0.3)
	_progress_bar.max_value = combo_total
	_label.text = "[shake amount=%f] x%d [/shake]" % [multiplier_value * 0.1, multiplier_value]
	
	var progress_ratio = 1.0 - (combo_value / combo_total)
	var intensity = clamp(multiplier_value / 10.0, 0.0, 1.0)
	
	var color_start = Color(0.1, 1.0, 0.1) 
	var color_end = Color(1.0, 0.2, 0.2)
	var color_mix = color_start.lerp(color_end, progress_ratio * (0.5 + intensity))
	
	_progress_bar.modulate = color_mix
