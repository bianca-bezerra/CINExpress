extends GameLevel
class_name QuicklyType

const type_feedback_write = preload("res://scenes/type_feeadback_write.tscn")

@onready var hflow_container: HFlowContainer = $HFlowContainer
@onready var _feedback_label: Label = $VBoxContainer/FeedbackLabel 

var _character_boxes: Array[Node] = []

const SCORE_FACTOR = 10
var _current_name: String = ""
var _current_letter_index: int = 0
var _round_start_time: float = 0.0

func unnanbrazile(letter: String) -> String:
	if letter == 'á' or letter == 'ã': return 'a'
	if letter == 'é' or letter == 'ẽ': return 'e'
	if letter == 'í': return 'i'
	if letter == 'ó' or letter == 'õ': return 'o'
	if letter == 'ú': return 'u'
	if letter == 'ç': return 'c'
	return letter

	
func _ready() -> void:
	start_game()

func start_game() -> void:
	_current_name = ""
	_current_letter_index = 0
	_skip_spaces()
	_feedback_label.text = ""
	
	var dificult_index = clamp(GameManager.current_level, 0, len(GameManager.names) - 1)
	
	_current_name = GameManager.names[dificult_index].pick_random()
	setup_word_display()
	update_ui()
	
	_round_start_time = Time.get_ticks_msec()

func finish_game() -> void:
	var time_spent_ms = Time.get_ticks_msec() - _round_start_time
	var time_spent_seg = time_spent_ms / 1000.0
	var score_multiplication = SCORE_FACTOR * (GameManager.current_level + 1)
	var points_added = int((len(_current_name) * score_multiplication) / time_spent_seg)
	
	PlayerManager.add_score(points_added)
	_feedback_label.text = "Boa! +%d pontos (%.2f seg)" % [points_added, time_spent_seg]
	await get_tree().create_timer(2.0).timeout
	GameManager.change_to_next_level()

func _skip_spaces() -> void:
	while _current_letter_index < _current_name.length() and _current_name[_current_letter_index] == " ":
		_current_letter_index += 1


func setup_word_display() -> void:
	for child in hflow_container.get_children():
		child.queue_free()
	_character_boxes.clear()

	for char_text in _current_name:
		var char_box = type_feedback_write.instantiate()
		char_box.set_character(char_text)
		hflow_container.add_child(char_box)
		_character_boxes.append(char_box)


func _unhandled_input(event: InputEvent) -> void:
	if _current_letter_index >= _current_name.length():
		return

	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.is_action_pressed("ui_text_backspace"):
			if _current_letter_index > 0:
				_current_letter_index -= 1
				update_ui()
			return
		
		if event.unicode != 0:
			var typed_char = char(event.unicode) 
			var expected_char = _current_name[_current_letter_index]

			if unnanbrazile(typed_char) == unnanbrazile(expected_char):
				_current_letter_index += 1
				_skip_spaces()
				update_ui()
				if _current_letter_index >= _current_name.length():
					finish_game()
			else:
				pass

func update_ui() -> void:
	if _character_boxes.is_empty():
		return
		
	for i in _character_boxes.size():
		var box = _character_boxes[i]
		if i < _current_letter_index:
			box.set_state(box.State.CORRECT)
		elif i == _current_letter_index:
			box.set_state(box.State.ACTIVE)
		else:
			box.set_state(box.State.PENDING)
