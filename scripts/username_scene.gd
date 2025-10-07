extends Node2D
@onready var input = $NameInput

func _ready() -> void:
	input.grab_focus()

func _on_name_input_text_submitted(new_text: String) -> void:
	var player_name = new_text
	PlayerManager.register_new_player(player_name)
	GameManager.start_game()
