extends Node2D

@onready var added_score_mark: Marker2D = $Marker2D
@onready var timer_progress: Label = $TimerLabel
@onready var wallet: Label = $WalletLabel

var floating_text_scene: PackedScene = preload("res://scenes/components/floating_text.tscn")

func update_score_text():
	$ScoreLabel.text = "SCORE: %.2f" % PlayerManager.get_score()
	
func _format_time(remaining_time: float) -> String:
	@warning_ignore("integer_division")
	var minutes: int = int(remaining_time) / 60 
	var seconds: int = int(remaining_time) % 60	
	return "%02d:%02d" % [minutes, seconds]

func _ready() -> void:
	PlayerManager.score_chaged.connect(_on_player_score_changed)
	PlayerManager.combo_stopped.connect(_on_combo_stopped)
	
func _process(_delta: float) -> void:
	update_score_text()
	var timer: Timer = GameManager.game_timer
	timer_progress.text = _format_time(timer.time_left)
	wallet.text = "CINs: %d" % PlayerManager.get_cin_count()

func spawn_added_score(added_score: float):
	var added_score_obj: RichTextLabel = floating_text_scene.instantiate()
	added_score_obj.text = "+ %.2f" % added_score
	added_score_obj.global_position = added_score_mark.global_position
	add_child(added_score_obj)

func _on_combo_stopped():
	$ComboGauge.visible = false

func _on_player_score_changed(new_score: float):
	spawn_added_score(new_score)
	_play_score_animation()
	if PlayerManager.multiplier > 1:
		$ComboGauge.visible = true

func _play_score_animation():
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($ScoreLabel, "scale", Vector2(1.3,1.3), 0.3)
	tween.tween_property($ScoreLabel, "scale", Vector2(1,1), 0.3)
