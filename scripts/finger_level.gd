extends GameLevel
class_name FingerLevel

@onready var win_timer = $WinTimer
@onready var finger = $Finger
@onready var digital_reader_sprite = $digital_reader/Sprite2D
@onready var floating_text_scene = preload("res://scenes/floating_text.tscn")

var can_win := false
var can_try := false
var _animation_played := false


var perfect_phrases = [
	"Perfeito!!",
	"Incrível!!",
	"Show!!"
]

var good_phrases = [
	"Boa",
	"Legal",
	"Bacana",
    "Nice"
]

var bad_phrases = [
	"Err..",
	"Ops..",
	"Hã..?",
    "Ihh"
]


func spawn_motivation_text():
	var score = finger.score_percentage
	var text = ""
	
	if score >= 0.5:
		text = perfect_phrases[randi() % perfect_phrases.size()]
		text = "[shake][rainbow]%s[/rainbow][/shake]" % text
	elif score >= 0.1 or can_win:
		text = good_phrases[randi() % good_phrases.size()]
	else:
		text = bad_phrases[randi() % bad_phrases.size()]
		text = "[shake rate=10.0 level=2]%s[/shake]" % text
	
	var floating_text = floating_text_scene.instantiate()
	floating_text.text = text
	floating_text.scale = Vector2(2, 2)
	floating_text.global_position = $FeedbackMarker.global_position
	add_child(floating_text)


func _process(_delta: float) -> void:
	$Finger/DebugLabel.text = "is win? %s | score %.2f" % [can_win, finger.score_percentage]	
	if can_win and not _animation_played:
		digital_reader_sprite.play()
		_animation_played = true	

func _on_win_timer_timeout() -> void:
	GameManager.game_timer.paused = false
	if can_win:
		GameManager.change_to_next_level()
	else:
		finger.can_move = true
