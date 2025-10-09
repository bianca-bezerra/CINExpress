extends GameLevel

@export var MAX_POINTS = 100
@export var SLIDER_GROW_FACTOR = 5 

@onready var shaderRect = $RectBlur
@onready var v_slider_default_modulate = $VSlider.modulate
@onready var floating_text_scene = preload("res://scenes/components/floating_text.tscn")
@onready var reset_timer = $ResetTimer
@onready var personagem_sprite = $Icon

var slider_len = clamp(10 + SLIDER_GROW_FACTOR * GameManager.current_level, 0, MAX_POINTS)
var point = randi_range(1, slider_len/2)
var score_times = 0
var _phrases = ["Diga Xiss!", "Uau!", "Massa!"]

@onready var _sliders = [$HSlider, $VSlider]
@onready var _current_slider = _sliders.pick_random()

var player_winned = false

func _ready() -> void:

	if personagem_sprite and CharacterManager.personagem_atual:
		personagem_sprite.texture = CharacterManager.get_sprite_cinza()
		print("📸 Personagem no minigame da câmera: ", CharacterManager.personagem_atual)
	
	_current_slider.grab_focus()
	_current_slider.max_value = slider_len
	
	for item in _sliders:
		if item != _current_slider:
			item.visible = false

	point = randi_range(slider_len/2, 2 + slider_len/2) 
	_current_slider.value = randi_range(point - slider_len/2, point + slider_len/2)
	while _current_slider.value == point:
		_current_slider.value = randi_range(point - slider_len/2, point + slider_len/2)
	
func handle_win():

	if personagem_sprite:
		personagem_sprite.texture = CharacterManager.get_sprite_feliz()
		print("😊 Personagem ficou feliz após a foto!")
	
	var floating_text: RichTextLabel = floating_text_scene.instantiate()
	floating_text.global_position = $FeedbackMarker.global_position
	floating_text.scale = Vector2(1.5, 1.5)
	floating_text.rotation_degrees = 45
	floating_text.text = "[shake][rainbow]%s[/rainbow][/shake]" % _phrases.pick_random()
	add_child(floating_text)
	PlayerManager.add_score(100)
	$AnimationPlayer.play("flash")
	AudioManager.play_sfx("flash")

func _process(_delta: float) -> void:
	var actual_point = _current_slider.value
	$DebugLabel.text = "Ponto atual: %d | Ponto: %d" % [actual_point, point]
	
	if player_winned: return
	if Input.is_action_just_pressed("space"):
		if actual_point == point:
			handle_win()
			player_winned = true
			return
		AudioManager.play_sfx("wrong_hit")
		PlayerManager.stop_combo()
	if actual_point == point:
		_current_slider.modulate = Color.GREEN
	elif abs(actual_point - point) < 3:
		_current_slider.modulate = Color.YELLOW
	else:
		$VSlider.modulate = v_slider_default_modulate
	
	shaderRect.material.set("shader_parameter/offset", 2 * (point  - actual_point))

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "flash":
		GameManager.change_to_next_level()
