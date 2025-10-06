extends Node2D

@export var MAX_POINTS = 100
@export var SLIDER_GROW_FACTOR = 5 

@onready var slider = $VSlider
@onready var shaderRect = $RectBlur
@onready var v_slider_default_modulate = $VSlider.modulate

var slider_len = clamp(10 + SLIDER_GROW_FACTOR * GameManager.current_level, 0, MAX_POINTS)
var point = randi_range(1, slider_len)
var score_times = 0


func _ready() -> void:
	slider.grab_focus()
	slider.max_value = slider_len
	shaderRect.visible = true
	
func handle_win():
	slider.max_value = slider_len
	point = randi_range(1, slider_len)
	GameManager.change_to_next_level()
	

func _process(_delta: float) -> void:
	var actual_point = slider.value
	$DebugLabel.text = "Ponto atual: %d | Ponto: %d" % [actual_point, point]
	if actual_point == point:
		if Input.is_action_just_pressed("space"):
			handle_win()
		$VSlider.modulate = Color.GREEN
	elif abs(actual_point - point) < 3:
		$VSlider.modulate = Color.YELLOW
	else:
		$VSlider.modulate = v_slider_default_modulate

	shaderRect.material.set("shader_parameter/offset", 2 * (point  - actual_point))
