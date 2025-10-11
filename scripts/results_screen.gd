extends Node2D

@onready var score_label: Label = $VBoxContainer/ScorePointsLabel
@onready var cins_label: Label = $CinsPointsLabel
@onready var title_label: RichTextLabel = $TitleLabel
@onready var retry_game_button: Button = $HBoxContainer/RetryGameButton
@onready var menu_button: Button = $HBoxContainer/MenuButton

const DELAY_BETWEEN_CATEGORIES: float = 0.3
const FADE_DURATION: float = 0.4
const ZOOM_SCALE: float = 2.0
const ZOOM_DURATION: float = 0.25
const BUTTON_LOCK_TIME: float = 3.0 

func _ready() -> void:
	GameManager.set_ui_visible(false)
	score_label.text = "0"
	cins_label.text = "x0"
	
	var _player_name: String = PlayerManager._current_player_data["name"]
	title_label.text = "Atendente\n[wave]%s[/wave]" % _player_name
	
	_set_buttons_enabled(false)

	start_score_animation()

	await get_tree().create_timer(BUTTON_LOCK_TIME).timeout
	_set_buttons_enabled(true)
	
	retry_game_button.grab_focus.call_deferred()


func _set_buttons_enabled(state: bool) -> void:
	retry_game_button.disabled = not state
	if $HBoxContainer.has_node("MenuButton"):
		$HBoxContainer/MenuButton.disabled = not state


func start_score_animation() -> void:
	await _animate_score_label(score_label, PlayerManager.get_score())
	await get_tree().create_timer(DELAY_BETWEEN_CATEGORIES).timeout

	await _animate_score_label(cins_label, PlayerManager.get_cin_count(), "x")
	await get_tree().create_timer(DELAY_BETWEEN_CATEGORIES).timeout


func _animate_score_label(label_to_animate: Label, target_score: int, prefix: String = "") -> void:
	if target_score <= 0:
		label_to_animate.text = "%s0" % prefix
		return

	var duration = clamp(target_score / 150.0, 0.6, 1.5)

	label_to_animate.modulate.a = 0.0
	var fade_in_tween := create_tween()
	fade_in_tween.tween_property(label_to_animate, "modulate:a", 1.0, FADE_DURATION)
	await fade_in_tween.finished

	var sound_tween := create_tween()
	sound_tween.tween_property(AudioManager.play_sfx("spinner_sound", 2.0), "pitch_scale", 1.0, duration)

	var tween := create_tween().set_parallel()
	tween.tween_method(
		_update_label_text.bind(label_to_animate, prefix),
		0.0,
		float(target_score),
		duration
	).set_ease(Tween.EaseType.EASE_OUT)
	await tween.finished

	label_to_animate.text = "%s%s" % [prefix, str(target_score)]
	AudioManager.stop_sfx()

	await _play_zoom_bang(label_to_animate)

	var fade_out_tween := create_tween()
	fade_out_tween.tween_property(label_to_animate, "modulate:a", 0.8, FADE_DURATION)
	await fade_out_tween.finished


func _update_label_text(value: float, label: Label, prefix: String) -> void:
	label.text = "%s%s" % [prefix, str(roundi(value))]


func _play_zoom_bang(label: Label) -> void:
	var zoom_tween := create_tween().set_parallel()
	label.scale = Vector2.ONE
	zoom_tween.tween_property(label, "scale", Vector2(ZOOM_SCALE, ZOOM_SCALE), ZOOM_DURATION).set_ease(Tween.EaseType.EASE_OUT)
	zoom_tween.tween_property(label, "scale", Vector2.ONE, ZOOM_DURATION).set_delay(ZOOM_DURATION).set_ease(Tween.EaseType.EASE_IN)
	await zoom_tween.finished
	AudioManager.play_sfx("bang_sound")


func _reset_data():
	GameManager.set_ui_visible(false)
	PlayerManager.reset_current_player_data()


func _on_retry_game_button_pressed() -> void:
	_reset_data()
	GameManager.change_to_username_scene()


func _on_menu_button_pressed() -> void:
	_reset_data()
	GameManager.change_to_menu_scene()
