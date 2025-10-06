extends GameLevel
class_name FingerLevel

@onready var win_timer = $WinTimer
@onready var finger = $Finger
@onready var digital_reader_sprite = $digital_reader/Sprite2D
@onready var floating_text_scene = preload("res://scenes/floating_text.tscn")

var is_win := false
var text_spawned = false

func spawn_motivation_text():
	var score = finger.score_percentage
	var text = ""
	if score >= 0.5:
		text = "[rainbow]Perfeito!![/rainbow]"
	elif score >= 0.4:
		text = "Boa!"
	else:
		text = "[shake rate=10.0 level=2]Err...[/shake]"
	var floating_text = floating_text_scene.instantiate()
	floating_text.text = text
	floating_text.scale = Vector2(2, 2)
	floating_text.global_position = $FeedbackMarker.global_position
	add_child(floating_text)

func _process(_delta: float) -> void:
	if is_win:
		GameManager.game_timer.paused = true
		if not text_spawned:
			spawn_motivation_text()
			text_spawned = true
		digital_reader_sprite.play()
		finger.can_move = false
		if win_timer.is_stopped():
			win_timer.start(1.2)

func _on_win_timer_timeout() -> void:
	GameManager.game_timer.paused = false
	GameManager.change_to_next_level()
