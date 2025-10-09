extends VBoxContainer

@onready var label: Label = $Label
@onready var cursor: ColorRect = $ColorRect
@onready var cursor_timer: Timer = $CursorTimer

const COLOR_DEFAULT = Color("696969ff")
const COLOR_CORRECT = Color("008100ff")
const COLOR_INCORRECT = Color("lightcoral")

enum State { PENDING, ACTIVE, CORRECT, INCORRECT }

func _ready() -> void:
	set_state(State.PENDING)

func set_character(new_text: String) -> void:
	$Label.text = new_text

func _on_cursor_timer_timeout() -> void:
	cursor.visible = not cursor.visible

func set_state(new_state: State) -> void:
	cursor_timer.stop()
	cursor.visible = false
	cursor.modulate = COLOR_DEFAULT

	match new_state:
		State.PENDING:
			pass 
		State.ACTIVE:
			cursor.visible = true 
			cursor_timer.start()  
		State.CORRECT:
			cursor.visible = true
			cursor.modulate = COLOR_CORRECT
			
		State.INCORRECT:
			cursor.visible = true 
			cursor.modulate = COLOR_INCORRECT
