extends VBoxContainer

@onready var label: Label = $Label
@onready var cursor: ColorRect = $ColorRect

const COLOR_DEFAULT = Color("white")
const COLOR_CORRECT = Color("lightgreen")
const COLOR_INCORRECT = Color("lightcoral")

enum State { PENDING, ACTIVE, CORRECT, INCORRECT }

func _ready() -> void:
	# Estado inicial padrão
	set_state(State.PENDING)

func set_character(new_text: String) -> void:
	$Label.text = new_text

func set_state(new_state: State) -> void:
	cursor.visible = false
	cursor.modulate = COLOR_DEFAULT

	match new_state:
		State.PENDING:
			pass 
		State.ACTIVE:
			cursor.visible = true
		State.CORRECT:
			cursor.visible = true
			cursor.modulate = COLOR_CORRECT
		State.INCORRECT:
			cursor.modulate = COLOR_INCORRECT
