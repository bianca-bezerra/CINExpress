extends GameLevel
class_name QuicklyType

var _current_name: String = ""
var _round_start_time: float = 0.0

const _SCORE_FACTOR = 1000 

@onready var _prompt_label: Label = $VBoxContainer/PromptLabel
@onready var _input_line_edit: LineEdit = $VBoxContainer/InputLineEdit
@onready var _feedback_label: Label = $VBoxContainer/FeedbackLabel


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
	
	if GameManager.names.is_empty():
		# Se a lista de nomes acabar
		_feedback_label.text = "Parabéns! Você completou todos os nomes!"
		_input_line_edit.editable = false
		get_tree().change_scene_to_file("res://scenes/levels/finger_scene.tscn")
		return
	
	_current_name = GameManager.names.pick_random()
	
	GameManager.names.erase(_current_name) 
	_prompt_label.text = _current_name
	
	_round_start_time = Time.get_ticks_msec()

	

func _on_input_submitted(typed_text: String) -> void:
	_input_line_edit.grab_click_focus.call_deferred()
	if typed_text.strip_edges() == _current_name:
		var time_spent_ms = Time.get_ticks_msec() - _round_start_time
		var time_spent_seg = time_spent_ms / 1000.0
		var points_added = int((len(_current_name) * _SCORE_FACTOR) / time_spent_seg)
		
		GameManager.update_score(points_added)
	 
		_feedback_label.text = "Correto! +%d pontos (%.2f seg)" % [points_added, time_spent_seg]	
		get_tree().change_scene_to_file("res://scenes/levels/finger_scene.tscn")
	else:
		_feedback_label.text = "Incorreto! Tente novamente."
		_input_line_edit.clear()
		_input_line_edit.grab_focus.call_deferred()
		
