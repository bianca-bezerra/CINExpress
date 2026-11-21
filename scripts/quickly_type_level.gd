extends GameLevel
class_name QuicklyType

# Preload da cena para a letra
const type_feedback_write = preload("res://scenes/components/type_feeadback_write.tscn")
var names = preload("res://scripts/names.gd").new()

@onready var hflow_container: HFlowContainer = $CanvasLayer/HFlowContainer
@onready var feedback_label: RichTextLabel = $CanvasLayer/FeedbackLabel
@onready var input_line_edit: LineEdit = $CanvasLayer/InputLineEdit
@onready var warning_label = $CanvasLayer/WarningLabel
@onready var signature: Label = $CanvasLayer/AssinaturaDigital/signature
@onready var instruction_1 = $Instruction1
@onready var instruction_2 = $Instruction2

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

func _ready() -> void:
	warning_label.visible = false
	input_line_edit.text_changed.connect(_on_text_changed)
	start_game()

# Inicia ou reinicia a rodada
func start_game() -> void:
	_current_name = ""
	_current_letter_index = 0
	feedback_label.text = ""

	var fase_atual: int = GameManager.current_level
	var fase_par: bool = (fase_atual % 2) == 0
	
	# O nome começa com tamanho de 3, e aumenta em 1 a cada 2 fases
	var tamanho_nome: int = (fase_atual - 1) + 3 if fase_par else fase_atual - 1 + 2

	tamanho_nome = clamp(tamanho_nome, 3, 20)
	print("Tamanho do nome no jogo de teclado: ", tamanho_nome)
	var genero_atual: int = CharacterManager.get_genero_personagem_atual()
	
	_current_name = names.gerar_nome(genero_atual, tamanho_nome)
	CharacterManager.registrar_nome_atual(_current_name)
	
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
	var typed_so_far: String = names.normalizar_nome(new_text)
	var correct_prefix = _current_name.left(typed_so_far.length())

	if typed_so_far != correct_prefix:
		var last_correct_text = _current_name.left(_current_letter_index)
		input_line_edit.text = last_correct_text
		input_line_edit.caret_column = last_correct_text.length()
		return
		
	if input_line_edit.text != typed_so_far:
		input_line_edit.text = typed_so_far
		input_line_edit.caret_column = typed_so_far.length()

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
	
	signature.text = input_line_edit.text

	if _current_letter_index >= _current_name.length():
		input_line_edit.release_focus()
		finish_game()

func update_ui() -> void:
	$PlusLabel.hide()
	instruction_2.hide()
	if _character_boxes.is_empty():
		return

	for i in _character_boxes.size():
		var box = _character_boxes[i]
		if i < _current_letter_index:
			box.set_state(box.State.CORRECT)
		elif i == _current_letter_index:
			var letter = _current_name[_current_letter_index]
			instruction_1.setup_instruction(letter)

			box.set_state(box.State.ACTIVE)
		else:
			box.set_state(box.State.PENDING)
