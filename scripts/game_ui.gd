extends Node2D

@onready var added_score_mark: Marker2D = $Marker2D
@onready var timer_progress: Label = $TimerLabel
@onready var wallet: Label = $WalletLabel

var floating_text_scene: PackedScene = preload("res://scenes/floating_text.tscn")
var _score_to_show = 0.0
func update_score_text():
	_score_to_show = move_toward(_score_to_show, PlayerManager.get_score(), 5)
	$ScoreLabel.text = "SCORE: %.2f" % _score_to_show
	
func _format_time(remaining_time: float) -> String:
	@warning_ignore("integer_division")
	var minutes: int = int(remaining_time) / 60 
	var seconds: int = int(remaining_time) % 60

	return "%02d:%02d" % [minutes, seconds]

func _ready() -> void:
	PlayerManager.score_chaged.connect(_on_player_score_changed)
	GameManager.combo_stopped.connect(_on_combo_stopped)
	
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
	$ComboGauge.visible = true
