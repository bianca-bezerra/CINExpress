extends Node2D

@onready var input = $NameInput
@onready var warning_label: Label = $WarningLabel


func _ready() -> void:
	warning_label.visible = false
	input.grab_focus()


func _on_name_input_text_submitted(new_text: String) -> void:
	var player_name = new_text
	
	for dashboard in SaveManager.game_data["dashboard"]:
		name = dashboard.get("name", "")
		
		if player_name == name:
			warning_label.visible = true
			warning_label.text = "Esse nome já existe"
			return 
	
	if player_name == "":
		warning_label.visible = true
		warning_label.text = "Insira um nome válido"
		return
		
	warning_label.visible = false
	PlayerManager.register_new_player(player_name)
	GameManager.start_game()
