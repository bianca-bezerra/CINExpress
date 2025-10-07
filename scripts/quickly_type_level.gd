extends GameLevel
class_name QuicklyType

# Preload da cena para a letra
const type_feedback_write = preload("res://scenes/type_feeadback_write.tscn")

# Referências aos nós da cena (Onready vars)
@onready var hflow_container: HFlowContainer = $HFlowContainer
@onready var _feedback_label: Label = $VBoxContainer/FeedbackLabel
@onready var input_line_edit: LineEdit = $InputLineEdit

# Variáveis de estado do jogo
var _character_boxes: Array[Node] = []
const SCORE_FACTOR = 10
var _current_name: String = ""
var _current_letter_index: int = 0
var _round_start_time: float = 0.0


func unnanbrazile(letter: String) -> String:
	if letter == 'á' or letter == 'ã' or letter == 'â': return 'a'
	if letter == 'é' or letter == 'ẽ' or letter == 'ê': return 'e'
	if letter == 'í' or letter == 'î': return 'i'
	if letter == 'ó' or letter == 'õ' or letter == 'ô': return 'o'
	if letter == 'ú' or letter == 'û':  return 'u'
	if letter == 'ç': return 'c'
	return letter


func _ready() -> void:
	input_line_edit.text_changed.connect(_on_text_changed)
	start_game()


# Inicia ou reinicia a rodada
func start_game() -> void:
	_current_name = ""
	_current_letter_index = 0
	_feedback_label.text = ""

	var dificult_index = clamp(GameManager.current_level, 0, len(GameManager.names) - 1)
	_current_name = GameManager.names[dificult_index].pick_random()

	setup_word_display()
	update_ui()

	input_line_edit.clear()
	input_line_edit.grab_focus()

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

func setup_word_display() -> void:
	for child in hflow_container.get_children():
		child.queue_free()
	_character_boxes.clear()

	for char_text in _current_name:
		var char_box = type_feedback_write.instantiate()
		char_box.set_character(char_text)
		hflow_container.add_child(char_box)
		_character_boxes.append(char_box)


func _on_text_changed(new_text: String) -> void:
	var typed_so_far = new_text
	var correct_prefix = _current_name.left(typed_so_far.length())

	if typed_so_far != correct_prefix:
		var last_correct_text = _current_name.left(_current_letter_index)
		input_line_edit.text = last_correct_text
		input_line_edit.caret_column = last_correct_text.length()
		return
		
	_current_letter_index = typed_so_far.length()


	var spaces_were_skipped = false
	while _current_letter_index < _current_name.length() and _current_name[_current_letter_index] == " ":
		_current_letter_index += 1
		spaces_were_skipped = true

	
	if spaces_were_skipped:
		var text_with_spaces = _current_name.left(_current_letter_index)
		input_line_edit.text = text_with_spaces
		input_line_edit.caret_column = text_with_spaces.length()

	
	update_ui()

	if _current_letter_index >= _current_name.length():
		input_line_edit.release_focus()
		finish_game()


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
