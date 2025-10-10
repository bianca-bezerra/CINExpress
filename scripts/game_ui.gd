extends Node2D

@onready var added_score_mark: Marker2D = $Marker2D
@onready var timer_progress: Label = $TimerLabel
@onready var wallet: Label = $WalletLabel
@onready var combo_gauge = $ComboGauge
@onready var score_label = $ScoreLabel
@onready var timer_anim = $TimerAnim
@onready var star_anim = $StarAnim
@onready var attendant_sprite: AnimatedSprite2D = $AtendantSprite

var floating_text_scene: PackedScene = preload("res://scenes/components/floating_text.tscn")

# controle para evitar recriar animações
var _is_low_time_animating := false
var _current_shake_intensity := 0.0
var _current_score = 0.0

func update_score_text():
	_current_score = lerp(_current_score, PlayerManager.get_score(), 0.1)
	score_label.text = "[shake rate=10] Pontos: %.2f" % _current_score
	
func _format_time(remaining_time: float) -> String:
	@warning_ignore("integer_division")
	var minutes: int = int(remaining_time) / 60
	var seconds: int = int(remaining_time) % 60
	return "%02d:%02d" % [minutes, seconds]

func _ready() -> void:
	PlayerManager.score_chaged.connect(_on_player_score_changed)
	PlayerManager.combo_stopped.connect(_on_combo_stopped)
	PlayerManager.cin_increased.connect(_on_cin_increased)
	timer_anim.play()
	star_anim.play()
	combo_gauge.modulate.a = 0
	
func _handle_animated_attendant():
	pass

func _process(_delta: float) -> void:
	update_score_text()
	var timer: Timer = GameManager.game_timer
	timer_progress.text = _format_time(timer.time_left)
	wallet.text = "x%d" % PlayerManager.get_cin_count()
	_check_time_warning(timer.time_left)

func _check_time_warning(remaining_time: float):
	# Quando o tempo estiver abaixo de 10 segundos, dispara a animação
	if remaining_time <= 10 and not _is_low_time_animating:
		_is_low_time_animating = true
		_start_time_warning_animation()
	elif remaining_time > 10 and _is_low_time_animating:
		_is_low_time_animating = false
		_reset_time_label()
		

func _start_time_warning_animation():
	var tween = get_tree().create_tween().set_loops() # faz repetir indefinidamente
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# faz o texto pulsar e mudar de cor em loop
	tween.tween_property(timer_progress, "scale", Vector2(1.2, 1.2), 0.4)
	tween.parallel().tween_property(timer_progress, "modulate", Color(1, 0.3, 0.3), 0.4)
	tween.tween_property(timer_progress, "scale", Vector2(1, 1), 0.4)
	tween.parallel().tween_property(timer_progress, "modulate", Color(1, 1, 1), 0.4)

	timer_progress.set_meta("warning_tween", tween)

func _reset_time_label():
	timer_progress.scale = Vector2.ONE
	timer_progress.modulate = Color.WHITE
	if timer_progress.has_meta("warning_tween"):
		var t = timer_progress.get_meta("warning_tween")
		if t:
			t.kill()

func spawn_added_score(added_score: float):
	var added_score_obj: RichTextLabel = floating_text_scene.instantiate()
	added_score_obj.text = "+ %.2f" % added_score
	added_score_obj.global_position = added_score_mark.global_position
	add_child(added_score_obj)

func _on_cin_increased():
	_play_cin_animation()

func _on_combo_stopped():
	_handle_attendant_sad_animation()
	if combo_gauge.modulate.a > 0:
		combo_gauge.animation_player.play_backwards("appearing")

func _on_player_score_changed(new_score: float):
	spawn_added_score(new_score)
	_play_combo_spring_animation()
	await _play_score_animation()
	_play_attendant_happy_animation()
	if PlayerManager.multiplier > 1 and combo_gauge.modulate.a <= 0:
		combo_gauge.animation_player.play("appearing")
		
func _on_game_finished():
	_current_score = PlayerManager.get_score()
	_current_shake_intensity = 0

func _play_attendant_happy_animation():
	$AtendantSprite.play("default")
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property($AtendantSprite, "scale", Vector2(1.3, 1.3), 0.3)
	tween.tween_property($AtendantSprite, "scale", Vector2(1, 1), 0.3)

func _play_score_animation():
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($ScoreLabel, "scale", Vector2(1.3, 1.3), 0.3)
	tween.tween_property($ScoreLabel, "scale", Vector2(1, 1), 0.3)
	await tween.finished

func _play_combo_spring_animation():
	# 🔹 Efeito de "spring" quando o combo aumenta
	var tween = get_tree().create_tween()
	var original_scale = combo_gauge.scale

	combo_gauge.scale = original_scale * 0.8  # começa levemente menor
	tween.tween_property(
		combo_gauge,
		"scale",
		original_scale * 1.2,   # dá um pulinho
		0.15
	).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		combo_gauge,
		"scale",
		original_scale,         # volta ao normal
		0.25
	).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		
	
func _play_cin_animation():
	var label: Label = $WalletLabel
	var tween = get_tree().create_tween()

	# Pisca em amarelo e volta ao normal
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(label, "modulate", Color(1, 1, 0), 0.15)
	tween.parallel().tween_property(label, "scale", Vector2(1.2, 1.2), 0.15)

	tween.tween_property(label, "modulate", Color(1, 1, 1), 0.15)
	tween.parallel().tween_property(label, "scale", Vector2(1, 1), 0.15)

func _handle_attendant_sad_animation():
	attendant_sprite.play("sad")
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($AtendantSprite, "scale", Vector2(1.2, 1.2), 0.15)
	tween.tween_property($AtendantSprite, "scale", Vector2(1, 1), 0.15)
	
