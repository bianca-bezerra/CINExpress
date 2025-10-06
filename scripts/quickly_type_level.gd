extends GameLevel
class_name QuicklyType

@onready var _prompt_label: RichTextLabel = $VBoxContainer/PromptLabel
@onready var _input_line_edit: LineEdit = $VBoxContainer/InputLineEdit
@onready var _feedback_label: Label = $VBoxContainer/FeedbackLabel

const SCORE_FACTOR = 1000 

var _current_name: String = ""
var _current_letter_index: int = 0

var _round_start_time: float = 0.0

func unnanbrazile(letter: String) -> String:
	if letter == 'á' or letter == 'ã':
		return 'a';
	if letter == 'é' or letter == 'ẽ':
		return 'e'
	if letter == 'í':
		return 'i'
	if letter == 'ó' or letter == 'õ':
		return 'o'
	if letter == 'ú':
		return 'u'
	if letter == 'ç':
		return 'c'
	return letter

func _change_finger_scene():
	get_tree().change_scene_to_file("res://scenes/levels/finger_scene.tscn")

func _on_input_change(typed_char: String) -> void:
	_input_line_edit.text = ''
	
	var expected_char: String = _current_name[_current_letter_index];
	
	if(typed_char == expected_char):
		_current_letter_index += 1;
		var _completed_part_of_name: String = _current_name.substr(0, _current_letter_index)
		var _uncompleted_part_of_name: String = _current_name.substr(_current_letter_index)
		
		_prompt_label.text = '[bgcolor=green]' + _completed_part_of_name + '[/bgcolor]' + _uncompleted_part_of_name
		
		_feedback_label.text += unnanbrazile(typed_char);
		
		if _current_letter_index == _current_name.length():
			finish_game();

func _ready() -> void:
	_input_line_edit.text_changed.connect(_on_input_change)	
	_input_line_edit.editable = false
	_input_line_edit.max_length = 1;
	_input_line_edit.keep_editing_on_text_submit = true
	_prompt_label.bbcode_enabled = true
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
	_prompt_label.text = '[pulse]' + _current_name + '[/pulse]'
	
	_round_start_time = Time.get_ticks_msec()

func finish_game() -> void:
	_input_line_edit.grab_click_focus.call_deferred()
	
	var time_spent_ms = Time.get_ticks_msec() - _round_start_time
	var time_spent_seg = time_spent_ms / 1000.0
	var score_multiplication = SCORE_FACTOR * (GameManager.current_level + 1)
	var points_added = int((len(_current_name) * score_multiplication) / time_spent_seg)
	
	GameManager.update_score(points_added)
 
	_feedback_label.text = "Boa! +%d pontos (%.2f seg)" % [points_added, time_spent_seg]	
	_change_finger_scene()
		
