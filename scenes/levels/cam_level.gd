extends GameLevel

@export var MAX_POINTS = 100
@export var SLIDER_GROW_FACTOR = 5 

@onready var slider = $VSlider
@onready var shaderRect = $RectBlur
@onready var v_slider_default_modulate = $VSlider.modulate
@onready var floating_text_scene = preload("res://scenes/components/floating_text.tscn")

var slider_len = clamp(10 + SLIDER_GROW_FACTOR * GameManager.current_level, 0, MAX_POINTS)
var point = randi_range(1, slider_len/2)
var score_times = 0

var _phrases = ["Diga Xiss!", "Uau!", "Massa!"]

func _ready() -> void:
	slider.grab_focus()
	slider.max_value = slider_len
	slider.max_value = slider_len
	point = randi_range(slider_len/2, 2 + slider_len/2) 
	
func handle_win():
	var floating_text: RichTextLabel = floating_text_scene.instantiate()
	floating_text.global_position = $FeedbackMarker.global_position
	floating_text.scale = Vector2(1.5, 1.5)
	floating_text.rotation_degrees = 45
	floating_text.text = _phrases.pick_random()
	add_child(floating_text)
	$AnimationPlayer.play("flash")

func _process(_delta: float) -> void:
	var actual_point = slider.value
	$DebugLabel.text = "Ponto atual: %d | Ponto: %d" % [actual_point, point]
	if actual_point == point:
		if Input.is_action_just_pressed("space"):
			handle_win()
			return
		$VSlider.modulate = Color.GREEN
	elif abs(actual_point - point) < 3:
		$VSlider.modulate = Color.YELLOW
	else:
		$VSlider.modulate = v_slider_default_modulate

	shaderRect.material.set("shader_parameter/offset", 2 * (point  - actual_point))


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "flash":
		GameManager.change_to_next_level()
