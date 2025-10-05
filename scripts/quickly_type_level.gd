extends GameLevel
class_name QuicklyType

@onready var _prompt_label: Label = $VBoxContainer/PromptLabel
@onready var _input_line_edit: LineEdit = $VBoxContainer/InputLineEdit
@onready var _feedback_label: Label = $VBoxContainer/FeedbackLabel

const SCORE_FACTOR = 1000 

var _current_name: String = ""
var _round_start_time: float = 0.0

func _change_finger_scene():
	GameManager.current_level += 1
	get_tree().change_scene_to_file("res://scenes/levels/finger_scene.tscn")

func _ready() -> void:
	_input_line_edit.text_submitted.connect(_on_input_submitted)
	_input_line_edit.editable = false
	_input_line_edit.keep_editing_on_text_submit = true
	start_game()

func start_game() -> void:
	_current_name = ""
	_input_line_edit.editable = true 
	_feedback_label.text = ""
	_input_line_edit.grab_focus.call_deferred()
	
	if len(GameManager.names) == GameManager.current_level:
		# Se a lista de nomes acabar
		_feedback_label.text = "Parabéns! Você completou todos os nomes!"
		_input_line_edit.editable = false
		_change_finger_scene()
		return
	
	_current_name = GameManager.names[GameManager.current_level].pick_random()
	_prompt_label.text = _current_name
	
	_round_start_time = Time.get_ticks_msec()

func _on_input_submitted(typed_text: String) -> void:
	_input_line_edit.grab_click_focus.call_deferred()
	if typed_text.strip_edges() == _current_name:
		var time_spent_ms = Time.get_ticks_msec() - _round_start_time
		var time_spent_seg = time_spent_ms / 1000.0
		var score_multiplication = SCORE_FACTOR * (GameManager.current_level + 1)
		var points_added = int((len(_current_name) * score_multiplication) / time_spent_seg)
		
		GameManager.update_score(points_added)
	 
		_feedback_label.text = "Correto! +%d pontos (%.2f seg)" % [points_added, time_spent_seg]	
		_change_finger_scene()
	else:
		_feedback_label.text = "Incorreto! Tente novamente."
		_input_line_edit.clear()
		_input_line_edit.grab_focus.call_deferred()
		
