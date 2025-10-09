extends GameLevel
class_name QuicklyType

# Preload da cena para a letra
const type_feedback_write = preload("res://scenes/components/type_feeadback_write.tscn")


@onready var hflow_container: HFlowContainer = $CanvasLayer/HFlowContainer
@onready var feedback_label: RichTextLabel = $CanvasLayer/FeedbackLabel
@onready var input_line_edit: LineEdit = $CanvasLayer/InputLineEdit
@onready var warning_label = $CanvasLayer/WarningLabel
@onready var signature: Label = $CanvasLayer/AssinaturaDigital/signature

var good_phrases = [
	"Boa",
	"Legal",
	"Bacana",
    "Nice"
]

# Variáveis de estado do jogo
var _character_boxes: Array[Node] = []
const SCORE_FACTOR = 10
var _current_name: String = ""
var _current_letter_index: int = 0
var _round_start_time: float = 0.0
var _caps_lock_enabled := false


func unnanbrazile(letter: String) -> String:
	if letter == 'á' or letter == 'ã': return 'a'
	if letter == 'é' or letter == 'ẽ': return 'e'
	if letter == 'í': return 'i'
	if letter == 'ó' or letter == 'õ': return 'o'
	if letter == 'ú': return 'u'
	if letter == 'ç': return 'c'
	return letter


func _ready() -> void:
	warning_label.visible = false
	input_line_edit.text_changed.connect(_on_text_changed)
	start_game()

# Inicia ou reinicia a rodada
func start_game() -> void:
	_current_name = ""
	_current_letter_index = 0
	feedback_label.text = ""

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
	var good_phrase = good_phrases[randi() % good_phrases.size()]
	feedback_label.text = "[shake][rainbow]%s! (%.2f seg)[/rainbow][/shake]" % [good_phrase, time_spent_seg]
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
	
	signature.text = new_text

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

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_CAPSLOCK:
			_caps_lock_enabled = not _caps_lock_enabled
			warning_label.visible = _caps_lock_enabled

		elif event.unicode >= 65 and event.unicode <= 90:
			if not event.shift_pressed:
				_caps_lock_enabled = true
				warning_label.visible = true
		elif event.unicode >= 97 and event.unicode <= 122: 
			if event.shift_pressed:
				_caps_lock_enabled = true
				warning_label.visible = true
