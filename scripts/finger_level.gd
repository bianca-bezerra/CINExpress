extends GameLevel
class_name FingerLevel

@onready var win_timer = $WinTimer
@onready var finger = $Finger
@onready var digital_reader_sprite = $digital_reader/Sprite2D
@onready var floating_text_scene = preload("res://scenes/components/floating_text.tscn")

var can_win := false
var can_try := false
var _animation_stopped := false


var perfect_phrases = [
	"Perfeito!!",
	"Incrível!!",
	"Show!!",
	"Arrasou!!"
]

var bad_phrases = [
	"Err..",
	"Ops..",
	"Hã..?",
	"Ihh",
	"Vish...",
	"Eita!",
	"Oxe..."
]


func spawn_motivation_text():
	var score = finger.score_percentage
	var text = ""
	var color = Color.WHITE
	
	if score >= 0.1 or can_win:
		text = perfect_phrases[randi() % perfect_phrases.size()]
		text = "[shake][rainbow]%s[/rainbow][/shake]" % text
	else:
		text = bad_phrases[randi() % bad_phrases.size()]
		text = "[shake rate=10.0 level=2]%s[/shake]" % text
		color = Color("ff3700")
	
	var floating_text = floating_text_scene.instantiate()
	floating_text.text = text
	floating_text.modulate = color
	floating_text.scale = Vector2(2, 2)
	floating_text.global_position = $FeedbackMarker.global_position
	add_child(floating_text)

func _ready() -> void:
	digital_reader_sprite.play()

func _process(_delta: float) -> void:
	$Finger/DebugLabel.text = "is win? %s | score %.2f" % [can_win, finger.score_percentage]	
	if can_win and not _animation_stopped:
		digital_reader_sprite.frame = 1
		digital_reader_sprite.pause()
		_animation_stopped = true	

func _on_win_timer_timeout() -> void:
	GameManager.game_timer.paused = false
	if can_win:
		GameManager.change_to_next_level()
	else:
		finger.can_move = true
		
