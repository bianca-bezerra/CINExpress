extends Node2D

@onready var added_score_mark: Marker2D = $Marker2D
@onready var timer_progress: ProgressBar = $TimerProgress

var floating_text_scene: PackedScene = preload("res://scenes/floating_text.tscn")

func update_score_text():
	$ScoreLabel.text = "SCORE: %.2f" % GameManager.get_score()
	

func _ready() -> void:
	timer_progress.max_value = GameManager.total_game_duration
	timer_progress.value = GameManager.total_game_duration
	update_score_text()
	GameManager.score_chaged.connect(_on_player_score_changed)
	
func _process(_delta: float) -> void:
	var timer: Timer = GameManager.game_timer
	timer_progress.value = timer.time_left
	

func spawn_added_score(added_score: float):
	var added_score_obj: RichTextLabel = floating_text_scene.instantiate()
	added_score_obj.text = "+ %.2f" % added_score
	added_score_obj.global_position = added_score_mark.global_position
	add_child(added_score_obj)

func _on_player_score_changed(new_score: float):
	update_score_text()
	spawn_added_score(new_score)
